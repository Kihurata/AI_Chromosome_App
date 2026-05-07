import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:medcore_crm/core/theme/app_colors.dart';
import 'package:medcore_crm/core/providers/auth_provider.dart';
import 'package:medcore_crm/core/models/nav_item.dart';
import 'package:medcore_crm/presentation/widgets/shared/layouts/medical_record_layout.dart';
import 'package:medcore_crm/presentation/widgets/shared/form/app_buttons.dart';
import 'package:medcore_crm/presentation/screens/patient_detail/medical_record/tabs/patient_info_tab.dart';
import 'package:medcore_crm/presentation/screens/patient_detail/medical_record/tabs/history_tab.dart';
import 'package:medcore_crm/presentation/screens/patient_detail/medical_record/tabs/test_results_tab.dart';
import 'package:medcore_crm/logic/bloc/patient/patient_cubit.dart';
import 'package:medcore_crm/logic/bloc/patient/patient_state.dart';
import 'package:medcore_crm/domain/entities/patient.dart';

class SharedMedicalRecordPage extends ConsumerStatefulWidget {
  final String id; // patientId
  final String? appointmentId;
  const SharedMedicalRecordPage({super.key, required this.id, this.appointmentId});

  @override
  ConsumerState<SharedMedicalRecordPage> createState() => _SharedMedicalRecordPageState();
}

class _SharedMedicalRecordPageState extends ConsumerState<SharedMedicalRecordPage> {
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientCubit>().getPatientById(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authNotifierProvider).role;
    final isClinician = role == AppRole.clinician || role == AppRole.specialist;

    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        if (state is PatientLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is PatientError) {
          return Scaffold(
            body: Center(child: Text('Lỗi: ${state.message}')),
          );
        }

        if (state is PatientDetailLoaded) {
          final patient = state.patient;

          return MedicalRecordLayout(
            title: 'Bệnh án Điện tử',
            headerAction: isClinician ? AppPrimaryButton(
              onPressed: () {
                // Ưu tiên dùng appointmentId nếu có, nếu không thì dùng patientId (nhưng form cần appointmentId)
                final idToPass = widget.appointmentId ?? widget.id;
                context.push('/clinician/examination-form/$idToPass');
              },
              icon: LucideIcons.stethoscope,
              text: 'Lập Phiếu Khám bệnh',
            ) : null,
            breadcrumbText: patient.fullName,
            onBreadcrumbTap: () => context.go('/clinician/appointments'),
            profileSection: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.user, color: AppColors.textSecondary, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.fingerprint, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(patient.patientCode ?? 'Chưa có mã', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(patient.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                )
              ],
            ),
            tabTitles: const ['Thông tin Chi tiết', 'Lịch sử Khám bệnh', 'Kết quả Xét nghiệm'],
            activeTabIndex: _activeTabIndex,
            onTabChanged: (index) {
              setState(() {
                _activeTabIndex = index;
              });
            },
            tabBody: _buildTabBody(patient),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Không tìm thấy dữ liệu bệnh nhân')),
        );
      },
    );
  }

  Widget _buildTabBody(Patient patient) {
    if (_activeTabIndex == 0) {
      return PatientInfoTab(patient: patient);
    } else if (_activeTabIndex == 1) {
      return HistoryTab(patientId: patient.id ?? '');
    } else {
      return TestResultsTab(patientId: patient.id ?? '');
    }
  }
}

