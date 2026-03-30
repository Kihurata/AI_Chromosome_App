import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/clinical_repository.dart';
import 'package:intl/intl.dart';

class PatientRegistrationPage extends StatefulWidget {
  final ClinicalRepository? repository;
  const PatientRegistrationPage({super.key, this.repository});

  @override
  State<PatientRegistrationPage> createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  late final ClinicalRepository _clinicalRepo;

  @override
  void initState() {
    super.initState();
    _clinicalRepo = widget.repository ?? ClinicalRepository();
  }

  // Section 1 Controllers
  final _fullNameController = TextEditingController();
  final _identityCardController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Nam';

  // Section 2 Controllers
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // Province/District/Ward cascading
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  // Duplicate check states
  String? _duplicateWarning;
  bool _isSubmitting = false;

  // Sample Vietnam administrative data (compact for demo)
  static const Map<String, Map<String, List<String>>> _addressData = {
    'TP. Hồ Chí Minh': {
      'Quận 1': ['Phường Bến Nghé', 'Phường Bến Thành', 'Phường Cầu Kho', 'Phường Đa Kao'],
      'Quận 3': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5'],
      'Quận 7': ['Phường Tân Phú', 'Phường Tân Thuận Đông', 'Phường Tân Thuận Tây'],
      'Quận Bình Thạnh': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 5'],
      'TP. Thủ Đức': ['Phường An Phú', 'Phường Bình Thọ', 'Phường Linh Trung'],
    },
    'Hà Nội': {
      'Quận Ba Đình': ['Phường Cống Vị', 'Phường Điện Biên', 'Phường Ngọc Hà'],
      'Quận Hoàn Kiếm': ['Phường Hàng Bài', 'Phường Hàng Bạc', 'Phường Hàng Bồ'],
      'Quận Đống Đa': ['Phường Cát Linh', 'Phường Hàng Bột', 'Phường Ô Chợ Dừa'],
    },
    'Đà Nẵng': {
      'Quận Hải Châu': ['Phường Hải Châu 1', 'Phường Hải Châu 2', 'Phường Thanh Bình'],
      'Quận Sơn Trà': ['Phường An Hải Bắc', 'Phường An Hải Đông'],
    },
  };

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
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(bottom: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.border.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.arrowLeft, color: AppColors.textSecondary, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Tiếp nhận bệnh nhân tại quầy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Section 1: Thông tin định danh (Bắt buộc) ──
                        _buildSectionCard(
                          icon: LucideIcons.userCheck,
                          title: '1. Thông tin định danh',
                          badge: 'Bắt buộc',
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildField(
                                    'Họ và tên',
                                    _fullNameController,
                                    hint: 'NGUYỄN VĂN A',
                                    required: true,
                                    prefixIcon: LucideIcons.user,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildField(
                                    'Số CCCD / Hộ chiếu',
                                    _identityCardController,
                                    hint: '001203xxxxxx',
                                    required: true,
                                    prefixIcon: LucideIcons.creditCard,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                                    onChanged: (_) => _checkDuplicate(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildDateField()),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildField(
                                    'Số điện thoại',
                                    _phoneController,
                                    hint: '090 123 4567',
                                    required: true,
                                    prefixIcon: LucideIcons.phone,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                                    onChanged: (_) => _checkDuplicate(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _buildGenderField(),

                            // Duplicate Warning
                            if (_duplicateWarning != null)
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
                                          _duplicateWarning!,
                                          style: const TextStyle(fontSize: 13, color: AppColors.dangerText, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Section 2: Địa chỉ & Liên lạc ──
                        _buildSectionCard(
                          icon: LucideIcons.mapPin,
                          title: '2. Địa chỉ & Liên lạc',
                          children: [
                            // Cascading Dropdowns
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildDropdown('Tỉnh/Thành phố', _addressData.keys.toList(), _selectedProvince, (v) {
                                  setState(() {
                                    _selectedProvince = v;
                                    _selectedDistrict = null;
                                    _selectedWard = null;
                                  });
                                })),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDropdown(
                                  'Quận/Huyện',
                                  _selectedProvince != null ? _addressData[_selectedProvince]!.keys.toList() : [],
                                  _selectedDistrict,
                                  (v) {
                                    setState(() {
                                      _selectedDistrict = v;
                                      _selectedWard = null;
                                    });
                                  },
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDropdown(
                                  'Phường/Xã',
                                  (_selectedProvince != null && _selectedDistrict != null)
                                      ? _addressData[_selectedProvince]![_selectedDistrict]! : [],
                                  _selectedWard,
                                  (v) => setState(() => _selectedWard = v),
                                )),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _buildField(
                              'Số nhà, Tên đường',
                              _addressController,
                              hint: '123 Đường Lê Lợi...',
                              prefixIcon: LucideIcons.home,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildField(
                                    'Người liên hệ khẩn cấp',
                                    _emergencyNameController,
                                    hint: 'Họ và tên người thân',
                                    prefixIcon: LucideIcons.heartHandshake,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildField(
                                    'SĐT người thân',
                                    _emergencyPhoneController,
                                    hint: '091 xxxxxxx',
                                    prefixIcon: LucideIcons.phoneCall,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Actions ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Huỷ bỏ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ),
                            const SizedBox(width: 14),
                            ElevatedButton.icon(
                              onPressed: (_isSubmitting || _duplicateWarning != null) ? null : _handleSubmit,
                              icon: _isSubmitting
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(LucideIcons.save, size: 16),
                              label: Text(
                                _isSubmitting ? 'Đang lưu...' : 'Lưu hồ sơ',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primaryBlue.withAlpha(120),
                                disabledForegroundColor: Colors.white70,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          ),
        ],
      ),
    );
  }

  // ── Section Card ──
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
                decoration: BoxDecoration(color: AppColors.activeBackground, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              if (badge != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
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

  // ── Text Field ──
  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool required = false,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: _inputDecoration(hint ?? '').copyWith(
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(prefixIcon, size: 16, color: AppColors.textPlaceholder),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null : null,
        ),
      ],
    );
  }

  // ── Date Picker ──
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Ngày sinh (dd/mm/yyyy)', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          decoration: _inputDecoration('dd/mm/yyyy').copyWith(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(LucideIcons.calendar, size: 16, color: AppColors.textPlaceholder),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng chọn ngày sinh' : null,
          onTap: () async {
            DateTime initialDateValue = DateTime(1990, 1, 1);
            if (_dobController.text.isNotEmpty) {
              try {
                initialDateValue = DateFormat('dd/MM/yyyy').parse(_dobController.text);
              } catch (_) {}
            }
            final date = await showDatePicker(
              context: context,
              initialDate: initialDateValue,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              locale: const Locale('vi', 'VN'),
            );
            if (date != null) {
              _dobController.text = DateFormat('dd/MM/yyyy').format(date);
            }
          },
        ),
      ],
    );
  }

  // ── Gender Radio ──
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Giới tính', required: true),
        const SizedBox(height: 8),
        Row(
          children: ['Nam', 'Nữ', 'Khác'].map((g) {
            final isSelected = _selectedGender == g;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _selectedGender = g),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPlaceholder,
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      g,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Dropdown ──
  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          decoration: _inputDecoration('Chọn $label'),
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textPlaceholder),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: items.isEmpty ? null : onChanged,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  // ── Label ──
  Widget _label(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        if (required) const Text(' *', style: TextStyle(color: AppColors.dangerText, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ── Input Decoration ──
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
      filled: true,
      fillColor: AppColors.border.withAlpha(35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.dangerText)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.dangerText, width: 1.5)),
    );
  }

  // ── Duplicate Check ──
  Future<void> _checkDuplicate() async {
    final idCard = _identityCardController.text.trim();
    final phone = _phoneController.text.trim();

    if (idCard.length < 9 && phone.length < 9) {
      if (_duplicateWarning != null) {
        setState(() => _duplicateWarning = null);
      }
      return;
    }

    final existingPatient = await _clinicalRepo.checkDuplicatePatient(
      identityCard: idCard.length >= 9 ? idCard : null,
      phone: phone.length >= 9 ? phone : null,
    );

    if (mounted) {
      setState(() {
        if (existingPatient != null) {
          _duplicateWarning = 'Bệnh nhân "${existingPatient.fullName}" đã tồn tại trong hệ thống (Mã: ${existingPatient.patientCode ?? existingPatient.id}). Vui lòng kiểm tra lại.';
        } else {
          _duplicateWarning = null;
        }
      });
    }
  }

  // ── Submit ──
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_duplicateWarning != null) return;

    setState(() => _isSubmitting = true);

    try {
      final dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);

      final patient = PatientModel(
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

      await _clinicalRepo.createPatient(patient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Đã lưu hồ sơ bệnh nhân thành công!'),
              ],
            ),
            backgroundColor: AppColors.successText,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.dangerText,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
