import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/test_order.dart';
import '../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../logic/bloc/appointment/appointment_state.dart';
import '../../../logic/bloc/clinician/clinician_order_cubit.dart';
import '../../../logic/bloc/clinician/clinician_order_state.dart';
import '../shared/data_display/status_badge.dart';
import '../shared/form/app_buttons.dart';

class RecentPatientsTable extends StatefulWidget {
  const RecentPatientsTable({super.key});

  @override
  State<RecentPatientsTable> createState() => _RecentPatientsTableState();
}

class _RecentPatientsTableState extends State<RecentPatientsTable> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentCubit>().listenToTodayAppointments();
    context.read<ClinicianOrderCubit>().loadTestOrders();
  }

  BadgeType _mapAppointmentStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return BadgeType.success;
      case AppointmentStatus.inProgress:
        return BadgeType.processing;
      case AppointmentStatus.cancelled:
        return BadgeType.danger;
      case AppointmentStatus.scheduled:
        return BadgeType.warning;
    }
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

  Color _getAvatarTextColor(String name) {
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
          // Table Header Title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoạt động bệnh nhân gần đây',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cập nhật thời gian thực về quy trình khám bệnh',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Xem tất cả', style: TextStyle(color: AppColors.primaryBlue)),
                )
              ],
            ),
          ),

          // Table Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('BỆNH NHÂN', style: _headerStyle)),
                Expanded(flex: 3, child: Text('LÝ DO KHÁM', style: _headerStyle)),
                Expanded(flex: 2, child: Text('TRẠNG THÁI', style: _headerStyle)),
                Expanded(flex: 2, child: Text('KQXN', style: _headerStyle)),
                Expanded(flex: 2, child: Text('THỜI GIAN', style: _headerStyle)),
                Expanded(flex: 2, child: Text('THAO TÁC', style: _headerStyle, textAlign: TextAlign.center)),
              ],
            ),
          ),

          // Table Data Rows via BlocBuilder
          BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading || state is AppointmentInitial) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is AppointmentError) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(child: Text('Lỗi: ${state.message}', style: const TextStyle(color: AppColors.dangerText))),
                );
              }

              final appointments = state is AppointmentLoaded ? state.filteredAppointments : <Appointment>[];

              if (appointments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(60.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.calendarX, size: 48, color: AppColors.textPlaceholder),
                        SizedBox(height: 16),
                        Text('Không có hoạt động nào phù hợp', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(appointments.length, (index) {
                  final appt = appointments[index];
                  return _buildRow(
                    appt: appt,
                    isLast: index == appointments.length - 1,
                  );
                }),
              );
            },
          ),

          // Pagination Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, state) {
                final count = state is AppointmentLoaded ? state.filteredAppointments.length : 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hiển thị $count cập nhật phù hợp', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Row(
                      children: [
                        AppSecondaryButton(
                          text: 'Trước',
                          onPressed: null,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36, height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
                          child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        AppSecondaryButton(
                          text: 'Tiếp',
                          onPressed: null,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          )
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

  Widget _buildRow({required Appointment appt, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Tên bệnh nhân
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getAvatarColor(appt.patientName),
                  child: Text(
                    _getInitials(appt.patientName),
                    style: TextStyle(color: _getAvatarTextColor(appt.patientName), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appt.patientName,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Lý do khám
          Expanded(
            flex: 3,
            child: Text(
              appt.reason,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Cột Trạng thái (Appointment)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                text: appt.status.displayName,
                type: _mapAppointmentStatus(appt.status),
              ),
            ),
          ),
          // Cột KQXN (Test Order)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _KqxnBadge(appointmentId: appt.id),
            ),
          ),
          // Thời gian
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('HH:mm').format(appt.appointmentDate),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          // Thao tác
          Expanded(
            flex: 2,
            child: appt.status == AppointmentStatus.scheduled
                ? AppPrimaryButton(
                    text: 'Khám bệnh',
                    icon: LucideIcons.stethoscope,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onPressed: () {
                      context.read<AppointmentCubit>().startExamination(appt.id);
                      context.push('/clinician/medical-record/${appt.patientId}?appointmentId=${appt.id}');
                    },
                  )
                : AppSecondaryButton(
                    text: 'Chi tiết',
                    icon: LucideIcons.eye,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onPressed: () => context.push('/clinician/medical-record/${appt.patientId}?appointmentId=${appt.id}'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KqxnBadge extends StatelessWidget {
  final String appointmentId;
  const _KqxnBadge({required this.appointmentId});

  BadgeType _mapTestOrderStatus(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.completed:
        return BadgeType.success;
      case TestOrderStatus.culturing:
      case TestOrderStatus.analyzing:
      case TestOrderStatus.waitingApproval:
        return BadgeType.processing;
      case TestOrderStatus.rejected:
        return BadgeType.danger;
      case TestOrderStatus.pending:
        return BadgeType.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicianOrderCubit, ClinicianOrderState>(
      builder: (context, state) {
        if (state is TestOrdersLoaded) {
          final orders = state.allOrders.where((o) => o.appointmentId == appointmentId).toList();
          if (orders.isEmpty) {
            return const Text(
              '—',
              style: TextStyle(color: AppColors.textPlaceholder, fontSize: 13),
            );
          }
          // Lấy order mới nhất
          final latest = orders.first;
          return StatusBadge(
            text: latest.status.displayName,
            type: _mapTestOrderStatus(latest.status),
          );
        }
        return const Text(
          '—',
          style: TextStyle(color: AppColors.textPlaceholder, fontSize: 13),
        );
      },
    );
  }
}
