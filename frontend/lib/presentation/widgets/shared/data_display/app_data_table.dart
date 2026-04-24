import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class AppDataTable extends StatelessWidget {
  final String searchHint;
  final String countText;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final Widget headerRow;
  final List<Widget> rows;
  final Widget? emptyState;
  final bool isLoading;

  const AppDataTable({
    super.key,
    required this.searchHint,
    required this.countText,
    this.searchController,
    this.onSearchChanged,
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
        // Search + Filter Bar
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
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: searchHint,
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textPlaceholder),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Icon(LucideIcons.search, size: 16, color: AppColors.textPlaceholder),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: AppColors.border.withAlpha(50),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                    ),
                  ),
                ),
              ),
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
                    Text(countText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (rows.isEmpty && emptyState != null)
                emptyState!
              else
                Column(children: rows),
            ],
          ),
        ),
      ],
    );
  }
}
