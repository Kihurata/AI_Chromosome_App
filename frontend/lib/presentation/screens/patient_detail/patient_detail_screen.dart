import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/patient_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/nav_item.dart';
import 'receptionist_patient_detail_view.dart';
import 'doctor_patient_detail_view.dart';


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
        return DoctorPatientDetailView(patient: patient);
      case AppRole.receptionist:
        return ReceptionistPatientDetailView(patient: patient);
      case AppRole.manager:
        // Or create a manager view if needed, right now defaulting to Receptionist view
        return ReceptionistPatientDetailView(patient: patient);
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
