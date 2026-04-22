import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/clinical_repository.dart';
import '../../widgets/receptionist/today_appointments_table.dart';
import '../../widgets/dashboard/stat_card.dart';
import 'patient_registration_page.dart';

/// Slim receptionist dashboard — no sidebar/header (handled by AppNavigationWrapper).
class ReceptionistDashboardBody extends StatelessWidget {
  final ClinicalRepository? repository;
  const ReceptionistDashboardBody({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final clinicalRepo = repository ?? ClinicalRepository();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tổng quan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Theo dõi hoạt động tiếp nhận hôm nay',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick action
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PatientRegistrationPage(),
                  ),
                ),
                icon: const Icon(LucideIcons.userPlus, size: 16),
                label: const Text('Thêm bệnh nhân'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stat Cards
          StreamBuilder<QuerySnapshot>(
            stream: clinicalRepo.getTodayAppointments(),
            builder: (context, snapshot) {
              final total =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;
              final pending = snapshot.hasData
                  ? snapshot.data!.docs
                      .where((d) => d['status'] == 'scheduled')
                      .length
                  : 0;
              final completed = snapshot.hasData
                  ? snapshot.data!.docs
                      .where((d) => d['status'] == 'completed')
                      .length
                  : 0;

              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Lịch hẹn hôm nay',
                      value: total.toString().padLeft(2, '0'),
                      trend: 'Tổng số hồ sơ',
                      isPositive: true,
                      icon: LucideIcons.calendarDays,
                      iconColor: AppColors.primaryBlue,
                      iconBgColor: AppColors.activeBackground,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      title: 'Đang chờ tiếp nhận',
                      value: pending.toString().padLeft(2, '0'),
                      trend: 'Cần xử lý ngay',
                      isPositive: pending > 0 ? false : true,
                      icon: LucideIcons.hourglass,
                      iconColor: AppColors.warningText,
                      iconBgColor: AppColors.warningBg,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      title: 'Đã hoàn tất hôm nay',
                      value: completed.toString().padLeft(2, '0'),
                      trend: 'Đã xong quy trình',
                      isPositive: true,
                      icon: LucideIcons.checkCircle,
                      iconColor: AppColors.successText,
                      iconBgColor: AppColors.successBg,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Appointments Table
          TodayAppointmentsTable(repository: clinicalRepo),
        ],
      ),
    );
  }
}

