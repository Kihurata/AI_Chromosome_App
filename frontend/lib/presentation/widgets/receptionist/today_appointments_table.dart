import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/appointment.dart';
import '../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../logic/bloc/appointment/appointment_state.dart';
import '../shared/data_display/status_badge.dart';

class TodayAppointmentsTable extends StatefulWidget {
  const TodayAppointmentsTable({super.key});

  @override
  State<TodayAppointmentsTable> createState() => _TodayAppointmentsTableState();
}

class _TodayAppointmentsTableState extends State<TodayAppointmentsTable> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentCubit>().listenToTodayAppointments();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts.last[0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final int hash = name.hashCode;
    final List<Color> colors = [
      Colors.blue[100]!,
      Colors.purple[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.red[100]!,
      Colors.teal[100]!,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getTextColor(String name) {
    final int hash = name.hashCode;
    final List<Color> colors = [
      Colors.blue[900]!,
      Colors.purple[900]!,
      Colors.green[900]!,
      Colors.orange[900]!,
      Colors.red[900]!,
      Colors.teal[900]!,
    ];
    return colors[hash.abs() % colors.length];
  }

  BadgeType _mapStatus(String status) {
    switch (status) {
      case 'completed':
        return BadgeType.success;
      case 'scheduled':
        return BadgeType.warning;
      case 'in_progress':
        return BadgeType.processing;
      case 'urgent':
        return BadgeType.danger;
      default:
        return BadgeType.warning;
    }
  }

  String _mapStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn tất';
      case 'scheduled':
        return 'Đang chờ';
      case 'in_progress':
        return 'Đang khám';
      case 'urgent':
        return 'Khẩn cấp';
      default:
        return 'Đang chờ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lịch hẹn hôm nay',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, dd/MM/yyyy', 'vi').format(DateTime.now()),
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Xem tất cả', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                ),
              ],
            ),
          ),

          // Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 48), // Avatar space
                Expanded(flex: 4, child: Text('HỌ TÊN', style: _headerStyle)),
                Expanded(flex: 2, child: Text('GIỜ HẸN', style: _headerStyle)),
                Expanded(flex: 4, child: Text('LÝ DO KHÁM', style: _headerStyle)),
                Expanded(flex: 3, child: Text('BÁC SĨ', style: _headerStyle)),
                Expanded(flex: 2, child: Text('TRẠNG THÁI', style: _headerStyle)),
                SizedBox(width: 80, child: Text('THAO TÁC', style: _headerStyle, textAlign: TextAlign.center)),
              ],
            ),
          ),

          // Data Rows via BlocBuilder
          BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading || state is AppointmentInitial) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is AppointmentError) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text('Lỗi: ${state.message}', style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }

              if (state is AppointmentLoaded && state.appointments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.calendarX, size: 48, color: AppColors.textPlaceholder),
                        SizedBox(height: 16),
                        Text('Không có lịch hẹn nào cho hôm nay', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }

              final appointments = state is AppointmentLoaded ? state.appointments : <Appointment>[];
              return Column(
                children: List.generate(appointments.length, (index) {
                  final appt = appointments[index];
                  return _buildRow(
                    initials: _getInitials(appt.patientName),
                    avatarBg: _getAvatarColor(appt.patientName),
                    avatarText: _getTextColor(appt.patientName),
                    name: appt.patientName,
                    time: DateFormat('HH:mm').format(appt.appointmentDate),
                    reason: appt.reason,
                    doctor: appt.doctorName,
                    status: _mapStatus(appt.status),
                    statusText: _mapStatusText(appt.status),
                    isLast: index == appointments.length - 1,
                    onAccept: () => context.read<AppointmentCubit>().updateStatus(appt.id, 'in_progress'),
                  );
                }),
              );
            },
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, state) {
                final count = state is AppointmentLoaded ? state.appointments.length : 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hiển thị $count lịch hẹn cho hôm nay', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Row(
                      children: [
                        _paginationBtn('Trước', enabled: false),
                        const SizedBox(width: 8),
                        _activePage('1'),
                        const SizedBox(width: 8),
                        _paginationBtn('Tiếp', enabled: false),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  Widget _buildRow({
    required String initials,
    required Color avatarBg,
    required Color avatarText,
    required String name,
    required String time,
    required String reason,
    required String doctor,
    required BadgeType status,
    required String statusText,
    required VoidCallback onAccept,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarBg,
            child: Text(initials, style: TextStyle(color: avatarText, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            flex: 4,
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          ),
          // Time
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(time, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Reason
          Expanded(
            flex: 4,
            child: Text(reason, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          // Doctor
          Expanded(
            flex: 3,
            child: Text(doctor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
          // Status
          Expanded(
            flex: 2,
            child: StatusBadge(text: statusText, type: status),
          ),
          // Actions
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (statusText == 'Đang chờ')
                  SizedBox(
                    height: 32,
                    child: TextButton(
                      onPressed: onAccept,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Tiếp nhận', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paginationBtn(String text, {bool enabled = true}) {
    return OutlinedButton(
      onPressed: enabled ? () {} : null,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(0, 36),
      ),
      child: Text(text, style: TextStyle(color: enabled ? AppColors.textSecondary : AppColors.textPlaceholder, fontSize: 13)),
    );
  }

  Widget _activePage(String text) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
