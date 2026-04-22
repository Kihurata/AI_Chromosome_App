import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/nav_item.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/nav_provider.dart';
import '../../../core/theme/app_colors.dart';

// Breakpoint: screens wider than this use NavigationRail
const double _kRailBreakpoint = 800.0;

/// Responsive navigation wrapper.
/// - Wide screen  (≥800px): NavigationRail on the left
/// - Narrow screen (<800px): BottomNavigationBar + Drawer
class AppNavigationWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppNavigationWrapper({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<AppNavigationWrapper> createState() =>
      _AppNavigationWrapperState();
}

class _AppNavigationWrapperState extends ConsumerState<AppNavigationWrapper>
    with SingleTickerProviderStateMixin {
  bool _isRailExtended = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _railAnim;

  @override
  void initState() {
    super.initState();
    _railAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _railAnim.dispose();
    super.dispose();
  }

  void _toggleRail() {
    setState(() => _isRailExtended = !_isRailExtended);
    if (_isRailExtended) {
      _railAnim.forward();
    } else {
      _railAnim.reverse();
    }
  }

  // Find selected index from current route in nav items
  int _selectedIndex(List<NavItem> items) {
    final idx = items.indexWhere(
      (item) => widget.currentRoute.startsWith(item.routePath),
    );
    return idx < 0 ? 0 : idx;
  }

  void _onItemSelected(List<NavItem> items, int index) {
    if (index >= 0 && index < items.length) {
      context.go(items[index].routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = ref.watch(filteredNavItemsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kRailBreakpoint;
        final selectedIdx = _selectedIndex(navItems);

        if (isWide) {
          return _WideLayout(
            navItems: navItems,
            selectedIndex: selectedIdx,
            isExtended: _isRailExtended,
            onItemSelected: (i) => _onItemSelected(navItems, i),
            onToggleRail: _toggleRail,
            child: widget.child,
          );
        } else {
          return _NarrowLayout(
            scaffoldKey: _scaffoldKey,
            navItems: navItems,
            selectedIndex: selectedIdx,
            onItemSelected: (i) {
              Navigator.of(context).pop(); // close drawer if open
              _onItemSelected(navItems, i);
            },
            child: widget.child,
          );
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDE LAYOUT: NavigationRail
// ─────────────────────────────────────────────────────────────────────────────
class _WideLayout extends ConsumerWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final bool isExtended;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onToggleRail;
  final Widget child;

  const _WideLayout({
    required this.navItems,
    required this.selectedIndex,
    required this.isExtended,
    required this.onItemSelected,
    required this.onToggleRail,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── NavigationRail Panel ──────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: isExtended ? 230 : 72,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                right: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo + toggle
                _RailHeader(
                  isExtended: isExtended,
                  onToggle: onToggleRail,
                ),
                const Divider(height: 1, color: AppColors.border),

                // Nav items
                Expanded(
                  child: NavigationRail(
                    extended: isExtended,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onItemSelected,
                    backgroundColor: Colors.transparent,
                    minWidth: 72,
                    minExtendedWidth: 230,
                    useIndicator: true,
                    indicatorColor: AppColors.activeBackground,
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    destinations: navItems
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Tooltip(
                              message: isExtended ? '' : (item.tooltip ?? item.label),
                              child: Icon(item.icon),
                            ),
                            selectedIcon: Tooltip(
                              message: isExtended ? '' : (item.tooltip ?? item.label),
                              child: Icon(item.activeIcon ?? item.icon),
                            ),
                            label: Text(item.label),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // Profile footer
                const Divider(height: 1, color: AppColors.border),
                _ProfileTile(auth: auth, isExpanded: isExtended),
              ],
            ),
          ),
          // ── Main Content ─────────────────────────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NARROW LAYOUT: BottomNavigationBar + Drawer
// ─────────────────────────────────────────────────────────────────────────────
class _NarrowLayout extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Widget child;

  const _NarrowLayout({
    required this.scaffoldKey,
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    // Show max 5 items in bottom bar; rest go into drawer
    final bottomItems = navItems.take(4).toList();
    final drawerItems = navItems;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.menu, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xFF4A9DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.activity, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'MedCore',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: _AppDrawer(
        navItems: drawerItems,
        selectedIndex: selectedIndex,
        auth: auth,
        onItemSelected: onItemSelected,
      ),
      bottomNavigationBar: bottomItems.isEmpty
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: selectedIndex.clamp(0, bottomItems.length - 1),
                onTap: onItemSelected,
                backgroundColor: AppColors.surface,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: AppColors.textSecondary,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                items: bottomItems
                    .map(
                      (item) => BottomNavigationBarItem(
                        icon: Icon(item.icon, size: 20),
                        activeIcon: Icon(item.activeIcon ?? item.icon, size: 20),
                        label: item.label,
                        tooltip: item.tooltip ?? item.label,
                      ),
                    )
                    .toList(),
              ),
            ),
      body: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _RailHeader extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onToggle;

  const _RailHeader({required this.isExtended, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isExtended ? 20 : 12,
        20,
        isExtended ? 12 : 12,
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
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
            child: const Icon(LucideIcons.activity, color: Colors.white, size: 18),
          ),
          if (isExtended) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'MedCore',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Hospital CRM',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onToggle,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.border.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExtended
                      ? LucideIcons.panelLeftClose
                      : LucideIcons.panelLeftOpen,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends ConsumerWidget {
  final AuthSnapshot auth;
  final bool isExpanded;

  const _ProfileTile({required this.auth, required this.isExpanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isExpanded) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Tooltip(
          message: '${auth.displayName} • ${auth.role?.displayName ?? ''}',
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              auth.userInitial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.activeBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                auth.userInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    auth.role?.displayName ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Logout handled via auth cubit
                context.go('/login');
              },
              child: const Icon(
                LucideIcons.logOut,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final AuthSnapshot auth;
  final ValueChanged<int> onItemSelected;

  const _AppDrawer({
    required this.navItems,
    required this.selectedIndex,
    required this.auth,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, Color(0xFF4A9DFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.activity, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'MedCore',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Hospital CRM',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),

            // Menu items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final isActive = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onItemSelected(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.activeBackground
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isActive
                                    ? (item.activeIcon ?? item.icon)
                                    : item.icon,
                                size: 20,
                                color: isActive
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.primaryBlue
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Profile footer
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      auth.userInitial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          auth.role?.displayName ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    color: AppColors.textSecondary,
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

