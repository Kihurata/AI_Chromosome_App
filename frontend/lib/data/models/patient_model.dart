import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String? id;
  final String? patientCode;
  final String fullName;
  final String identityCard;
  final DateTime dob;
  final String gender;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String status;

  PatientModel({
    this.id,
    this.patientCode,
    required this.fullName,
    this.identityCard = '',
    required this.dob,
    required this.gender,
    required this.phone,
    this.province = '',
    this.district = '',
    this.ward = '',
    this.address = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.status = 'active',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patient_code': patientCode ?? '',
      'full_name': fullName,
      'identity_card': identityCard,
      'dob': Timestamp.fromDate(dob),
      'gender': gender,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      id: doc.id,
      patientCode: data['patient_code'] ?? '',
      fullName: data['full_name'] ?? '',
      identityCard: data['identity_card'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      phone: data['phone'] ?? '',
      province: data['province'] ?? '',
      district: data['district'] ?? '',
      ward: data['ward'] ?? '',
      address: data['address'] ?? '',
      emergencyContactName: data['emergency_contact_name'] ?? '',
      emergencyContactPhone: data['emergency_contact_phone'] ?? '',
      status: data['status'] ?? 'active',
    );
  }
}
