import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/patient.dart';
import '../../../logic/bloc/patient/patient_cubit.dart';
import '../../../logic/bloc/patient/patient_state.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/receptionist/registration_section.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../widgets/shared/form/app_text_field.dart';
import '../../widgets/shared/layouts/main_form_layout.dart';

class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({super.key});

  @override
  State<PatientRegistrationPage> createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

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

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final dob = DateTime.tryParse(_dobController.text.split('/').reversed.join('-')) ?? DateTime.now();

    final patient = Patient(
      id: '', // Sẽ được Firebase tự tạo
      fullName: _fullNameController.text.trim(),
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
    );

    context.read<PatientCubit>().createPatient(patient);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        if (state is PatientActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.successText,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is PatientError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: AppColors.dangerText,
            ),
          );
        }
      },
      child: MainFormLayout(
        title: 'Tiếp nhận bệnh nhân tại quầy',
        subtitle: 'Thêm mới thông tin bệnh nhân vào hệ thống',
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

  const _IdentitySection({
    required this.fullNameController,
    required this.identityCardController,
    required this.dobController,
    required this.phoneController,
    required this.selectedGender,
    required this.onGenderChanged,
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
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập SĐT' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _GenderSelector(selectedGender: selectedGender, onChanged: onGenderChanged),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  const _DatePickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
      child: IgnorePointer(
        child: AppTextField(
          labelText: 'Ngày sinh *',
          controller: controller,
          hintText: 'dd/mm/yyyy',
          prefixIcon: LucideIcons.calendar,
          validator: (v) => (v == null || v.isEmpty) ? 'Chọn ngày sinh' : null,
        ),
      ),
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
            Expanded(child: _SimpleDropdown(label: 'Tỉnh/Thành', value: selectedProvince, items: const ['TP. Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng'], onChanged: onProvinceChanged)),
            const SizedBox(width: 16),
            Expanded(child: _SimpleDropdown(label: 'Quận/Huyện', value: selectedDistrict, items: const ['Quận 1', 'Quận 3', 'Quận 7'], onChanged: onDistrictChanged)),
            const SizedBox(width: 16),
            Expanded(child: _SimpleDropdown(label: 'Phường/Xã', value: selectedWard, items: const ['Phường 1', 'Phường 2'], onChanged: onWardChanged)),
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

class _SimpleDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SimpleDropdown({required this.label, this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _FormActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _FormActions({required this.onCancel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PatientCubit>().state is PatientLoading;
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
