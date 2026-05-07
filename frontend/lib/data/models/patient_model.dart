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
      'patient_code': patientCode,
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
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Xử lý dob an toàn: chấp nhận Timestamp hoặc String (nếu có dữ liệu cũ)
    DateTime parsedDob;
    try {
      final dobData = data['dob'];
      if (dobData is Timestamp) {
        parsedDob = dobData.toDate();
      } else if (dobData is String) {
        parsedDob = DateTime.tryParse(dobData) ?? DateTime(1900);
      } else {
        parsedDob = DateTime(1900);
      }
    } catch (_) {
      parsedDob = DateTime(1900);
    }

    return PatientModel(
      id: doc.id,
      patientCode: data['patient_code'] ?? data['patientCode'] ?? '',
      fullName: data['full_name'] ?? data['fullName'] ?? '',
      identityCard: data['identity_card'] ?? data['identityCard'] ?? '',
      dob: parsedDob,
      gender: data['gender'] ?? '',
      phone: data['phone'] ?? '',
      province: data['province'] ?? '',
      district: data['district'] ?? '',
      ward: data['ward'] ?? '',
      address: data['address'] ?? '',
      emergencyContactName: data['emergency_contact_name'] ?? data['emergencyContactName'] ?? '',
      emergencyContactPhone: data['emergency_contact_phone'] ?? data['emergencyContactPhone'] ?? '',
      status: data['status'] ?? 'active',
    );
  }

  factory PatientModel.fromEntity(Patient patient) {
    return PatientModel(
      id: patient.id,
      patientCode: patient.patientCode,
      fullName: patient.fullName,
      identityCard: patient.identityCard,
      dob: patient.dob,
      gender: patient.gender,
      phone: patient.phone,
      province: patient.province,
      district: patient.district,
      ward: patient.ward,
      address: patient.address,
      emergencyContactName: patient.emergencyContactName,
      emergencyContactPhone: patient.emergencyContactPhone,
      status: patient.status,
    );
  }
}
