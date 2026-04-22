import 'package:flutter/material.dart';

/// All roles that exist in the system (matches Firestore `users.role` field)
enum AppRole {
  manager,
  clinician,
  specialist,
  receptionist;

  /// Parse from Firestore string value
  static AppRole fromString(String value) {
    return AppRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => AppRole.receptionist,
    );
  }

  String get displayName {
    switch (this) {
      case AppRole.manager:
        return 'Quản lý';
      case AppRole.clinician:
        return 'Bác sĩ lâm sàng';
      case AppRole.specialist:
        return 'Bác sĩ chuyên khoa';
      case AppRole.receptionist:
        return 'Lễ tân';
    }
  }
}

/// Data model for a single navigation item.
/// This is the Single Source of Truth — no if/else in UI.
class NavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String routePath;
  final List<AppRole> allowedRoles;
  final String? tooltip;

  const NavItem({
    required this.label,
    required this.icon,
    required this.routePath,
    required this.allowedRoles,
    this.activeIcon,
    this.tooltip,
  });

  /// Whether a given role can see/access this item
  bool isAllowedFor(AppRole role) => allowedRoles.contains(role);
}

