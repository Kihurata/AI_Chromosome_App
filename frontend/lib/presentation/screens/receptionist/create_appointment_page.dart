import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/clinical_repository.dart';

import '../../widgets/shared/layouts/main_form_layout.dart';
import '../../widgets/shared/form/app_text_field.dart';
import '../../widgets/shared/form/app_buttons.dart';

class CreateAppointmentPage extends StatefulWidget {
  final ClinicalRepository? repository;
  /// Pre-fill with a specific date (e.g. from Calendar page)
  final DateTime? initialDate;

  const CreateAppointmentPage({
    super.key,
    this.repository,
    this.initialDate,
  });

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  late final ClinicalRepository _clinicalRepo;

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
    _clinicalRepo = widget.repository ?? ClinicalRepository();
    _selectedDate = widget.initialDate ?? DateTime.now();
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
                          // Date picker
                          Expanded(child: _buildDateSelector()),
                          const SizedBox(width: 20),
                          // Time picker
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
                      AppPrimaryButton(
                        text: 'Xác nhận lịch hẹn',
                        icon: LucideIcons.calendarCheck,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _handleSubmit,
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
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
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
                decoration: BoxDecoration(
                  color: AppColors.activeBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dangerText,
                    ),
                  ),
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

  // ── Patient dropdown ──
  Widget _buildPatientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Tìm bệnh nhân', required: true),
        const SizedBox(height: 6),
        StreamBuilder<List<PatientModel>>(
          stream: _clinicalRepo.getAllPatients(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            final patients = snapshot.data ?? [];
            return DropdownButtonFormField<String>(
              initialValue: _selectedPatientId,
              decoration: _inputDecoration('Chọn bệnh nhân...'),
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown,
                  size: 16, color: AppColors.textPlaceholder),
              items: patients.map((p) {
                final code = p.patientCode ?? p.id ?? '';
                final card = p.identityCard.isNotEmpty
                    ? ' — CCCD: ${p.identityCard}'
                    : '';
                return DropdownMenuItem(
                  value: p.id,
                  child: Text(
                    '${p.fullName} ($code)$card',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                final p = patients.firstWhere((e) => e.id == v);
                setState(() {
                  _selectedPatientId = v;
                  _selectedPatientName = p.fullName;
                });
              },
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            );
          },
        ),
      ],
    );
  }

  // ── Doctor dropdown ──
  Widget _buildDoctorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Bác sĩ phụ trách', required: true),
        const SizedBox(height: 6),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _clinicalRepo.getClinicians(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            final doctors = snapshot.data ?? [];
            return DropdownButtonFormField<String>(
              initialValue: _selectedDoctorUid,
              decoration: _inputDecoration('Chọn bác sĩ...'),
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown,
                  size: 16, color: AppColors.textPlaceholder),
              items: doctors.map((d) {
                return DropdownMenuItem(
                  value: d['uid'] as String,
                  child: Text(
                    d['full_name'] as String,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                final doc = doctors.firstWhere((d) => d['uid'] == v);
                setState(() {
                  _selectedDoctorUid = v;
                  _selectedDoctorName = doc['full_name'] as String;
                });
              },
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            );
          },
        ),
      ],
    );
  }

  // ── Date selector ──
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Ngày hẹn', required: true),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
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
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.border.withAlpha(35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.calendar,
                    size: 16, color: AppColors.textPlaceholder),
                const SizedBox(width: 10),
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Time selector ──
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Giờ hẹn', required: true),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (t != null) setState(() => _selectedTime = t);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.border.withAlpha(35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock,
                    size: 16, color: AppColors.textPlaceholder),
                const SizedBox(width: 10),
                Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
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

  // ── Shared helpers ──
  Widget _label(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary),
        ),
        if (required)
          const Text(' *',
              style: TextStyle(
                  color: AppColors.dangerText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
      filled: true,
      fillColor: AppColors.border.withAlpha(35),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
    );
  }

  // ── Submit ──
  Future<void> _handleSubmit() async {
    if (_selectedPatientId == null ||
        _selectedDoctorUid == null ||
        _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: AppColors.warningText,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appointmentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
          ),
        );
        Navigator.of(context).pop(true); // return true = refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.dangerText,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

