import 'package:cloud_firestore/cloud_firestore.dart';

class IcdCodeModel {
  final String code;
  final String name;

  IcdCodeModel({
    required this.code,
    required this.name,
  });

  factory IcdCodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return IcdCodeModel(
      code: data?['code'] ?? '',
      name: data?['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
    };
  }
}
