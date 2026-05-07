import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/appointment.dart';
import '../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../logic/bloc/appointment/appointment_state.dart';
import '../../../logic/bloc/patient/patient_cubit.dart';
import '../../../logic/bloc/patient/patient_state.dart';

import '../../widgets/shared/layouts/main_form_layout.dart';
import '../../widgets/shared/form/app_text_field.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../widgets/shared/form/app_dropdown.dart';

class CreateAppointmentPage extends StatefulWidget {
  /// Pre-fill with a specific date (e.g. from Calendar page)
  final DateTime? initialDate;

  const CreateAppointmentPage({
    super.key,
    this.initialDate,
  });

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  // Form state
  final _reasonController = TextEditingController();
  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _selectedDoctorUid;
  String? _selectedDoctorName;
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    // Fetch patients and clinicians for dropdowns
    context.read<PatientCubit>().fetchPatients();
    context.read<AppointmentCubit>().fetchClinicians();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MainFormLayout(
        title: 'Tạo lịch hẹn mới',
        subtitle: 'Lên lịch hẹn khám cho bệnh nhân',
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1 — Bệnh nhân
                  _buildSectionCard(
                    icon: LucideIcons.users,
                    title: '1. Bệnh nhân',
                    badge: 'Bắt buộc',
                    children: [_buildPatientDropdown()],
                  ),
                  const SizedBox(height: 20),

                  // Section 2 — Bác sĩ phụ trách
                  _buildSectionCard(
                    icon: LucideIcons.stethoscope,
                    title: '2. Bác sĩ phụ trách',
                    badge: 'Bắt buộc',
                    children: [_buildDoctorDropdown()],
                  ),
                  const SizedBox(height: 20),

                  // Section 3 — Thời gian & Lý do
                  _buildSectionCard(
                    icon: LucideIcons.calendarClock,
                    title: '3. Thời gian & Lý do khám',
                    badge: 'Bắt buộc',
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDateSelector()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildTimeSelector()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildReasonField(),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppSecondaryButton(
                        text: 'Huỷ bỏ',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 14),
                      // Listen to submission state
                      BlocListener<AppointmentCubit, AppointmentState>(
                        listener: (context, state) {
                          if (state is AppointmentSuccess) {
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
                            Navigator.of(context).pop(true);
                          } else if (state is AppointmentError) {
                            setState(() => _isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${state.message}'),
                                backgroundColor: AppColors.dangerText,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(20),
                              ),
                            );
                          }
                        },
                        child: AppPrimaryButton(
                          text: 'Xác nhận lịch hẹn',
                          icon: LucideIcons.calendarCheck,
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : _handleSubmit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section card ──
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? badge,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.activeBackground, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              if (badge != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.dangerText)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // ── Patient dropdown via PatientCubit ──
  Widget _buildPatientDropdown() {
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        if (state is PatientLoading || state is PatientInitial) {
          return const LinearProgressIndicator();
        }
        final patients = state is PatientLoaded ? state.patients : [];
        return AppDropdown<String>(
          labelText: 'Tìm bệnh nhân *',
          hintText: 'Chọn bệnh nhân...',
          value: _selectedPatientId,
          prefixIcon: LucideIcons.user,
          items: patients.map<DropdownMenuItem<String>>((p) {
            final code = p.patientCode ?? p.id ?? '';
            final card = p.identityCard.isNotEmpty ? ' — CCCD: ${p.identityCard}' : '';
            return DropdownMenuItem<String>(
              value: p.id,
              child: Text('${p.fullName} ($code)$card'),
            );
          }).toList(),
          onChanged: (v) {
            final p = patients.firstWhere((e) => e.id == v);
            setState(() {
              _selectedPatientId = v;
              _selectedPatientName = p.fullName;
            });
          },
        );
      },
    );
  }

  // ── Doctor dropdown via AppointmentCubit (fetchClinicians) ──
  Widget _buildDoctorDropdown() {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoading || state is AppointmentInitial) {
          return const LinearProgressIndicator();
        }
        final doctors = state is CliniciansLoaded ? state.clinicians : <Map<String, dynamic>>[];
        return AppDropdown<String>(
          labelText: 'Bác sĩ phụ trách *',
          hintText: 'Chọn bác sĩ...',
          value: _selectedDoctorUid,
          prefixIcon: LucideIcons.stethoscope,
          items: doctors.map<DropdownMenuItem<String>>((d) {
            return DropdownMenuItem<String>(
              value: d['uid'] as String,
              child: Text(d['full_name'] as String),
            );
          }).toList(),
          onChanged: (v) {
            final doc = doctors.firstWhere((d) => d['uid'] == v);
            setState(() {
              _selectedDoctorUid = v;
              _selectedDoctorName = doc['full_name'] as String;
            });
          },
        );
      },
    );
  }

  // ── Date selector ──
  Widget _buildDateSelector() {
    return AppTextField(
      labelText: 'Ngày hẹn *',
      hintText: 'dd/MM/yyyy',
      controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_selectedDate)),
      prefixIcon: LucideIcons.calendar,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030, 12, 31),
          locale: const Locale('vi', 'VN'),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
    );
  }

  // ── Time selector ──
  Widget _buildTimeSelector() {
    return AppTextField(
      labelText: 'Giờ hẹn *',
      hintText: 'hh:mm',
      controller: TextEditingController(
        text: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      ),
      prefixIcon: LucideIcons.clock,
      readOnly: true,
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: _selectedTime);
        if (t != null) setState(() => _selectedTime = t);
      },
    );
  }

  // ── Reason field ──
  Widget _buildReasonField() {
    return AppTextField(
      labelText: 'Lý do khám *',
      controller: _reasonController,
      maxLines: 3,
      hintText: 'Mô tả triệu chứng hoặc mục đích khám...',
    );
  }


  // ── Submit: build domain entity and call cubit ──
  Future<void> _handleSubmit() async {
    if (_selectedPatientId == null || _selectedDoctorUid == null || _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: AppColors.warningText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final appointmentDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final appointment = Appointment(
      id: '',
      patientId: _selectedPatientId!,
      patientName: _selectedPatientName ?? '',
      doctorId: _selectedDoctorUid!,
      doctorName: _selectedDoctorName ?? '',
      appointmentDate: appointmentDate,
      reason: _reasonController.text.trim(),
      status: AppointmentStatus.scheduled,
    );

    if (mounted) {
      context.read<AppointmentCubit>().addAppointment(appointment);
    }
  }
}
