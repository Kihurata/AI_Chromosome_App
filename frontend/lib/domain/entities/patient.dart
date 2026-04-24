import 'package:equatable/equatable.dart';

class Patient extends Equatable {
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

  const Patient({
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

  @override
  List<Object?> get props => [
    id,
    patientCode,
    fullName,
    identityCard,
    dob,
    gender,
    phone,
    province,
    district,
    ward,
    address,
    emergencyContactName,
    emergencyContactPhone,
    status,
  ];
}
