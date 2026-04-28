import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/appointment.dart';
import '../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../logic/bloc/appointment/appointment_state.dart';
import '../../widgets/shared/data_display/status_badge.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/shared/form/app_buttons.dart';
import 'create_appointment_page.dart';

class AppointmentCalendarPage extends StatefulWidget {
  const AppointmentCalendarPage({super.key});

  @override
  State<AppointmentCalendarPage> createState() => _AppointmentCalendarPageState();
}

class _AppointmentCalendarPageState extends State<AppointmentCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchForDay(_selectedDay);
  }

  void _fetchForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    context.read<AppointmentCubit>().fetchAppointmentsInRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return MainListLayout(
      title: 'Lịch khám',
      subtitle: 'Xem và quản lý lịch hẹn khám',
      headerActions: [
        AppPrimaryButton(
          text: 'Tạo lịch hẹn',
          icon: LucideIcons.plus,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateAppointmentPage(initialDate: _selectedDay),
            ),
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top: Calendar ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.calendarDays, size: 20, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Text(
                        'Lịch tổng hợp',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 8),

                  // Calendar Widget
                  TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    locale: 'vi_VN',
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _fetchForDay(selectedDay);
                    },
                    onFormatChanged: (format) => setState(() => _calendarFormat = format),
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                      selectedDecoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                      selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      weekendTextStyle: const TextStyle(color: AppColors.dangerText),
                      defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                      cellMargin: const EdgeInsets.all(4),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      formatButtonTextStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      leftChevronIcon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.border.withAlpha(60), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.textSecondary),
                      ),
                      rightChevronIcon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.border.withAlpha(60), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      weekendStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dangerText),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Bottom: Selected Day Appointments ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.activeBackground, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          DateFormat('dd/MM').format(_selectedDay),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE', 'vi').format(_selectedDay),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),

                  // Appointments list via BlocBuilder
                  BlocBuilder<AppointmentCubit, AppointmentState>(
                    builder: (context, state) {
                      if (state is AppointmentLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final appointments = state is RangeAppointmentsLoaded
                          ? state.appointments
                          : <Appointment>[];

                      if (appointments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(LucideIcons.calendarX, size: 44, color: AppColors.textPlaceholder.withAlpha(120)),
                                const SizedBox(height: 14),
                                const Text('Không có lịch hẹn', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedDay),
                                  style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Count
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: AppColors.border.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.clipboardList, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  '${appointments.length} lịch hẹn',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // List
                          ...appointments.map((appt) => _buildAppointmentCard(
                                patientName: appt.patientName,
                                doctorName: appt.doctorName,
                                time: DateFormat('HH:mm').format(appt.appointmentDate),
                                reason: appt.reason,
                                status: appt.status,
                              )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String patientName,
    required String doctorName,
    required String time,
    required String reason,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.clock, size: 12, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ],
                ),
              ),
              const Spacer(),
              StatusBadge(text: _mapStatusText(status), type: _mapStatusType(status)),
            ],
          ),
          const SizedBox(height: 10),
          Text(patientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(LucideIcons.stethoscope, size: 12, color: AppColors.textPlaceholder),
              const SizedBox(width: 4),
              Expanded(child: Text(doctorName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(reason, style: const TextStyle(fontSize: 12, color: AppColors.textPlaceholder), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  String _mapStatusText(String status) {
    switch (status) {
      case 'completed': return 'Hoàn tất';
      case 'scheduled': return 'Đang chờ';
      case 'in_progress': return 'Đang khám';
      case 'cancelled': return 'Đã huỷ';
      default: return 'Đang chờ';
    }
  }

  BadgeType _mapStatusType(String status) {
    switch (status) {
      case 'completed': return BadgeType.success;
      case 'scheduled': return BadgeType.warning;
      case 'in_progress': return BadgeType.processing;
      case 'cancelled': return BadgeType.danger;
      default: return BadgeType.warning;
    }
  }
}
