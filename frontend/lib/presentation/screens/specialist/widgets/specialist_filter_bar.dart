import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/specialist/specialist_dashboard_cubit.dart';
import '../../../../logic/bloc/specialist/specialist_dashboard_state.dart';
import '../../../../core/models/filter_options.dart';
import '../../../widgets/shared/form/dashboard_filter_bar.dart';

class SpecialistFilterBar extends StatelessWidget {
  const SpecialistFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpecialistDashboardCubit, SpecialistDashboardState>(
      buildWhen: (p, c) => 
          p.searchKeyword != c.searchKeyword || 
          p.sortOrder != c.sortOrder || 
          p.dateRangePreset != c.dateRangePreset ||
          p.statusFilter != c.statusFilter,
      builder: (context, state) {
        return AppDashboardFilterBar(
          searchHint: 'Tìm kiếm theo tên hoặc mã bệnh nhân...',
          initialSearchValue: state.searchKeyword,
          onSearchChanged: (value) =>
              context.read<SpecialistDashboardCubit>().setSearchKeyword(value),
          onFilterPressed: () => Scaffold.of(context).openEndDrawer(),
          hasActiveFilters: state.statusFilter != null || 
              state.dateRangePreset != AppDateRangePreset.all,
        );
      },
    );
  }
}
