import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/layouts/main_form_layout.dart';
import '../../../widgets/shared/form/app_text_field.dart';
import '../../../widgets/shared/form/app_buttons.dart';
import '../../../../logic/bloc/clinician/clinician_order_cubit.dart';
import '../../../../logic/bloc/clinician/clinician_order_state.dart';
import '../../../../logic/bloc/patient/patient_cubit.dart';
import '../../../../logic/bloc/patient/patient_state.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../logic/bloc/auth/auth_cubit.dart';
import '../../../../core/router/app_router.dart';

class ClinicianBloodTestPrescriptionPage extends StatefulWidget {
  final String id; // appointmentId
  const ClinicianBloodTestPrescriptionPage({super.key, required this.id});

  @override
  State<ClinicianBloodTestPrescriptionPage> createState() =>
      _ClinicianBloodTestPrescriptionPageState();
}

class _ClinicianBloodTestPrescriptionPageState
    extends State<ClinicianBloodTestPrescriptionPage> {
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _clinicalNotesCtrl = TextEditingController();
  final _sampleDateCtrl = TextEditingController();
  final _sampleTimeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _clinicalNotesCtrl.dispose();
    _sampleDateCtrl.dispose();
    _sampleTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitOrder(BuildContext context) async {
    final patientState = context.read<PatientCubit>().state;
    final authState = context.read<AuthCubit>().state;
    
    String patientId = '';
    String patientName = '';
    String patientCode = '';
    String clinicianId = '';

    if (patientState is PatientDetailLoaded) {
      final p = patientState.patient;
      patientId = p.id ?? '';
      patientName = p.fullName;
      patientCode = p.patientCode ?? '';
    } else if (patientState is PatientLoaded && patientState.patients.isNotEmpty) {
      final p = patientState.patients.first;
      patientId = p.id ?? '';
      patientName = p.fullName;
      patientCode = p.patientCode ?? '';
    }

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa tải được thông tin bệnh nhân. Vui lòng thử lại.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (authState is Authenticated) {
      clinicianId = authState.user.uid;
    }

    final orderId = const Uuid().v4();
    final testOrder = TestOrder(
      id: orderId,
      patientId: patientId,
      patientName: patientName,
      patientCode: patientCode,
      appointmentId: widget.id,
      clinicianId: clinicianId,
      createdAt: DateTime.now(),
    );

    final collectedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final sample = Sample(
      id: const Uuid().v4(),
      testOrderId: orderId,
      patientName: patientName,
      patientCode: patientCode,
      sampleType: 'Máu',
      collectedBy: clinicianId,
      collectedAt: collectedAt,
      notes: _clinicalNotesCtrl.text,
      status: SampleStatus.collected,
    );

    await context.read<ClinicianOrderCubit>().submitOrderWithSample(
      order: testOrder,
      sample: sample,
    );
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
          context.go(AppRoutes.clinicianDashboard);
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
              // ── THÔNG TIN MẪU BỆNH PHẨM ──────────────────────────────────
              _buildSection(
                icon: LucideIcons.microscope,
                title: 'THÔNG TIN MẪU BỆNH PHẨM',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDateSelector()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTimeSelector()),
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

  Widget _buildDateSelector() {
    _sampleDateCtrl.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    return AppTextField(
      labelText: 'Ngày lấy mẫu *',
      hintText: 'dd/MM/yyyy',
      controller: _sampleDateCtrl,
      prefixIcon: LucideIcons.calendar,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 7)),
          locale: const Locale('vi', 'VN'),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
    );
  }

  Widget _buildTimeSelector() {
    _sampleTimeCtrl.text = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    return AppTextField(
      labelText: 'Giờ lấy mẫu *',
      hintText: 'hh:mm',
      controller: _sampleTimeCtrl,
      prefixIcon: LucideIcons.clock,
      readOnly: true,
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: _selectedTime);
        if (t != null) setState(() => _selectedTime = t);
      },
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
