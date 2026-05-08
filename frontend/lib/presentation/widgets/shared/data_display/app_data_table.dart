import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../form/app_text_field.dart';

class AppDataTable extends StatelessWidget {
  final String? searchHint;
  final String? countText;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final Widget? customHeader;
  final Widget headerRow;
  final List<Widget> rows;
  final Widget? emptyState;
  final bool isLoading;

  const AppDataTable({
    super.key,
    this.searchHint,
    this.countText,
    this.searchController,
    this.onSearchChanged,
    this.customHeader,
    required this.headerRow,
    required this.rows,
    this.emptyState,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search + Filter Bar or Custom Header
        if (customHeader != null)
          customHeader!
        else if (searchHint != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    hintText: searchHint!,
                    prefixIcon: LucideIcons.search,
                  ),
                ),
                if (countText != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.activeBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.list, size: 14, color: AppColors.primaryBlue),
                        const SizedBox(width: 6),
                        Text(countText!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        
        if (customHeader != null || searchHint != null)
          const SizedBox(height: 20),
        
        // Table Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: headerRow,
              ),
              // Body
              isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : rows.isEmpty && emptyState != null
                        ? Center(child: SingleChildScrollView(child: emptyState!))
                        : SingleChildScrollView(
                            child: Column(children: rows),
                          ),
            ],
          ),
        ),
    ],
  );
  }
}
