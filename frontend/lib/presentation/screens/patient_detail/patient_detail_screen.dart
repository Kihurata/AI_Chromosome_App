import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/patient_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/nav_item.dart';
import './medical_record/shared_medical_record_page.dart';


class PatientDetailScreen extends ConsumerWidget {
  final PatientModel patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authNotifierProvider).role;

    // FACTORY METHOD logic
    switch (role) {
      case AppRole.clinician:
      case AppRole.specialist:
      case AppRole.receptionist:
      case AppRole.manager:
        return SharedMedicalRecordPage(id: patient.id ?? '');
      default:
        // Unauthorized fallback
        return Scaffold(
          body: Center(
            child: Text('Không có quyền truy cập hồ sơ này!'),
          ),
        );
    }
  }
}
