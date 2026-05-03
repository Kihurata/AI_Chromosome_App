import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/appointment.dart';
import '../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../logic/bloc/appointment/appointment_state.dart';
import '../../widgets/shared/data_display/status_badge.dart';
import '../../widgets/shared/data_display/app_data_table.dart';
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
            SizedBox(
              height: 500, // Fixed height for the table container
              child: BlocBuilder<AppointmentCubit, AppointmentState>(
                builder: (context, state) {
                  if (state is AppointmentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final appointments = state is RangeAppointmentsLoaded
                      ? state.appointments
                      : <Appointment>[];

                  return AppDataTable(
                    searchHint: 'Tìm bệnh nhân...',
                    countText: '${appointments.length} lịch hẹn',
                    onSearchChanged: (v) {
                      // Internal search could be implemented here if needed
                    },
                    headerRow: const _AppointmentTableHeader(),
                    isLoading: state is AppointmentLoading,
                    emptyState: _EmptyAppointments(selectedDay: _selectedDay),
                    rows: appointments.map((appt) => _AppointmentRow(
                      appointment: appt,
                      onView: () {
                        // Navigate to EMR
                        context.push('/clinician/medical-record/${appt.patientId}');
                      },
                    )).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTableHeader extends StatelessWidget {
  const _AppointmentTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
    return const Row(
      children: [
        Expanded(flex: 1, child: Text('GIỜ', style: style)),
        Expanded(flex: 3, child: Text('BỆNH NHÂN', style: style)),
        Expanded(flex: 3, child: Text('BÁC SĨ', style: style)),
        Expanded(flex: 2, child: Text('TRẠNG THÁI', style: style)),
        Expanded(flex: 1, child: Text('THAO TÁC', style: style, textAlign: TextAlign.center)),
      ],
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onView;

  const _AppointmentRow({required this.appointment, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              DateFormat('HH:mm').format(appointment.appointmentDate),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Text(appointment.doctorName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(
              text: _mapStatusText(appointment.status),
              type: _mapStatusType(appointment.status),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: onView,
              icon: const Icon(LucideIcons.eye, size: 18, color: AppColors.primaryBlue),
              tooltip: 'Xem bệnh án',
            ),
          ),
        ],
      ),
    );
  }

  String _mapStatusText(AppointmentStatus status) {
    return status.displayName;
  }

  BadgeType _mapStatusType(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed: return BadgeType.success;
      case AppointmentStatus.inProgress: return BadgeType.processing;
      case AppointmentStatus.cancelled: return BadgeType.danger;
      case AppointmentStatus.scheduled: return BadgeType.warning;
    }
  }
}

class _EmptyAppointments extends StatelessWidget {
  final DateTime selectedDay;
  const _EmptyAppointments({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(LucideIcons.calendarX, size: 44, color: AppColors.textPlaceholder.withAlpha(120)),
          const SizedBox(height: 14),
          const Text('Không có lịch hẹn', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd/MM/yyyy').format(selectedDay),
            style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
