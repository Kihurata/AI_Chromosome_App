import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../logic/bloc/specialist/sample_detail_cubit.dart';
import '../../../../logic/bloc/specialist/sample_detail_state.dart';
import '../../../../logic/bloc/auth/auth_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/sample.dart';
import '../../widgets/shared/layouts/main_form_layout.dart';
import '../../widgets/shared/form/app_text_field.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../widgets/shared/form/app_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class SampleDetailScreen extends StatefulWidget {
  final String sampleId; // In creation mode, this is testOrderId

  const SampleDetailScreen({super.key, required this.sampleId});

  @override
  State<SampleDetailScreen> createState() => _SampleDetailScreenState();
}

class _SampleDetailScreenState extends State<SampleDetailScreen> {
  final _noteController = TextEditingController();
  final _sampleDateCtrl = TextEditingController();
  final _sampleTimeCtrl = TextEditingController();
  late final SampleDetailCubit _cubit;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedSampleType = 'Máu ngoại vi';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SampleDetailCubit>();
    // In our new flow, specialist enters this screen to CREATE a sample for an ORDER
    _cubit.loadTestOrder(widget.sampleId);
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    _noteController.dispose();
    _sampleDateCtrl.dispose();
    _sampleTimeCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _submitSample(BuildContext context, String patientName, String patientCode) async {
    final authState = context.read<AuthCubit>().state;
    String specialistId = '';
    if (authState is Authenticated) {
      specialistId = authState.user.uid;
    }

    final collectedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final sample = Sample(
      id: const Uuid().v4(),
      testOrderId: widget.sampleId,
      patientName: patientName,
      patientCode: patientCode,
      sampleType: _selectedSampleType,
      collectedBy: specialistId,
      collectedAt: collectedAt,
      notes: _noteController.text,
      status: SampleStatus.collected,
    );

    await _cubit.createSample(sample);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SampleDetailCubit, SampleDetailState>(
        listener: (context, state) {
          if (state is SampleDetailSuccess && state.sample.id.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo mẫu bệnh phẩm thành công'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is SampleDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          String patientTitle = '...';
          String patientSubtitle = 'Đang tải thông tin...';
          Widget formBody = const Center(child: CircularProgressIndicator());

          if (state is SampleDetailSuccess) {
            final sample = state.sample;
            patientTitle = sample.patientName;
            patientSubtitle = 'Mã BN: ${sample.patientCode}';
            
            formBody = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── THÔNG TIN MẪU BỆNH PHẨM ──────────────────────────────────
                _buildSection(
                  icon: LucideIcons.microscope,
                  title: 'THÔNG TIN THU NHẬN MẪU',
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
                      AppDropdown<String>(
                        labelText: 'Loại mẫu *',
                        hintText: 'Chọn loại mẫu...',
                        value: _selectedSampleType,
                        prefixIcon: LucideIcons.testTube2,
                        items: const [
                          DropdownMenuItem(value: 'Máu ngoại vi', child: Text('Máu ngoại vi')),
                          DropdownMenuItem(value: 'Dịch ối', child: Text('Dịch ối')),
                          DropdownMenuItem(value: 'Gai nhau', child: Text('Gai nhau')),
                          DropdownMenuItem(value: 'Tủy xương', child: Text('Tủy xương')),
                          DropdownMenuItem(value: 'Máu cuống rốn', child: Text('Máu cuống rốn')),
                          DropdownMenuItem(value: 'Sinh thiết da', child: Text('Sinh thiết da')),
                          DropdownMenuItem(value: 'Mô sảy thai', child: Text('Mô sảy thai')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedSampleType = v);
                        },
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        labelText: 'Ghi chú mẫu bệnh phẩm',
                        hintText: 'Nhập ghi chú về tình trạng mẫu...',
                        maxLines: 4,
                        controller: _noteController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── BOTTOM ACTIONS ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppSecondaryButton(
                      text: 'Hủy',
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    AppPrimaryButton(
                      text: 'Lưu mẫu bệnh phẩm',
                      icon: LucideIcons.save,
                      onPressed: () => _submitSample(context, sample.patientName, sample.patientCode),
                    ),
                  ],
                ),
              ],
            );
          }

          if (state is SampleDetailError) {
            formBody = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    text: 'Thử lại',
                    onPressed: () => _cubit.loadTestOrder(widget.sampleId),
                  ),
                ],
              ),
            );
          }

          return MainFormLayout(
            title: 'Tạo Mẫu Bệnh Phẩm',
            subtitle: '$patientTitle - $patientSubtitle',
            showBackButton: true,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: formBody,
            ),
          );
        },
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
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
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

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
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
                    fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

