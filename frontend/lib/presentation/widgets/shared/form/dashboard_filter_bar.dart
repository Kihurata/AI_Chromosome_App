import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'app_text_field.dart';
import 'app_buttons.dart';

class AppDashboardFilterBar extends StatelessWidget {
  final String searchHint;
  final String initialSearchValue;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final bool hasActiveFilters;

  const AppDashboardFilterBar({
    super.key,
    this.searchHint = 'Tìm kiếm...',
    this.initialSearchValue = '',
    required this.onSearchChanged,
    required this.onFilterPressed,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 88,
            child: AppTextField(
              hintText: searchHint,
              prefixIcon: LucideIcons.search,
              initialValue: initialSearchValue,
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 12,
            child: AppPrimaryButton(
              text: 'Bộ lọc',
              icon: LucideIcons.filter,
              onPressed: onFilterPressed,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              showBadge: hasActiveFilters,
            ),
          ),
        ],
      ),
    );
  }
}
