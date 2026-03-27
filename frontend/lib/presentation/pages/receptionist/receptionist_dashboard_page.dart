import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/receptionist/receptionist_sidebar.dart';
import '../../widgets/receptionist/receptionist_header.dart';
import '../../widgets/receptionist/today_appointments_table.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../../data/repositories/clinical_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_registration_page.dart';

class ReceptionistDashboardPage extends StatefulWidget {
  const ReceptionistDashboardPage({super.key});

  @override
  State<ReceptionistDashboardPage> createState() => _ReceptionistDashboardPageState();
}

class _ReceptionistDashboardPageState extends State<ReceptionistDashboardPage> {
  int _activeIndex = 0;
  final ClinicalRepository _clinicalRepo = ClinicalRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          ReceptionistSidebar(
            activeIndex: _activeIndex,
            onItemTap: (i) => setState(() => _activeIndex = i),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                ReceptionistHeader(
                  onAddPatient: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
                  ),
                ),
                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat Cards
                        StreamBuilder<QuerySnapshot>(
                          stream: _clinicalRepo.getTodayAppointments(),
                          builder: (context, snapshot) {
                            final total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                            final pending = snapshot.hasData 
                                ? snapshot.data!.docs.where((d) => d['status'] == 'scheduled').length 
                                : 0;
                            final completed = snapshot.hasData 
                                ? snapshot.data!.docs.where((d) => d['status'] == 'completed').length 
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
                          }
                        ),
                        const SizedBox(height: 28),
                        // Appointments Table
                        TodayAppointmentsTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
