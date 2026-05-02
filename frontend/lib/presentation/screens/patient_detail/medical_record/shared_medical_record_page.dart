import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:medcore_crm/core/theme/app_colors.dart';
import 'package:medcore_crm/core/providers/auth_provider.dart';
import 'package:medcore_crm/core/models/nav_item.dart';
import 'package:medcore_crm/presentation/widgets/shared/layouts/medical_record_layout.dart';
import 'package:medcore_crm/presentation/screens/patient_detail/medical_record/tabs/patient_info_tab.dart';
import 'package:medcore_crm/presentation/screens/patient_detail/medical_record/tabs/history_tab.dart';
import 'package:medcore_crm/presentation/screens/patient_detail/medical_record/tabs/test_results_tab.dart';



class SharedMedicalRecordPage extends ConsumerStatefulWidget {
  final String id;
  const SharedMedicalRecordPage({super.key, required this.id});

  @override
  ConsumerState<SharedMedicalRecordPage> createState() => _SharedMedicalRecordPageState();
}

class _SharedMedicalRecordPageState extends ConsumerState<SharedMedicalRecordPage> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authNotifierProvider).role;
    final isClinician = role == AppRole.clinician || role == AppRole.specialist;

    return MedicalRecordLayout(
      title: 'Bệnh án Điện tử',
      headerAction: isClinician ? ElevatedButton.icon(
        onPressed: () {
          context.push('/clinician/examination-form/${widget.id}');
        },
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Lập Phiếu Khám bệnh'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ) : null,
      breadcrumbText: 'Johnathan Doe',
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
            // Placeholder for avatar
            child: const Icon(LucideIcons.user, color: AppColors.textSecondary, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Johnathan Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(LucideIcons.mail, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text('j.doe@hospital.com', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: const [
                  Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text('+1 (555) 234-5678', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
      tabBody: _buildTabBody(),
    );
  }

  Widget _buildTabBody() {
    if (_activeTabIndex == 0) {
      return const PatientInfoTab();
    } else if (_activeTabIndex == 1) {
      return const HistoryTab();
    } else {
      return const TestResultsTab();
    }
  }


}
