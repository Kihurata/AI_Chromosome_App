import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String? id;
  final String bloodGroup;
  final String address;
  final DateTime dob;
  final String email;
  final String fullName;
  final String gender;
  final String phone;
  final String status; // active, inactive

  PatientModel({
    this.id,
    required this.bloodGroup,
    required this.address,
    required this.dob,
    required this.email,
    required this.fullName,
    required this.gender,
    required this.phone,
    this.status = 'active',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'blood_group': bloodGroup,
      'address': address,
      'dob': Timestamp.fromDate(dob),
      'email': email,
      'full_name': fullName,
      'gender': gender,
      'phone': phone,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      id: doc.id,
      bloodGroup: data['blood_group'] ?? '',
      address: data['address'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      email: data['email'] ?? '',
      fullName: data['full_name'] ?? '',
      gender: data['gender'] ?? '',
      phone: data['phone'] ?? '',
      status: data['status'] ?? 'active',
    );
  }
}
