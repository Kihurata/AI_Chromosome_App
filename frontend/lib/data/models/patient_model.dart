import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    super.id,
    super.patientCode,
    required super.fullName,
    super.identityCard = '',
    required super.dob,
    required super.gender,
    required super.phone,
    super.province = '',
    super.district = '',
    super.ward = '',
    super.address = '',
    super.emergencyContactName = '',
    super.emergencyContactPhone = '',
    super.status = 'active',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patientCode': patientCode,
      'fullName': fullName,
      'identityCard': identityCard,
      'dob': Timestamp.fromDate(dob),
      'gender': gender,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'address': address,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
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
