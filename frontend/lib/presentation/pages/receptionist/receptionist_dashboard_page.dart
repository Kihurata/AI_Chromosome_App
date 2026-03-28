import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/receptionist/receptionist_sidebar.dart';
import '../../widgets/receptionist/receptionist_header.dart';
import '../../widgets/receptionist/today_appointments_table.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../../data/repositories/clinical_repository.dart';
import 'patient_registration_page.dart';
import 'patient_list_page.dart';
import 'appointment_calendar_page.dart';

class ReceptionistDashboardPage extends StatefulWidget {
  const ReceptionistDashboardPage({super.key});

  @override
  State<ReceptionistDashboardPage> createState() => _ReceptionistDashboardPageState();
}

class _ReceptionistDashboardPageState extends State<ReceptionistDashboardPage> {
  int _activeIndex = 0;
  final ClinicalRepository _clinicalRepo = ClinicalRepository();

  static const _headerConfigs = [
    {'title': 'Tổng quan', 'subtitle': 'Theo dõi hoạt động tiếp nhận hôm nay'},
    {'title': 'Bệnh nhân', 'subtitle': 'Quản lý hồ sơ và thông tin bệnh nhân'},
    {'title': 'Lịch khám', 'subtitle': 'Quản lý lịch hẹn và phân công bác sĩ'},
  ];

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
                // Dynamic Header
                ReceptionistHeader(
                  title: _headerConfigs[_activeIndex]['title']!,
                  subtitle: _headerConfigs[_activeIndex]['subtitle']!,
                  onAddPatient: _activeIndex <= 1
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
                          )
                      : null,
                ),
                // Page Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_activeIndex) {
      case 0:
        return _DashboardContent(key: const ValueKey('dashboard'), clinicalRepo: _clinicalRepo);
      case 1:
        return const PatientListPage(key: ValueKey('patients'));
      case 2:
        return const AppointmentCalendarPage(key: ValueKey('calendar'));
      default:
        return _DashboardContent(key: const ValueKey('dashboard'), clinicalRepo: _clinicalRepo);
    }
  }
}

/// Dashboard overview content (extracted from old ReceptionistDashboardPage)
class _DashboardContent extends StatelessWidget {
  final ClinicalRepository clinicalRepo;

  const _DashboardContent({super.key, required this.clinicalRepo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Cards
          StreamBuilder<QuerySnapshot>(
            stream: clinicalRepo.getTodayAppointments(),
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
            },
          ),
          const SizedBox(height: 28),
          // Appointments Table
          TodayAppointmentsTable(),
        ],
      ),
    );
  }
}
