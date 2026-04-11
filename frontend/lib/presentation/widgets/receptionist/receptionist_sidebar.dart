import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ReceptionistSidebar extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int>? onItemTap;

  const ReceptionistSidebar({
    super.key,
    this.activeIndex = 0,
    this.onItemTap,
  });

  @override
  State<ReceptionistSidebar> createState() => _ReceptionistSidebarState();
}

class _ReceptionistSidebarState extends State<ReceptionistSidebar>
    with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;

  static const _items = [
    _NavItem(icon: LucideIcons.layoutDashboard, title: 'Tổng quan', index: 0),
    _NavItem(icon: LucideIcons.users, title: 'Bệnh nhân', index: 1),
    _NavItem(icon: LucideIcons.calendarDays, title: 'Lịch khám', index: 2),
  ];

  @override
  Widget build(BuildContext context) {
    final double w = _isCollapsed ? 64 : 230;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: w,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo / Toggle row ──
          Padding(
            padding: EdgeInsets.fromLTRB(
              _isCollapsed ? 12 : 20,
              24,
              _isCollapsed ? 12 : 16,
              12,
            ),
            child: Row(
              children: [
                // Logo icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, Color(0xFF4A9DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.activity,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                // Branding — hidden when collapsed
                if (!_isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'MedCore',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Tiếp nhận',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Toggle button
                _CollapseToggle(
                  isCollapsed: _isCollapsed,
                  onTap: () => setState(() => _isCollapsed = !_isCollapsed),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: _isCollapsed ? 10 : 16),
            child: const Divider(color: AppColors.border, height: 20),
          ),

          // Menu label — hidden when collapsed
          if (!_isCollapsed)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Text(
                'MENU CHÍNH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPlaceholder,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          // Nav items
          ..._items.map(
            (item) => _buildNavItem(item, widget.activeIndex == item.index),
          ),

          const Spacer(),

          // Divider + Profile
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _isCollapsed ? 10 : 16),
            child: const Divider(color: AppColors.border, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _isCollapsed
                ? Tooltip(
                    message: 'Lê Thị Lan • Lễ tân',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryBlue,
                      child: const Text(
                        'L',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : _buildProfileExpanded(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isCollapsed ? 8 : 10,
        vertical: 2,
      ),
      child: Tooltip(
        message: _isCollapsed ? item.title : '',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => widget.onItemTap?.call(item.index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: _isCollapsed ? 0 : 12,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.activeBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? Border.all(color: AppColors.primaryBlue.withAlpha(30))
                    : null,
              ),
              child: _isCollapsed
                  ? Center(
                      child: Icon(
                        item.icon,
                        color: isActive
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    )
                  : Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isActive
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.primaryBlue
                                  : AppColors.textSecondary,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileExpanded() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.activeBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.primaryBlue,
            child: const Text(
              'L',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lê Thị Lan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Lễ tân',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.logOut, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ── Collapse toggle button ──
class _CollapseToggle extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onTap;

  const _CollapseToggle({required this.isCollapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.border.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCollapsed ? LucideIcons.panelLeftOpen : LucideIcons.panelLeftClose,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Data holder ──
class _NavItem {
  final IconData icon;
  final String title;
  final int index;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}
