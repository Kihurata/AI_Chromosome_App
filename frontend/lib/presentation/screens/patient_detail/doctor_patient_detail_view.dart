import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../data/models/patient_model.dart';
import '../../../../core/theme/app_colors.dart';

class DoctorPatientDetailView extends StatelessWidget {
  final PatientModel patient;

  const DoctorPatientDetailView({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kê đơn & Chỉ định - ${patient.fullName}'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.stethoscope, size: 64, color: AppColors.primaryBlue),
            const SizedBox(height: 16),
            const Text(
              'Giao diện dành riêng cho Bác Sĩ (Placeholder)',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Bệnh nhân: ${patient.fullName}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
