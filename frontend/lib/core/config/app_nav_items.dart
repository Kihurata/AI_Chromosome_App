import 'package:lucide_icons/lucide_icons.dart';
import '../models/nav_item.dart';

/// Master navigation list — every role's menu items are defined here.
/// UI components consume this list and filter by role via Riverpod provider.
/// To add a new page, add ONE entry here — no other changes needed in the UI.
const List<NavItem> appNavItems = [
  // ── RECEPTIONIST ──────────────────────────────────────────────────────────
  NavItem(
    label: 'Tổng quan',
    icon: LucideIcons.layoutDashboard,
    routePath: '/receptionist/dashboard',
    allowedRoles: [AppRole.receptionist],
    tooltip: 'Tổng quan tiếp nhận',
  ),
  NavItem(
    label: 'Bệnh nhân',
    icon: LucideIcons.users,
    routePath: '/receptionist/patients',
    allowedRoles: [AppRole.receptionist],
    tooltip: 'Quản lý bệnh nhân',
  ),
  NavItem(
    label: 'Lịch khám',
    icon: LucideIcons.calendarDays,
    routePath: '/receptionist/appointments',
    allowedRoles: [AppRole.receptionist],
    tooltip: 'Lịch hẹn khám',
  ),

  // ── CLINICIAN ─────────────────────────────────────────────────────────────
  NavItem(
    label: 'Tổng quan',
    icon: LucideIcons.layoutDashboard,
    routePath: '/clinician/dashboard',
    allowedRoles: [AppRole.clinician],
    tooltip: 'Trang tổng quan',
  ),
  NavItem(
    label: 'Danh sách LK',
    icon: LucideIcons.calendar,
    routePath: '/clinician/appointments',
    allowedRoles: [AppRole.clinician],
    tooltip: 'Danh sách lịch khám',
  ),
  NavItem(
    label: 'Phòng Lab AI',
    icon: LucideIcons.microscope,
    routePath: '/clinician/lab',
    allowedRoles: [AppRole.clinician, AppRole.specialist],
    tooltip: 'Phòng Lab AI phân tích NST',
  ),

  // ── SPECIALIST ────────────────────────────────────────────────────────────
  NavItem(
    label: 'Tổng quan',
    icon: LucideIcons.layoutDashboard,
    routePath: '/specialist/dashboard',
    allowedRoles: [AppRole.specialist],
    tooltip: 'Trang tổng quan chuyên khoa',
  ),
  NavItem(
    label: 'Phân tích NST',
    icon: LucideIcons.dna,
    routePath: '/specialist/analysis',
    allowedRoles: [AppRole.specialist],
    tooltip: 'Phân tích karyotype',
  ),

  // ── MANAGER ───────────────────────────────────────────────────────────────
  NavItem(
    label: 'Điều phối Lab',
    icon: LucideIcons.layoutDashboard,
    routePath: '/manager/dashboard',
    allowedRoles: [AppRole.manager],
    tooltip: 'Điều phối và duyệt kết quả',
  ),
  NavItem(
    label: 'Báo cáo',
    icon: LucideIcons.barChart3,
    routePath: '/manager/reports',
    allowedRoles: [AppRole.manager],
    tooltip: 'Báo cáo thống kê',
  ),
  NavItem(
    label: 'Nhân viên',
    icon: LucideIcons.users2,
    routePath: '/manager/staff',
    allowedRoles: [AppRole.manager],
    tooltip: 'Quản lý nhân viên',
  ),

  // ── SHARED (all roles) ────────────────────────────────────────────────────
  NavItem(
    label: 'Hồ sơ',
    icon: LucideIcons.userCircle,
    routePath: '/profile',
    allowedRoles: [
      AppRole.manager,
      AppRole.clinician,
      AppRole.specialist,
      AppRole.receptionist,
    ],
    tooltip: 'Hồ sơ cá nhân',
  ),
];

/// Default landing route per role
String defaultRouteForRole(AppRole role) {
  switch (role) {
    case AppRole.receptionist:
      return '/receptionist/dashboard';
    case AppRole.clinician:
      return '/clinician/appointments';
    case AppRole.specialist:
      return '/specialist/dashboard';
    case AppRole.manager:
      return '/manager/dashboard';
  }
}

