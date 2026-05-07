import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/layouts/main_form_layout.dart';
import '../../../widgets/shared/form/app_text_field.dart';
import '../../../widgets/shared/form/app_buttons.dart';
import '../../../widgets/shared/form/app_dropdown.dart';
import '../../../../logic/bloc/clinician/examination_cubit.dart';
import '../../../../logic/bloc/clinician/examination_state.dart';
import '../../../../logic/bloc/patient/patient_cubit.dart';
import '../../../../logic/bloc/patient/patient_state.dart';
import '../../../../logic/bloc/auth/auth_cubit.dart';
import '../../../../core/router/app_router.dart';

class ClinicianExaminationFormPage extends StatefulWidget {
  final String id; // appointmentId
  const ClinicianExaminationFormPage({super.key, required this.id});

  @override
  State<ClinicianExaminationFormPage> createState() =>
      _ClinicianExaminationFormPageState();
}

class _ClinicianExaminationFormPageState
    extends State<ClinicianExaminationFormPage> {
  // Controllers
  final _symptomLocationCtrl = TextEditingController();
  final _symptomDurationCtrl = TextEditingController();
  final _medicalHistoryCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _currentMedicationsCtrl = TextEditingController();
  final _prelimDiagCtrl = TextEditingController();
  final _icdCodeCtrl = TextEditingController();
  final _conclusionCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _medicationNotesCtrl = TextEditingController();
  final _followUpCtrl = TextEditingController();
  final _followUpTimeCtrl = TextEditingController();
  bool _priorityFollowUp = false;
  String _symptomSeverity = '5';
  DateTime? _selectedFollowUpDate;
  TimeOfDay _selectedFollowUpTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _symptomLocationCtrl.dispose();
    _symptomDurationCtrl.dispose();
    _medicalHistoryCtrl.dispose();
    _allergiesCtrl.dispose();
    _currentMedicationsCtrl.dispose();
    _prelimDiagCtrl.dispose();
    _icdCodeCtrl.dispose();
    _conclusionCtrl.dispose();
    _treatmentCtrl.dispose();
    _medicationNotesCtrl.dispose();
    _followUpCtrl.dispose();
    _followUpTimeCtrl.dispose();
    super.dispose();
  }

  String _getPatientId(BuildContext context) {
    final state = context.read<PatientCubit>().state;
    if (state is PatientDetailLoaded) {
      return state.patient.id ?? '';
    }
    if (state is PatientLoaded && state.filteredPatients.isNotEmpty) {
      return state.filteredPatients.first.id ?? '';
    }
    return '';
  }

  String _getDoctorId(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) return state.user.uid;
    return '';
  }

  Future<bool> _saveExamination({required bool andComplete}) async {
    final cubit = context.read<ExaminationCubit>();
    final patientId = _getPatientId(context);
    final doctorId = _getDoctorId(context);

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin bệnh nhân. Vui lòng quay lại.'), backgroundColor: Colors.orange),
      );
      return false;
    }

    if (andComplete) {
      await cubit.completeExamination(
        appointmentId: widget.id,
        patientId: patientId,
        doctorId: doctorId,
        symptomLocation: _symptomLocationCtrl.text,
        symptomDuration: _symptomDurationCtrl.text,
        symptomSeverity: _symptomSeverity,
        medicalHistory: _medicalHistoryCtrl.text,
        allergies: _allergiesCtrl.text,
        currentMedications: _currentMedicationsCtrl.text,
        preliminaryDiagnosis: _prelimDiagCtrl.text,
        icdCode: _icdCodeCtrl.text,
        conclusion: _conclusionCtrl.text,
        treatmentPlan: _treatmentCtrl.text,
        medicationNotes: _medicationNotesCtrl.text,
        followUpDate: _selectedFollowUpDate != null 
            ? DateTime(
                _selectedFollowUpDate!.year,
                _selectedFollowUpDate!.month,
                _selectedFollowUpDate!.day,
                _selectedFollowUpTime.hour,
                _selectedFollowUpTime.minute,
              )
            : null,
        priorityFollowUp: _priorityFollowUp,
      );
      return cubit.state is ExaminationSaveSuccess;
    } else {
      return cubit.saveBeforeOrderingTest(
        appointmentId: widget.id,
        patientId: patientId,
        doctorId: doctorId,
        symptomLocation: _symptomLocationCtrl.text,
        symptomDuration: _symptomDurationCtrl.text,
        symptomSeverity: _symptomSeverity,
        medicalHistory: _medicalHistoryCtrl.text,
        allergies: _allergiesCtrl.text,
        currentMedications: _currentMedicationsCtrl.text,
        preliminaryDiagnosis: _prelimDiagCtrl.text,
        icdCode: _icdCodeCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExaminationCubit, ExaminationState>(
      listener: (context, state) {
        if (state is ExaminationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: MainFormLayout(
        title: 'PHIẾU KHÁM BỆNH',
        subtitle: 'Mã lịch hẹn: #${widget.id.substring(0, 8).toUpperCase()}',
        showBackButton: false,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── NỘI DUNG CHUYÊN MÔN ──────────────────────────────────────
              _buildSection(
                icon: LucideIcons.stethoscope,
                title: 'NỘI DUNG CHUYÊN MÔN',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitle('TRIỆU CHỨNG LÂM SÀNG'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            labelText: 'Vị trí đau/khó chịu',
                            hintText: 'Vùng thượng vị, ngực trái...',
                            controller: _symptomLocationCtrl,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            labelText: 'Thời gian bị',
                            hintText: '2 ngày trước, kéo dài 10p...',
                            controller: _symptomDurationCtrl,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppDropdown<String>(
                            labelText: 'Mức độ đau (1-10)',
                            value: _symptomSeverity,
                            items: List.generate(10, (index) => (index + 1).toString())
                                .map((e) => DropdownMenuItem(value: e, child: Text('$e - ${e == '5' ? 'Trung bình' : 'Mức $e'}')))
                                .toList(),
                            onChanged: (v) => setState(() => _symptomSeverity = v ?? '5'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _subTitle('TIỀN SỬ & DỊ ỨNG'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            labelText: 'Bệnh nền',
                            hintText: 'Tiểu đường, cao huyết áp...',
                            maxLines: 3,
                            controller: _medicalHistoryCtrl,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            labelText: 'Dị ứng',
                            hintText: 'Thuốc kháng sinh, hải sản...',
                            maxLines: 3,
                            controller: _allergiesCtrl,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            labelText: 'Thuốc đang dùng',
                            hintText: 'Tên thuốc, liều dùng...',
                            maxLines: 3,
                            controller: _currentMedicationsCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            labelText: 'CHẨN ĐOÁN SƠ BỘ',
                            hintText: 'Nhập chẩn đoán sơ bộ...',
                            controller: _prelimDiagCtrl,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            labelText: 'CHẨN ĐOÁN CHÍNH (ICD-10)',
                            hintText: 'Tìm mã bệnh ICD-10...',
                            suffixIcon: const Icon(LucideIcons.search, size: 16),
                            controller: _icdCodeCtrl,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── KẾT LUẬN & ĐIỀU TRỊ ──────────────────────────────────────
              _buildSection(
                icon: LucideIcons.pill,
                title: 'KẾT LUẬN & ĐIỀU TRỊ',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            labelText: 'KẾT LUẬN BỆNH',
                            hintText: 'Tóm tắt tình trạng và kết luận...',
                            maxLines: 3,
                            controller: _conclusionCtrl,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            labelText: 'HƯỚNG ĐIỀU TRỊ & DẶN DÒ',
                            hintText: 'Chế độ ăn uống, sinh hoạt...',
                            maxLines: 3,
                            controller: _treatmentCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hẹn tái khám
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _buildFollowUpDateSelector()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildFollowUpTimeSelector()),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _priorityFollowUp = !_priorityFollowUp),
                                child: Container(
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(
                                    color: _priorityFollowUp ? AppColors.primaryBlue : Colors.transparent,
                                    border: Border.all(color: _priorityFollowUp ? AppColors.primaryBlue : AppColors.border),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _priorityFollowUp
                                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Ưu tiên tái khám',
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      labelText: 'GHI CHÚ THUỐC',
                      hintText: 'Ghi chú thêm về đơn thuốc...',
                      maxLines: 3,
                      controller: _medicationNotesCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── BOTTOM ACTIONS ─────────────────────────────────────────────
              BlocBuilder<ExaminationCubit, ExaminationState>(
                builder: (context, state) {
                  final isLoading = state is ExaminationLoading;
                  final cubit = context.read<ExaminationCubit>();
                  final router = GoRouter.of(context);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppSecondaryButton(
                        text: 'Hủy khám',
                        onPressed: isLoading
                            ? null
                            : () async {
                                await cubit.cancelExamination(widget.id);
                                if (mounted) router.go('/clinician/dashboard');
                              },
                      ),
                      Row(
                        children: [
                          AppSecondaryButton(
                            text: 'Lập Phiếu CĐXN',
                            icon: LucideIcons.flaskConical,
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final saved = await _saveExamination(andComplete: false);
                                    if (saved && mounted) {
                                      router.push('${AppRoutes.clinicianBloodTest}/${widget.id}');
                                    }
                                  },
                          ),
                          const SizedBox(width: 12),
                          isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : AppPrimaryButton(
                                  text: 'Lưu thông tin',
                                  icon: LucideIcons.save,
                                  onPressed: () async {
                                    await _saveExamination(andComplete: true);
                                    if (mounted && cubit.state is ExaminationSaveSuccess) {
                                      router.go('/clinician/dashboard');
                                    }
                                  },
                                ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpDateSelector() {
    _followUpCtrl.text = _selectedFollowUpDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedFollowUpDate!)
        : '';
    return AppTextField(
      labelText: 'HẸN TÁI KHÁM',
      hintText: 'dd/MM/yyyy',
      controller: _followUpCtrl,
      prefixIcon: LucideIcons.calendar,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedFollowUpDate ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('vi', 'VN'),
        );
        if (picked != null) setState(() => _selectedFollowUpDate = picked);
      },
    );
  }

  Widget _buildFollowUpTimeSelector() {
    _followUpTimeCtrl.text = _selectedFollowUpDate != null
        ? '${_selectedFollowUpTime.hour.toString().padLeft(2, '0')}:${_selectedFollowUpTime.minute.toString().padLeft(2, '0')}'
        : '';
    return AppTextField(
      labelText: 'GIỜ HẸN',
      hintText: 'hh:mm',
      controller: _followUpTimeCtrl,
      prefixIcon: LucideIcons.clock,
      readOnly: true,
      onTap: () async {
        if (_selectedFollowUpDate == null) return;
        final t = await showTimePicker(
            context: context, initialTime: _selectedFollowUpTime);
        if (t != null) setState(() => _selectedFollowUpTime = t);
      },
    );
  }

  Widget _buildSection({required IconData icon, required String title, String? actionText, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(icon, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ]),
              if (actionText != null)
                Text(actionText, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _subTitle(String title) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
      ],
    );
  }
}
