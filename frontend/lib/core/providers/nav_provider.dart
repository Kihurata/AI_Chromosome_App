import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nav_item.dart';
import '../config/app_nav_items.dart';
import 'auth_provider.dart';

/// Filtered nav items for the currently authenticated user's role.
/// UI only needs to watch this — zero if/else in widgets.
final filteredNavItemsProvider = Provider<List<NavItem>>((ref) {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.role == null) return [];
  return appNavItems
      .where((item) => item.isAllowedFor(auth.role!))
      .toList();
});

/// The default landing route for the current user's role.
final defaultRouteProvider = Provider<String>((ref) {
  final auth = ref.watch(authNotifierProvider);
  if (auth.role == null) return '/login';
  return defaultRouteForRole(auth.role!);
});
