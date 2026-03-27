import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/clinical_repository.dart';
import 'package:intl/intl.dart';

class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({super.key});

  @override
  State<PatientRegistrationPage> createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _selectedGender = 'Nam';
  static const Map<String, String> _doctorMapping = {
    'BS. Nguyễn Kim Cương': 'SuyvcITqmXd0pXYMbhR9a6l1cR52',
    'BS. Lê Minh Tuấn': 'DOC_002',
    'BS. Vũ Hồng Ngọc': 'DOC_003',
    'BS. Phạm Thị Mai': 'DOC_004',
  };

  String? _selectedDoctor;
  TimeOfDay? _selectedTime;

  final ClinicalRepository _clinicalRepo = ClinicalRepository();

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top bar
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Đăng ký Bệnh nhân mới',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 1 – Personal Info
                        _buildSectionCard(
                          icon: LucideIcons.user,
                          title: 'Thông tin cá nhân',
                          children: [
                            Row(
                              children: [
                                Expanded(flex: 3, child: _buildField('Họ và tên', _fullNameController, hint: 'Nguyễn Văn A', required: true)),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildDateField()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(flex: 2, child: _buildGenderField()),
                                const SizedBox(width: 16),
                                Expanded(flex: 3, child: _buildField('Số điện thoại', _phoneController, hint: '0912 345 678', keyboardType: TextInputType.phone)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildField('Địa chỉ', _addressController, hint: '123 Đường ABC, Quận 1, TP.HCM'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Section 2 – Appointment
                        _buildSectionCard(
                          icon: LucideIcons.calendarClock,
                          title: 'Thông tin Lịch hẹn',
                          children: [
                            _buildTextAreaField('Lý do khám', _reasonController,
                                hint: 'Mô tả ngắn gọn lý do bệnh nhân đến khám...', required: true),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(flex: 3, child: _buildDoctorDropdown()),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildTimeField(context)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Huỷ bỏ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _handleSubmit,
                              icon: const Icon(LucideIcons.save, size: 16),
                              label: const Text('Lưu hồ sơ & Tạo lịch hẹn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.activeBackground, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

  Widget _buildField(String label, TextEditingController controller, {
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint ?? ''),
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null : null,
        ),
      ],
    );
  }

  Widget _buildTextAreaField(String label, TextEditingController controller, {String? hint, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: _inputDecoration(hint ?? ''),
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null : null,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Ngày sinh'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          decoration: _inputDecoration('DD/MM/YYYY').copyWith(
            suffixIcon: const Icon(LucideIcons.calendar, size: 16, color: AppColors.textPlaceholder),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(1990, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              _dobController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
            }
          },
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Giới tính'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: _inputDecoration(''),
          items: ['Nam', 'Nữ', 'Khác'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
      ],
    );
  }

  Widget _buildDoctorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Bác sĩ lâm sàng phụ trách', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedDoctor,
          decoration: _inputDecoration('Chọn bác sĩ...'),
          items: _doctorMapping.keys.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (v) => setState(() => _selectedDoctor = v),
          validator: (v) => v == null ? 'Vui lòng chọn bác sĩ' : null,
        ),
      ],
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Giờ hẹn', required: true),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
            if (t != null) setState(() => _selectedTime = t);
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.border.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, size: 16, color: AppColors.textPlaceholder),
                const SizedBox(width: 8),
                Text(
                  _selectedTime != null
                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Chọn giờ...',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedTime != null ? AppColors.textPrimary : AppColors.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        if (required) const Text(' *', style: TextStyle(color: AppColors.dangerText, fontSize: 13)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
      filled: true,
      fillColor: AppColors.border.withAlpha(40),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.dangerText)),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
        
        final patient = PatientModel(
          fullName: _fullNameController.text,
          dob: dob,
          gender: _selectedGender ?? 'Khác',
          phone: _phoneController.text,
          address: _addressController.text,
          email: '', // Not in form yet
          bloodGroup: '', // Not in form yet
        );

        final now = DateTime.now();
        final appointmentDate = DateTime(
          now.year, now.month, now.day,
          _selectedTime?.hour ?? 8,
          _selectedTime?.minute ?? 0,
        );

        await _clinicalRepo.registerPatientWithAppointment(
          patient,
          {
            'doctor_uid': _doctorMapping[_selectedDoctor]!,
            'doctor_name': _selectedDoctor,
            'date': appointmentDate,
            'reason': _reasonController.text,
          },
        );

        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Đã lưu hồ sơ và tạo lịch hẹn trên hệ thống!'),
                ],
              ),
              backgroundColor: AppColors.successText,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(20),
            ),
          );
          Navigator.of(context).pop(); // Go back to dashboard
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: AppColors.dangerText),
          );
        }
      }
    }
  }
}
