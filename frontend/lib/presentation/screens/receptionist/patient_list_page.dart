import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/drawer_provider.dart';
import '../../../core/models/filter_options.dart';
import '../../../data/models/patient_model.dart';
import '../../../domain/entities/patient.dart';
import '../../../logic/bloc/patient/patient_cubit.dart';
import '../../../logic/bloc/patient/patient_state.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/shared/data_display/app_data_table.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../widgets/shared/form/dashboard_filter_bar.dart';
import '../../widgets/shared/filter/advanced_filter_drawer.dart';
import '../patient_detail/patient_detail_screen.dart';
import 'patient_registration_page.dart';

class PatientListPage extends ConsumerStatefulWidget {
  const PatientListPage({super.key});

  @override
  ConsumerState<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends ConsumerState<PatientListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientCubit>().loadPatients();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<PatientCubit>();
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
    // NOTE: Do NOT call FocusScope.of(context) here — context is already
    // deactivated during dispose(), causing "Looking up a deactivated widget's
    // ancestor is unsafe". Flutter unfocuses automatically on navigation.
    // Clear global drawer when leaving the page
    Future.microtask(() {
      _container.read(drawerProvider.notifier).clear();
    });
    super.dispose();
  }

  bool _isDrawerRegistered = false;

  void _registerDrawer(WidgetRef ref, PatientCubit cubit) {
    if (_isDrawerRegistered) return;
    _isDrawerRegistered = true;

    ref.read(drawerProvider.notifier).update(
          endDrawer: BlocProvider.value(
            value: cubit,
            child: BlocBuilder<PatientCubit, PatientState>(
              buildWhen: (p, c) {
                if (p is PatientLoaded && c is PatientLoaded) {
                  return p.sortOrder != c.sortOrder || p.dateRangePreset != c.dateRangePreset;
                }
                return false;
              },
              builder: (context, state) {
                if (state is! PatientLoaded) return const SizedBox();
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
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PatientCubit>();

    return MainListLayout(
      title: 'Danh sách bệnh nhân',
      subtitle: 'Quản lý hồ sơ và lịch sử khám bệnh',
      headerActions: [
        AppPrimaryButton(
          text: 'Thêm bệnh nhân',
          icon: LucideIcons.plus,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
          ),
        ),
      ],
      onRefresh: () async => cubit.loadPatients(),
      child: BlocListener<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<PatientCubit, PatientState>(
          builder: (context, state) {
            final loadedState = state is PatientLoaded ? state : null;
            final patients = loadedState?.filteredPatients ?? [];

            return Padding(
              padding: const EdgeInsets.all(28.0),
              child: AppDataTable(
                customHeader: AppDashboardFilterBar(
                  searchHint: 'Tìm theo tên, SĐT hoặc mã BN...',
                  initialSearchValue: loadedState?.searchQuery ?? '',
                  onSearchChanged: (v) => cubit.setSearchQuery(v),
                  onFilterPressed: () => Scaffold.of(context).openEndDrawer(),
                  hasActiveFilters: loadedState?.dateRangePreset != AppDateRangePreset.all,
                ),
                isLoading: state is PatientLoading,
                headerRow: const _PatientTableHeader(),
                emptyState: _EmptyPatients(onAdd: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
                )),
                rows: patients.map((p) => _PatientRow(
                  patient: p,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: PatientModel.fromEntity(p))),
                  ),
                )).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatientTableHeader extends StatelessWidget {
  const _PatientTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
    return const Row(
      children: [
        SizedBox(width: 44),
        Expanded(flex: 3, child: Text('HỌ TÊN', style: style)),
        Expanded(flex: 2, child: Text('MÃ BN', style: style)),
        Expanded(flex: 2, child: Text('SĐT', style: style)),
        Expanded(flex: 2, child: Text('NGÀY SINH', style: style)),
        Expanded(flex: 1, child: Text('GIỚI TÍNH', style: style)),
        Expanded(flex: 1, child: Text('THAO TÁC', style: style, textAlign: TextAlign.center)),
      ],
    );
  }
}

class _PatientRow extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const _PatientRow({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: UIUtils.getAvatarColor(patient.fullName),
            child: Text(
              UIUtils.getInitials(patient.fullName),
              style: TextStyle(color: UIUtils.getAvatarTextColor(patient.fullName), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(patient.patientCode ?? '---', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text(patient.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Text(UIUtils.formatDate(patient.dob), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(flex: 1, child: _GenderBadge(gender: patient.gender)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onTap,
                  icon: const Icon(LucideIcons.eye, size: 18, color: AppColors.primaryBlue),
                  tooltip: 'Xem bệnh án',
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PatientRegistrationPage(patient: patient),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.edit2, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Chỉnh sửa thông tin',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderBadge extends StatelessWidget {
  final String gender;
  const _GenderBadge({required this.gender});

  @override
  Widget build(BuildContext context) {
    final isNam = gender == 'Nam';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNam ? AppColors.activeBackground : const Color(0xFFFCE7F3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        gender,
        style: TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.w600, 
          color: isNam ? AppColors.primaryBlue : const Color(0xFFDB2777),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPatients({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Icon(LucideIcons.userX, size: 48, color: AppColors.textPlaceholder.withAlpha(120)),
          const SizedBox(height: 16),
          const Text('Chưa có bệnh nhân nào', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          AppPrimaryButton(text: 'Thêm bệnh nhân', icon: LucideIcons.plus, onPressed: onAdd),
        ],
      ),
    );
  }
}
