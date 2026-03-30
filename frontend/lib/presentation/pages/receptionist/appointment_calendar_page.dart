import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/clinical_repository.dart';
import '../../widgets/shared/status_badge.dart';

class AppointmentCalendarPage extends StatefulWidget {
  final ClinicalRepository? repository;
  const AppointmentCalendarPage({super.key, this.repository});

  @override
  State<AppointmentCalendarPage> createState() => _AppointmentCalendarPageState();
}

class _AppointmentCalendarPageState extends State<AppointmentCalendarPage> {
  late final ClinicalRepository _clinicalRepo;

  @override
  void initState() {
    super.initState();
    _clinicalRepo = widget.repository ?? ClinicalRepository();
  }
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // For new appointment dialog
  final _reasonController = TextEditingController();
  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _selectedDoctorUid;
  String? _selectedDoctorName;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                // Title + Add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.calendarDays, size: 20, color: AppColors.primaryBlue),
                        SizedBox(width: 10),
                        Text('Lịch hẹn khám', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showNewAppointmentDialog(context),
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text('Tạo lịch hẹn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
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
                      decoration: BoxDecoration(
                        color: AppColors.activeBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
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

                // Appointments for selected day
                StreamBuilder<QuerySnapshot>(
                  stream: _clinicalRepo.getAppointmentsInRange(
                    DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day),
                    DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 23, 59, 59),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

                    final docs = snapshot.data!.docs;
                    return Column(
                      children: [
                        // Count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.border.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.clipboardList, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '${docs.length} lịch hẹn',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // List
                        ...docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final time = (data['appointment_date'] as Timestamp).toDate();
                          final status = data['status'] ?? 'scheduled';
                          return _buildAppointmentCard(
                            patientName: data['patient_name'] ?? '',
                            doctorName: data['doctor_name'] ?? '',
                            time: DateFormat('HH:mm').format(time),
                            reason: data['reason'] ?? '',
                            status: status,
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
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
              StatusBadge(
                text: _mapStatusText(status),
                type: _mapStatusType(status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(patientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(LucideIcons.stethoscope, size: 12, color: AppColors.textPlaceholder),
              const SizedBox(width: 4),
              Expanded(
                child: Text(doctorName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
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

  // ── New Appointment Dialog ──
  void _showNewAppointmentDialog(BuildContext context) {
    _reasonController.clear();
    _selectedPatientId = null;
    _selectedPatientName = null;
    _selectedDoctorUid = null;
    _selectedDoctorName = null;
    _selectedTime = const TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppColors.activeBackground, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(LucideIcons.calendarPlus, color: AppColors.primaryBlue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text('Tạo lịch hẹn mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Patient search (simple - auto-complete from Firestore)
                  const Text('Bệnh nhân *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  _buildPatientDropdown(setDialogState),
                  const SizedBox(height: 16),

                  // Doctor dropdown
                  const Text('Bác sĩ phụ trách *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _clinicalRepo.getClinicians(),
                    builder: (context, snapshot) {
                      final doctors = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        value: _selectedDoctorUid,
                        decoration: _dialogInputDecoration('Chọn bác sĩ...'),
                        isExpanded: true,
                        items: doctors.map((d) => DropdownMenuItem(
                          value: d['uid'] as String,
                          child: Text('${d['full_name']} (${d['role']})', style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: (v) {
                          final doc = doctors.firstWhere((d) => d['uid'] == v);
                          setDialogState(() {
                            _selectedDoctorUid = v;
                            _selectedDoctorName = doc['full_name'] as String;
                          });
                        },
                        dropdownColor: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time + Reason
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Giờ hẹn *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final t = await showTimePicker(context: ctx, initialTime: _selectedTime);
                                if (t != null) setDialogState(() => _selectedTime = t);
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.border.withAlpha(35),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.clock, size: 14, color: AppColors.textPlaceholder),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Reason
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lý do khám *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _reasonController,
                              maxLines: 1,
                              decoration: _dialogInputDecoration('Mô tả ngắn gọn...'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Huỷ', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _submitAppointment(ctx),
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientDropdown(StateSetter setDialogState) {
    return StreamBuilder<List<PatientModel>>(
      stream: _clinicalRepo.getAllPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        
        final patients = snapshot.data ?? [];
        return DropdownMenu<String>(
          width: 444, // Dialog width minus padding 28*2
          hintText: 'Tìm theo tên hoặc CCCD...',
          enableFilter: true,
          enableSearch: true,
          textStyle: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.border.withAlpha(35),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
          ),
          onSelected: (val) {
             if (val != null) {
               final p = patients.firstWhere((e) => e.id == val);
               setDialogState(() {
                 _selectedPatientId = p.id;
                 _selectedPatientName = p.fullName;
               });
             }
          },
          dropdownMenuEntries: patients.map((p) {
            final card = p.identityCard.isNotEmpty ? p.identityCard : 'Không có';
            final label = '${p.fullName} (${p.patientCode}) - CCCD: $card';
            return DropdownMenuEntry<String>(
              value: p.id ?? '',
              label: label,
              style: MenuItemButton.styleFrom(
                textStyle: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        );
      }
    );
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
      filled: true,
      fillColor: AppColors.border.withAlpha(35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
    );
  }

  Future<void> _submitAppointment(BuildContext dialogContext) async {
    if (_selectedPatientId == null || _selectedDoctorUid == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: AppColors.warningText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    final appointmentDate = DateTime(
      _selectedDay.year, _selectedDay.month, _selectedDay.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    final db = FirebaseFirestore.instance;
    final appointment = AppointmentModel(
      id: '',
      patientId: db.doc('patients/$_selectedPatientId'),
      patientName: _selectedPatientName ?? '',
      doctorId: db.doc('doctors/$_selectedDoctorUid'),
      doctorName: _selectedDoctorName ?? '',
      appointmentDate: appointmentDate,
      reason: _reasonController.text.trim(),
      status: 'scheduled',
    );

    await _clinicalRepo.createAppointment(appointment);

    if (mounted) {
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Đã tạo lịch hẹn thành công!'),
            ],
          ),
          backgroundColor: AppColors.successText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }
}
