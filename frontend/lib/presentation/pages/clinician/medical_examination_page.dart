import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/icd_code_model.dart';
import '../../../data/models/medical_record_model.dart';
import '../../../data/repositories/clinical_repository.dart';

class MedicalExaminationPage extends StatefulWidget {
  final AppointmentModel appointment;

  const MedicalExaminationPage({super.key, required this.appointment});

  @override
  State<MedicalExaminationPage> createState() => _MedicalExaminationPageState();
}

class _MedicalExaminationPageState extends State<MedicalExaminationPage> {
  final ClinicalRepository _clinicalRepo = ClinicalRepository();
  final _formKey = GlobalKey<FormState>();

  final _reasonController = TextEditingController();
  final _pulseController = TextEditingController();
  final _bpController = TextEditingController();
  final _tempController = TextEditingController();
  final _weightController = TextEditingController();
  final _pathologyController = TextEditingController();
  final _physicalController = TextEditingController();
  final _notesController = TextEditingController();

  IcdCodeModel? _selectedIcdCode;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _pulseController.dispose();
    _bpController.dispose();
    _tempController.dispose();
    _weightController.dispose();
    _pathologyController.dispose();
    _physicalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord({bool updateStatus = false}) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final record = MedicalRecordModel(
        id: '',
        appointmentId: FirebaseFirestore.instance.doc('appointments/${widget.appointment.id}'),
        patientId: widget.appointment.patientId,
        doctorId: widget.appointment.doctorId,
        reason: _reasonController.text,
        pulse: int.tryParse(_pulseController.text),
        bloodPressure: _bpController.text,
        temperature: double.tryParse(_tempController.text),
        weight: double.tryParse(_weightController.text),
        pathologicalProcess: _pathologyController.text,
        physicalExamination: _physicalController.text,
        icdCode: _selectedIcdCode?.code ?? '',
        icdName: _selectedIcdCode?.name ?? '',
        doctorNotes: _notesController.text,
        createdAt: DateTime.now(),
      );

      await _clinicalRepo.saveMedicalRecord(record);
      
      if (updateStatus) {
        await _clinicalRepo.updateAppointmentStatus(widget.appointment.id, 'waiting_for_test');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu thông tin khám bệnh'), backgroundColor: AppColors.successText));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.dangerText));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOrderTest() async {
    // Show confirmation dialog
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lưu thông tin khám?'),
        content: const Text('Bạn có muốn lưu thông tin khám bệnh trước khi chỉ định xét nghiệm không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không lưu')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            child: const Text('Có, lưu thông tin'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveRecord(updateStatus: true);
    } else {
      await _clinicalRepo.updateAppointmentStatus(widget.appointment.id, 'waiting_for_test');
    }

    // MVP: For now test_order is just assumed to be created here
    // We would navigate to a generic Test Order creation page or just do it logic-wise
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chuyển bệnh nhân sang chờ xét nghiệm'), backgroundColor: AppColors.primaryBlue));
      Navigator.pop(context); // Go back to appointments
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông tin Khám bệnh', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPatientHeader(),
                        const Divider(height: 1, color: AppColors.border),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(LucideIcons.user, 'KHÁM TỔNG QUÁT'),
                              _buildTextField('LÝ DO ĐẾN KHÁM', 'Nhập lý do chính...', _reasonController, maxLines: 2),
                              const SizedBox(height: 24),
                              const Text('CHỈ SỐ SINH TỒN (VITALS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPlaceholder)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField('', 'Mạch', _pulseController, suffix: 'bpm')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('', 'H.Áp', _bpController, suffix: 'mmHg')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('', 'Nhiệt độ', _tempController, suffix: '°C')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField('', 'Cân nặng', _weightController, suffix: 'kg')),
                                ],
                              ),
                              const SizedBox(height: 48),

                              _buildSectionTitle(LucideIcons.activity, 'DIỄN BIẾN & TRIỆU CHỨNG'),
                              _buildTextField('QUÁ TRÌNH BỆNH LÝ', 'Mô tả diễn biến bệnh lý...', _pathologyController, maxLines: 4),
                              const SizedBox(height: 24),
                              _buildTextField('KHÁM THỰC THỂ', 'Các triệu chứng thực thể...', _physicalController, maxLines: 4),
                              const SizedBox(height: 48),

                              _buildSectionTitle(LucideIcons.fileText, 'CHẨN ĐOÁN & CHỈ ĐỊNH'),
                              const Text('CHẨN ĐOÁN SƠ BỘ (ICD-10)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPlaceholder)),
                              const SizedBox(height: 8),
                              _buildIcdAutocomplete(),
                              const SizedBox(height: 24),
                              _buildTextField('GHI CHÚ / DẶN DÒ', 'Ghi chú điều trị, dặn dò bệnh nhân...', _notesController, maxLines: 4),
                              const SizedBox(height: 48),

                              _buildActionButtons(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPatientHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HỌ TÊN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPlaceholder)),
                  Text(widget.appointment.patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(width: 48),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MÃ BN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPlaceholder)),
                  Text('Đang khám', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(20)),
            child: const Text('ĐANG KHÁM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warningText)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withAlpha(25), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1, String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPlaceholder)),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textPlaceholder),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 13),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
      ],
    );
  }

  Widget _buildIcdAutocomplete() {
    return Autocomplete<IcdCodeModel>(
      displayStringForOption: (option) => '${option.code} - ${option.name}',
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<IcdCodeModel>.empty();
        }
        final results = await _clinicalRepo.searchIcdCodes(textEditingValue.text);
        return results;
      },
      onSelected: (option) {
        setState(() => _selectedIcdCode = option);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Tìm mã hoặc tên bệnh...',
            suffixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textPlaceholder),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Hủy'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => _saveRecord(updateStatus: false),
          icon: const Icon(LucideIcons.save, size: 18),
          label: const Text('Lưu'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng Kê đơn thuốc đang xây dựng')));
          },
          icon: const Icon(LucideIcons.pill, size: 18),
          label: const Text('Kê Đơn thuốc'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: const BorderSide(color: AppColors.primaryBlue),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _handleOrderTest,
          icon: const Icon(LucideIcons.flaskConical, size: 18),
          label: const Text('Chỉ định Xét nghiệm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
