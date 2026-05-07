import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/patient.dart';
import '../../../logic/bloc/patient/patient_cubit.dart';
import '../../../logic/bloc/patient/patient_state.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/receptionist/registration_section.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../widgets/shared/form/app_text_field.dart';
import '../../widgets/shared/form/app_dropdown.dart';
import '../../widgets/shared/layouts/main_form_layout.dart';

class PatientRegistrationPage extends StatefulWidget {
  final Patient? patient;
  const PatientRegistrationPage({super.key, this.patient});

  @override
  State<PatientRegistrationPage> createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // State variables from main branch
  String? _duplicateWarning;
  bool _isSubmitting = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _identityCardController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Nam';
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // Address states
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _fullNameController.text = widget.patient!.fullName;
      _identityCardController.text = widget.patient!.identityCard;
      _dobController.text = DateFormat('dd/MM/yyyy').format(widget.patient!.dob);
      _phoneController.text = widget.patient!.phone;
      _selectedGender = widget.patient!.gender;
      _addressController.text = widget.patient!.address;
      _emergencyNameController.text = widget.patient!.emergencyContactName;
      _emergencyPhoneController.text = widget.patient!.emergencyContactPhone;
      _selectedProvince = widget.patient!.province.isNotEmpty ? widget.patient!.province : null;
      _selectedDistrict = widget.patient!.district.isNotEmpty ? widget.patient!.district : null;
      _selectedWard = widget.patient!.ward.isNotEmpty ? widget.patient!.ward : null;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _identityCardController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  // ── Duplicate Check (from main) ──
  void _checkDuplicate() {
    final idCard = _identityCardController.text.trim();
    final phone = _phoneController.text.trim();

    if (idCard.length < 9 && phone.length < 9) {
      if (_duplicateWarning != null) {
        setState(() => _duplicateWarning = null);
      }
      return;
    }

    context.read<PatientCubit>().checkDuplicate(
          identityCard: idCard.length >= 9 ? idCard : null,
          phone: phone.length >= 9 ? phone : null,
        );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_duplicateWarning != null) return;

    setState(() => _isSubmitting = true);

    try {
      // Use intl for parsing if format is dd/MM/yyyy
      final dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);

      final patient = Patient(
        id: widget.patient?.id ?? '', // Dùng ID cũ nếu là edit
        fullName: _fullNameController.text.trim().toUpperCase(),
        identityCard: _identityCardController.text.trim(),
        dob: dob,
        gender: _selectedGender,
        phone: _phoneController.text.trim(),
        province: _selectedProvince ?? '',
        district: _selectedDistrict ?? '',
        ward: _selectedWard ?? '',
        address: _addressController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
        patientCode: widget.patient?.patientCode, // Giữ nguyên mã BN
      );

      if (mounted) {
        if (widget.patient != null) {
          context.read<PatientCubit>().updatePatient(patient);
        } else {
          context.read<PatientCubit>().createPatient(patient);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý dữ liệu: ${e.toString()}'),
            backgroundColor: AppColors.dangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        if (state is PatientDuplicateChecked) {
          setState(() {
            if (state.existingPatient != null) {
              final p = state.existingPatient!;
              _duplicateWarning = 'Bệnh nhân "${p.fullName}" đã tồn tại trong hệ thống (Mã: ${p.patientCode ?? p.id}). Vui lòng kiểm tra lại.';
            } else {
              _duplicateWarning = null;
            }
          });
        } else if (state is PatientActionSuccess) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.successText,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is PatientError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: AppColors.dangerText,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: MainFormLayout(
        title: widget.patient != null ? 'Chỉnh sửa thông tin bệnh nhân' : 'Tiếp nhận bệnh nhân tại quầy',
        subtitle: widget.patient != null ? 'Cập nhật các thay đổi vào hệ thống' : 'Thêm mới thông tin bệnh nhân vào hệ thống',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IdentitySection(
                fullNameController: _fullNameController,
                identityCardController: _identityCardController,
                dobController: _dobController,
                phoneController: _phoneController,
                selectedGender: _selectedGender,
                onGenderChanged: (v) => setState(() => _selectedGender = v),
                onIdentityChanged: (_) => _checkDuplicate(),
                onPhoneChanged: (_) => _checkDuplicate(),
                duplicateWarning: _duplicateWarning,
              ),
              const SizedBox(height: 24),
              _AddressSection(
                addressController: _addressController,
                emergencyNameController: _emergencyNameController,
                emergencyPhoneController: _emergencyPhoneController,
                selectedProvince: _selectedProvince,
                selectedDistrict: _selectedDistrict,
                selectedWard: _selectedWard,
                onProvinceChanged: (v) => setState(() {
                  _selectedProvince = v;
                  _selectedDistrict = null;
                  _selectedWard = null;
                }),
                onDistrictChanged: (v) => setState(() {
                  _selectedDistrict = v;
                  _selectedWard = null;
                }),
                onWardChanged: (v) => setState(() => _selectedWard = v),
              ),
              const SizedBox(height: 32),
              _FormActions(
                onCancel: () => Navigator.of(context).pop(),
                onSubmit: _handleSubmit,
                isSubmitting: _isSubmitting,
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Widgets Chia nhỏ (Internal Classes) ──

class _IdentitySection extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController identityCardController;
  final TextEditingController dobController;
  final TextEditingController phoneController;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onIdentityChanged;
  final ValueChanged<String> onPhoneChanged;
  final String? duplicateWarning;

  const _IdentitySection({
    required this.fullNameController,
    required this.identityCardController,
    required this.dobController,
    required this.phoneController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onIdentityChanged,
    required this.onPhoneChanged,
    this.duplicateWarning,
  });

  @override
  Widget build(BuildContext context) {
    return RegistrationSection(
      icon: LucideIcons.userCheck,
      title: '1. Thông tin định danh',
      badge: 'Bắt buộc',
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                labelText: 'Họ và tên *',
                controller: fullNameController,
                hintText: 'NGUYỄN VĂN A',
                prefixIcon: LucideIcons.user,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AppTextField(
                labelText: 'Số CCCD / Hộ chiếu *',
                controller: identityCardController,
                hintText: '001203xxxxxx',
                prefixIcon: LucideIcons.creditCard,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                onChanged: onIdentityChanged,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập CCCD' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _DatePickerField(controller: dobController),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AppTextField(
                labelText: 'Số điện thoại *',
                controller: phoneController,
                hintText: '090 123 4567',
                prefixIcon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: onPhoneChanged,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập SĐT' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _GenderSelector(selectedGender: selectedGender, onChanged: onGenderChanged),

        if (duplicateWarning != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dangerText.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 18, color: AppColors.dangerText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      duplicateWarning!,
                      style: const TextStyle(fontSize: 13, color: AppColors.dangerText, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  const _DatePickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      labelText: 'Ngày sinh *',
      controller: controller,
      hintText: 'dd/mm/yyyy',
      prefixIcon: LucideIcons.calendar,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(1990),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          locale: const Locale('vi', 'VN'),
        );
        if (date != null) {
          controller.text = UIUtils.formatDate(date);
        }
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Chọn ngày sinh' : null,
    );
  }
}


class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onChanged;

  const _GenderSelector({required this.selectedGender, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Giới tính *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: ['Nam', 'Nữ', 'Khác'].map((g) {
            final isSelected = selectedGender == g;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: InkWell(
                onTap: () => onChanged(g),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                      size: 20,
                      color: isSelected ? AppColors.primaryBlue : AppColors.textPlaceholder,
                    ),
                    const SizedBox(width: 8),
                    Text(g, style: TextStyle(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AddressSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyPhoneController;
  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedWard;
  final ValueChanged<String?> onProvinceChanged;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onWardChanged;

  const _AddressSection({
    required this.addressController,
    required this.emergencyNameController,
    required this.emergencyPhoneController,
    this.selectedProvince,
    this.selectedDistrict,
    this.selectedWard,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onWardChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RegistrationSection(
      icon: LucideIcons.mapPin,
      title: '2. Địa chỉ & Liên lạc',
      children: [
        Row(
          children: [
            Expanded(
              child: AppDropdown<String>(
                labelText: 'Tỉnh/Thành',
                value: selectedProvince,
                items: const ['TP. Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onProvinceChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppDropdown<String>(
                labelText: 'Quận/Huyện',
                value: selectedDistrict,
                items: const ['Quận 1', 'Quận 3', 'Quận 7']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onDistrictChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppDropdown<String>(
                labelText: 'Phường/Xã',
                value: selectedWard,
                items: const ['Phường 1', 'Phường 2']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onWardChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppTextField(
          labelText: 'Số nhà, Tên đường',
          controller: addressController,
          hintText: '123 Đường...',
          prefixIcon: LucideIcons.home,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                labelText: 'Người liên hệ khẩn cấp',
                controller: emergencyNameController,
                prefixIcon: LucideIcons.heartHandshake,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AppTextField(
                labelText: 'SĐT người thân',
                controller: emergencyPhoneController,
                prefixIcon: LucideIcons.phoneCall,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _FormActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _FormActions({
    required this.onCancel,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PatientCubit>().state is PatientLoading || isSubmitting;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppSecondaryButton(text: 'Huỷ bỏ', onPressed: onCancel),
        const SizedBox(width: 14),
        AppPrimaryButton(
          text: 'Lưu hồ sơ',
          icon: LucideIcons.save,
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
      ],
    );
  }
}
