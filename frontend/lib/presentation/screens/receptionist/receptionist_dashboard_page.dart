import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../logic/bloc/appointment/appointment_state.dart';
import '../../../domain/entities/appointment.dart';
import '../../widgets/receptionist/receptionist_sidebar.dart';
import '../../widgets/receptionist/receptionist_header.dart';
import '../../widgets/receptionist/today_appointments_table.dart';
import '../../widgets/dashboard/stat_card.dart';
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
          ReceptionistSidebar(
            activeIndex: _activeIndex,
            onItemTap: (i) => setState(() => _activeIndex = i),
          ),
          Expanded(
            child: Column(
              children: [
                ReceptionistHeader(
                  title: _headerConfigs[_activeIndex]['title']!,
                  subtitle: _headerConfigs[_activeIndex]['subtitle']!,
                  onAddPatient: _activeIndex <= 1
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
                          )
                      : null,
                ),
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
        return const _DashboardContent(key: ValueKey('dashboard'));
      case 1:
        return const PatientListPage(key: ValueKey('patients'));
      case 2:
        return const AppointmentCalendarPage(key: ValueKey('calendar'));
      default:
        return const _DashboardContent(key: ValueKey('dashboard'));
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardStatsRow(),
          SizedBox(height: 28),
          TodayAppointmentsTable(),
        ],
      ),
    );
  }
}

class _DashboardStatsRow extends StatelessWidget {
  const _DashboardStatsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        int total = 0, pending = 0, completed = 0;
        if (state is AppointmentLoaded) {
          total = state.allAppointments.length;
          pending = state.allAppointments.where((a) => a.status == AppointmentStatus.scheduled).length;
          completed = state.allAppointments.where((a) => a.status == AppointmentStatus.completed).length;
        }

        return Row(
          children: [
            _StatItem(
              title: 'Lịch hẹn hôm nay',
              value: total,
              icon: LucideIcons.calendarDays,
              color: AppColors.primaryBlue,
              bgColor: AppColors.activeBackground,
            ),
            const SizedBox(width: 20),
            _StatItem(
              title: 'Đang chờ tiếp nhận',
              value: pending,
              icon: LucideIcons.hourglass,
              color: AppColors.warningText,
              bgColor: AppColors.warningBg,
              isAlert: pending > 0,
            ),
            const SizedBox(width: 20),
            _StatItem(
              title: 'Đã hoàn tất hôm nay',
              value: completed,
              icon: LucideIcons.checkCircle,
              color: AppColors.successText,
              bgColor: AppColors.successBg,
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isAlert;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StatCard(
        title: title,
        value: value.toString().padLeft(2, '0'),
        trend: isAlert ? 'Cần xử lý ngay' : 'Tổng số hồ sơ',
        isPositive: !isAlert,
        icon: icon,
        iconColor: color,
        iconBgColor: bgColor,
      ),
    );
  }
}
