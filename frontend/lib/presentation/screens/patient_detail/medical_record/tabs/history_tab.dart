import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/providers/drawer_provider.dart';
import '../../../../../core/models/filter_options.dart';
import '../../../../../logic/bloc/clinician/examination_cubit.dart';
import '../../../../../logic/bloc/clinician/examination_state.dart';
import '../../../../../domain/entities/examination.dart';
import '../../../../widgets/shared/form/dashboard_filter_bar.dart';
import '../../../../widgets/shared/filter/advanced_filter_drawer.dart';
import 'package:intl/intl.dart';

class HistoryTab extends ConsumerStatefulWidget {
  final String patientId;
  const HistoryTab({super.key, required this.patientId});

  @override
  ConsumerState<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<HistoryTab> {
  final List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExaminationCubit>().loadExaminations(widget.patientId);
    });
  }

  @override
  void dispose() {
    // Clear global drawer when leaving the page
    Future.microtask(() => ref.read(drawerProvider.notifier).clear());
    super.dispose();
  }

  bool _isDrawerRegistered = false;

  void _registerDrawer(WidgetRef ref, ExaminationCubit cubit) {
    if (_isDrawerRegistered) return;
    _isDrawerRegistered = true;

    Future.microtask(() {
      if (!mounted) return;
      ref.read(drawerProvider.notifier).update(
            endDrawer: BlocProvider.value(
              value: cubit,
              child: BlocBuilder<ExaminationCubit, ExaminationState>(
                buildWhen: (p, c) {
                  if (p is ExaminationLoaded && c is ExaminationLoaded) {
                    return p.sortOrder != c.sortOrder || p.dateRangePreset != c.dateRangePreset;
                  }
                  return false;
                },
                builder: (context, state) {
                  if (state is! ExaminationLoaded) return const SizedBox();
                  return AppAdvancedFilterDrawer(
                    currentSortOrder: state.sortOrder,
                    onSortOrderChanged: (sort) => cubit.updateFilters(sortOrder: sort),
                    currentDateRange: state.dateRangePreset,
                    onDateRangeChanged: (range) => cubit.updateFilters(dateRangePreset: range),
                    onApply: () {},
                    onClear: () => cubit.updateFilters(
                      searchQuery: '',
                      sortOrder: AppSortOrder.newest,
                      dateRangePreset: AppDateRangePreset.all,
                    ),
                  );
                },
              ),
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExaminationCubit>();
    _registerDrawer(ref, cubit);

    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        if (state is ExaminationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Examination> examinations = [];
        final loadedState = state is ExaminationLoaded ? state : null;
        if (loadedState != null) {
          examinations = loadedState.filteredExaminations;
          
          // Initialize expanded states if needed
          if (_isExpanded.length != examinations.length) {
            _isExpanded.clear();
            _isExpanded.addAll(List.generate(examinations.length, (index) => index == 0));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lịch sử Khám bệnh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng cộng ${examinations.length} lượt khám',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Bar
            AppDashboardFilterBar(
              searchHint: 'Tìm kiếm theo chẩn đoán, triệu chứng...',
              initialSearchValue: loadedState?.searchQuery ?? '',
              onSearchChanged: (v) => cubit.setSearchQuery(v),
              onFilterPressed: () => Scaffold.of(context).openEndDrawer(),
              hasActiveFilters: loadedState?.dateRangePreset != AppDateRangePreset.all,
            ),
            const SizedBox(height: 32),
            
            // Timeline List
            if (examinations.isEmpty) 
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: examinations.length,
                itemBuilder: (context, index) {
                  return _buildTimelineItem(examinations[index], index);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem(Examination exam, int index) {
    final expanded = _isExpanded[index];
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.briefcase, size: 16, color: AppColors.primaryBlue),
              ),
              if (index < _isExpanded.length - 1)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy - HH:mm').format(exam.createdAt),
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded[index] = !expanded;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  expanded ? 'Thu gọn' : 'Xem chi tiết',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  expanded ? LucideIcons.chevronUp : LucideIcons.chevronRight,
                                  size: 16,
                                  color: AppColors.primaryBlue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Bác sĩ ID: ${exam.doctorId}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'KHÁM BỆNH',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Chẩn đoán: ',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            TextSpan(
                              text: exam.preliminaryDiagnosis ?? 'Chưa có chẩn đoán',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (expanded) ...[
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 24),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel('TRIỆU CHỨNG LÂM SÀNG'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Vị trí: ${exam.symptomLocation ?? "N/A"}\nThời gian: ${exam.symptomDuration ?? "N/A"}\nMức độ: ${exam.symptomSeverity ?? "N/A"}',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel('TIỀN SỬ & DỊ ỨNG'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bệnh sử: ${exam.medicalHistory ?? "Không"}\nDị ứng: ${exam.allergies ?? "Không"}\nThuốc đang dùng: ${exam.currentMedications ?? "Không"}',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel('KẾT LUẬN'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chẩn đoán ICD: ${exam.icdCode ?? "N/A"}\nKết luận: ${exam.conclusion ?? "N/A"}',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel('HƯỚNG ĐIỀU TRỊ'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kế hoạch: ${exam.treatmentPlan ?? "N/A"}\nGhi chú thuốc: ${exam.medicationNotes ?? "N/A"}',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (exam.followUpDate != null) ...[
                          const SizedBox(height: 24),
                          _buildSectionLabel('HẸN TÁI KHÁM'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(exam.followUpDate!),
                                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (exam.priorityFollowUp) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ƯU TIÊN',
                                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Icon(LucideIcons.history, size: 64, color: AppColors.border.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch sử khám bệnh phù hợp',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
