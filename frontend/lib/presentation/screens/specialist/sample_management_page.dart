import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/drawer_provider.dart';
import '../../../../core/models/filter_options.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../logic/bloc/specialist/sample_management_cubit.dart';
import '../../../../logic/bloc/specialist/sample_management_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/shared/form/dashboard_filter_bar.dart';
import '../../widgets/shared/filter/advanced_filter_drawer.dart';
import 'widgets/sample_card.dart';

class SampleManagementPage extends ConsumerStatefulWidget {
  const SampleManagementPage({super.key});

  @override
  ConsumerState<SampleManagementPage> createState() => _SampleManagementPageState();
}

class _SampleManagementPageState extends ConsumerState<SampleManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<SampleManagementCubit>().loadSamples();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<SampleManagementCubit>();
      _registerDrawer(ref, cubit);
    });
  }

  late ProviderContainer _container;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context);
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    Future.microtask(() {
      _container.read(drawerProvider.notifier).clear();
    });
    super.dispose();
  }

  bool _isDrawerRegistered = false;

  void _registerDrawer(WidgetRef ref, SampleManagementCubit cubit) {
    if (_isDrawerRegistered) return;
    _isDrawerRegistered = true;

    ref.read(drawerProvider.notifier).update(
          endDrawer: BlocProvider.value(
            value: cubit,
            child: BlocBuilder<SampleManagementCubit, SampleManagementState>(
              buildWhen: (p, c) => p.sortOrder != c.sortOrder || p.dateRangePreset != c.dateRangePreset,
              builder: (context, state) {
                return AppAdvancedFilterDrawer(
                  currentSortOrder: state.sortOrder,
                  onSortOrderChanged: (sort) => cubit.updateFilters(sortOrder: sort),
                  currentDateRange: state.dateRangePreset,
                  onDateRangeChanged: (range) => cubit.updateFilters(dateRangePreset: range),
                  onApply: () {},
                  onClear: () => cubit.updateFilters(
                    searchKeyword: '',
                    clearStatusFilter: true,
                    sortOrder: AppSortOrder.newest,
                    dateRangePreset: AppDateRangePreset.all,
                  ),
                );
              },
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SampleManagementCubit>();

    return BlocListener<SampleManagementCubit, SampleManagementState>(
      listenWhen: (p, c) => c.lastStartedOrderId != null,
      listener: (context, state) {
        if (state.lastStartedOrderId != null) {
          if (!context.mounted) return;
          final orderId = state.lastStartedOrderId!;
          cubit.clearNavigation();
          context.push('${AppRoutes.specialistAnalysis}/$orderId');
        }
      },
      child: MainListLayout(
        title: 'Quản lý Mẫu Bệnh phẩm',
        subtitle: 'Theo dõi tiến độ nuôi cấy và quản lý mẫu xét nghiệm.',
        onRefresh: () async => cubit.loadSamples(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernFilterBar(),
              const SizedBox(height: 24),
              _buildSampleList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterBar() {
    return BlocBuilder<SampleManagementCubit, SampleManagementState>(
      buildWhen: (p, c) => 
          p.searchKeyword != c.searchKeyword || 
          p.filterStatus != c.filterStatus ||
          p.dateRangePreset != c.dateRangePreset,
      builder: (context, state) {
        return Column(
          children: [
            AppDashboardFilterBar(
              searchHint: 'Tìm theo tên bệnh nhân, mã mẫu...',
              initialSearchValue: state.searchKeyword,
              onSearchChanged: (v) => context.read<SampleManagementCubit>().setSearchKeyword(v),
              onFilterPressed: () => Scaffold.of(context).openEndDrawer(),
              hasActiveFilters: state.filterStatus != null || state.dateRangePreset != AppDateRangePreset.all,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Tất cả',
                    isSelected: state.filterStatus == null,
                    onSelected: () =>
                        context.read<SampleManagementCubit>().setFilter(null),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: 'Mới thu nhận',
                    isSelected: state.filterStatus == SampleStatus.collected,
                    onSelected: () => context
                        .read<SampleManagementCubit>()
                        .setFilter(SampleStatus.collected),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: 'Đang nuôi cấy',
                    isSelected: state.filterStatus == SampleStatus.culturing,
                    onSelected: () => context
                        .read<SampleManagementCubit>()
                        .setFilter(SampleStatus.culturing),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: 'Đã thu hoạch',
                    isSelected: state.filterStatus == SampleStatus.harvested,
                    onSelected: () => context
                        .read<SampleManagementCubit>()
                        .setFilter(SampleStatus.harvested),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: 'Thất bại',
                    isSelected: state.filterStatus == SampleStatus.failed,
                    onSelected: () => context
                        .read<SampleManagementCubit>()
                        .setFilter(SampleStatus.failed),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSampleList() {
    return BlocBuilder<SampleManagementCubit, SampleManagementState>(
      builder: (context, state) {
        if (state.status == SampleManagementStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.filteredSamples.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 64),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.package,
                  size: 64,
                  color: AppColors.textPlaceholder.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không tìm thấy mẫu nào phù hợp',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header row ──────────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Mã mẫu & Loại',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Bệnh nhân',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Ngày thu nhận',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Trạng thái',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Hành động',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Data rows ────────────────────────────────────────────────
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.filteredSamples.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final sample = state.filteredSamples[index];
                    return SampleCard(
                      sample: sample,
                      onStatusUpdate: (status) {
                        context.read<SampleManagementCubit>().updateStatus(
                          sample.id,
                          status,
                        );
                      },
                      onFailure: (reason) {
                        context.read<SampleManagementCubit>().updateNote(
                          sample.id,
                          reason,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
