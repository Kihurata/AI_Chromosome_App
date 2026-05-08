import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/layouts/main_form_layout.dart';
import '../../../widgets/shared/form/app_buttons.dart';
import '../../../../logic/bloc/clinician/clinician_order_cubit.dart';
import '../../../../logic/bloc/clinician/clinician_order_state.dart';
import '../../../../logic/bloc/patient/patient_cubit.dart';
import '../../../../logic/bloc/patient/patient_state.dart';
import '../../../../domain/entities/test_order.dart';
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
    } else if (patientState is PatientLoaded && patientState.filteredPatients.isNotEmpty) {
      final p = patientState.filteredPatients.first;
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

    await context.read<ClinicianOrderCubit>().createOrder(testOrder);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClinicianOrderCubit, ClinicianOrderState>(
      listener: (context, state) {
        if (!mounted) return;
        
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
        subtitle: 'Mã lịch hẹn: #${widget.id.length > 8 ? widget.id.substring(0, 8).toUpperCase() : widget.id.toUpperCase()}',
        showBackButton: true,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── XÁC NHẬN CHỈ ĐỊNH ──────────────────────────────────
              Container(
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
                      const Icon(LucideIcons.fileText, color: AppColors.primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      const Text('XÁC NHẬN CHỈ ĐỊNH',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ]),
                    const SizedBox(height: 20),
                    const Text(
                      'Bằng việc nhấn "Lưu phiếu xét nghiệm", bạn xác nhận yêu cầu thực hiện xét nghiệm di truyền cho bệnh nhân này. Thông tin mẫu bệnh phẩm sẽ được kỹ thuật viên (Specialist) cập nhật sau khi thu nhận thực tế.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.5),
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
}

