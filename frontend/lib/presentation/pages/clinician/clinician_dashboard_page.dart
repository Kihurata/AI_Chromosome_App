import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/clinician/clinician_sidebar.dart';
import '../../widgets/clinician/clinician_header.dart';
import 'clinician_appointments_page.dart';

class ClinicianDashboardPage extends StatefulWidget {
  const ClinicianDashboardPage({super.key});

  @override
  State<ClinicianDashboardPage> createState() => _ClinicianDashboardPageState();
}

class _ClinicianDashboardPageState extends State<ClinicianDashboardPage> {
  int _activeIndex = 0;

  static const _headerConfigs = [
    {'title': 'Lịch hẹn', 'subtitle': 'Quản lý lịch khám của bạn hôm nay'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          ClinicianSidebar(
            activeIndex: _activeIndex,
            onItemTap: (i) => setState(() => _activeIndex = i),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Dynamic Header
                ClinicianHeader(
                  title: _headerConfigs[_activeIndex]['title']!,
                  subtitle: _headerConfigs[_activeIndex]['subtitle']!,
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
        return const ClinicianAppointmentsPage(key: ValueKey('clinician_appointments'));
      default:
        return const ClinicianAppointmentsPage(key: ValueKey('clinician_appointments'));
    }
  }
}
