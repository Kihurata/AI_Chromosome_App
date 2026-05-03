import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/layouts/main_form_layout.dart';
import '../../../widgets/shared/form/app_text_field.dart';
import '../../../widgets/shared/form/app_buttons.dart';
import '../../../widgets/shared/form/app_dropdown.dart';
import '../../../../logic/bloc/clinician/clinician_order_cubit.dart';
import '../../../../logic/bloc/clinician/clinician_order_state.dart';
import '../../../../logic/bloc/patient/patient_cubit.dart';
import '../../../../logic/bloc/patient/patient_state.dart';
import '../../../../domain/entities/test_order.dart';

class ClinicianBloodTestPrescriptionPage extends StatefulWidget {
  final String id; // appointmentId
  const ClinicianBloodTestPrescriptionPage({super.key, required this.id});

  @override
  State<ClinicianBloodTestPrescriptionPage> createState() =>
      _ClinicianBloodTestPrescriptionPageState();
}

class _ClinicianBloodTestPrescriptionPageState
    extends State<ClinicianBloodTestPrescriptionPage> {
  final _clinicalNotesCtrl = TextEditingController();
  final _sampleTimeCtrl = TextEditingController();
  String _selectedTestType = 'Xét nghiệm máu';
  String _selectedSampleType = 'Máu';

  @override
  void dispose() {
    _clinicalNotesCtrl.dispose();
    _sampleTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitOrder(BuildContext context) async {
    final patientState = context.read<PatientCubit>().state;
    String patientId = '';
    String patientName = '';
    String patientCode = '';

    if (patientState is PatientLoaded && patientState.patients.isNotEmpty) {
      final p = patientState.patients.first;
      patientId = p.id ?? '';
      patientName = p.fullName;
      patientCode = p.patientCode ?? '';
    }

    final testOrder = TestOrder(
      id: const Uuid().v4(),
      patientId: patientId,
      patientName: patientName,
      patientCode: patientCode,
      appointmentId: widget.id,
      createdAt: DateTime.now(),
    );

    await context.read<ClinicianOrderCubit>().submitTestOrder(testOrder);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClinicianOrderCubit, ClinicianOrderState>(
      listener: (context, state) {
        if (state is ClinicianOrderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to dashboard after success
          context.go('/clinician/dashboard');
        } else if (state is ClinicianOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: MainFormLayout(
        title: 'Phiếu Chỉ định Xét nghiệm',
        subtitle: 'Mã lịch hẹn: #${widget.id.substring(0, 8).toUpperCase()}',
        showBackButton: true,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── THÔNG TIN CHỈ ĐỊNH ────────────────────────────────────────
              _buildSection(
                icon: LucideIcons.fileSearch,
                title: 'THÔNG TIN CHỈ ĐỊNH',
                child: Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<PatientCubit, PatientState>(
                        builder: (context, state) {
                          final name = (state is PatientLoaded && state.patients.isNotEmpty)
                              ? state.patients.first.fullName
                              : '—';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BỆNH NHÂN',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue)),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppDropdown<String>(
                        labelText: 'Loại xét nghiệm',
                        hintText: 'Chọn loại xét nghiệm',
                        value: _selectedTestType,
                        items: const ['Xét nghiệm máu', 'Xét nghiệm nước tiểu', 'Di truyền học']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedTestType = v ?? _selectedTestType),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── THÔNG TIN MẪU BỆNH PHẨM ──────────────────────────────────
              _buildSection(
                icon: LucideIcons.microscope,
                title: 'THÔNG TIN MẪU BỆNH PHẨM',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppDropdown<String>(
                            labelText: 'Loại mẫu',
                            value: _selectedSampleType,
                            items: const ['Máu', 'Nước tiểu', 'Khác']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedSampleType = v ?? _selectedSampleType),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            labelText: 'Thời gian lấy mẫu',
                            hintText: 'dd/mm/yyyy, HH:mm',
                            suffixIcon: const Icon(LucideIcons.calendar, size: 16),
                            controller: _sampleTimeCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      labelText: 'Ghi chú lâm sàng',
                      hintText: 'Nhập tóm tắt bệnh sử, chẩn đoán sơ bộ...',
                      maxLines: 4,
                      controller: _clinicalNotesCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── BOTTOM ACTIONS ────────────────────────────────────────────
              BlocBuilder<ClinicianOrderCubit, ClinicianOrderState>(
                builder: (context, state) {
                  final isLoading = state is ClinicianOrderLoading;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppSecondaryButton(
                        text: 'Hủy',
                        onPressed: isLoading ? null : () => context.pop(),
                      ),
                      const SizedBox(width: 12),
                      isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : AppPrimaryButton(
                              text: 'Lưu phiếu xét nghiệm',
                              icon: LucideIcons.save,
                              onPressed: () => _submitOrder(context),
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

  Widget _buildSection(
      {required IconData icon, required String title, required Widget child}) {
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
          Row(children: [
            Icon(icon, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
