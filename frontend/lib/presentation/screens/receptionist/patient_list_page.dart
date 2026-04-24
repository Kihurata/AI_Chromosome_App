import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/clinical_repository.dart';
import 'patient_registration_page.dart';
import '../patient_detail/patient_detail_screen.dart';

import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/shared/data_display/app_data_table.dart';
import '../../widgets/shared/form/app_buttons.dart';

class PatientListPage extends StatefulWidget {
  final ClinicalRepository? repository;
  const PatientListPage({super.key, this.repository});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  late final ClinicalRepository _clinicalRepo;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sort state
  String _sortColumn = 'full_name'; // 'full_name' | 'dob' | 'patient_code'
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _clinicalRepo = widget.repository ?? ClinicalRepository();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainListLayout(
      title: 'Bệnh nhân',
      subtitle: 'Quản lý hồ sơ và thông tin bệnh nhân',
      headerActions: [
        AppPrimaryButton(
          text: 'Thêm bệnh nhân',
          icon: LucideIcons.plus,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: StreamBuilder<List<PatientModel>>(
          stream: _clinicalRepo.getAllPatients(),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final count = snapshot.hasData ? snapshot.data!.length : 0;

            // Filter
            var patients = <PatientModel>[];
            if (snapshot.hasData) {
              patients = snapshot.data!.where((p) {
                if (_searchQuery.isEmpty) return true;
                return p.fullName.toLowerCase().contains(_searchQuery) ||
                    p.phone.contains(_searchQuery) ||
                    p.identityCard.contains(_searchQuery) ||
                    (p.patientCode ?? '').toLowerCase().contains(_searchQuery);
              }).toList();

              // Sort
              patients.sort((a, b) {
                int cmp;
                switch (_sortColumn) {
                  case 'dob':
                    cmp = a.dob.compareTo(b.dob);
                    break;
                  case 'patient_code':
                    cmp = (a.patientCode ?? '').compareTo(b.patientCode ?? '');
                    break;
                  default:
                    cmp = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
                }
                return _sortAscending ? cmp : -cmp;
              });
            }

            return AppDataTable(
              searchHint: 'Tìm theo tên, SĐT, CCCD hoặc mã BN...',
              countText: '$count bệnh nhân',
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              isLoading: isLoading,
              emptyState: Padding(
                padding: const EdgeInsets.all(60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty ? LucideIcons.searchX : LucideIcons.userX,
                        size: 48,
                        color: AppColors.textPlaceholder.withAlpha(120),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Không tìm thấy kết quả cho "$_searchQuery"'
                            : 'Chưa có bệnh nhân nào',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              headerRow: Row(
                children: [
                  const SizedBox(width: 44),
                  Expanded(flex: 3, child: _buildSortableHeader('HỌ TÊN', 'full_name')),
                  Expanded(flex: 2, child: _buildSortableHeader('MÃ BN', 'patient_code')),
                  Expanded(flex: 2, child: _buildStaticHeader('SĐT')),
                  Expanded(flex: 2, child: _buildStaticHeader('CCCD')),
                  Expanded(flex: 2, child: _buildSortableHeader('NGÀY SINH', 'dob')),
                  Expanded(flex: 1, child: _buildStaticHeader('GIỚI TÍNH')),
                  const SizedBox(width: 60),
                ],
              ),
              rows: patients.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                final isLast = idx == patients.length - 1;
                return _PatientRowItem(
                  patient: p,
                  isLast: isLast,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: p)),
                  ),
                  maskId: _maskIdentityCard,
                  initials: _getInitials(p.fullName),
                  avatarColor: _getAvatarColor(p.fullName),
                  textColor: _getTextColor(p.fullName),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  // ── Sortable header ──
  Widget _buildSortableHeader(String label, String column) {
    final isActive = _sortColumn == column;
    return InkWell(
      onTap: () => setState(() {
        if (_sortColumn == column) {
          _sortAscending = !_sortAscending;
        } else {
          _sortColumn = column;
          _sortAscending = true;
        }
      }),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? AppColors.primaryBlue
                  : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive
                ? (_sortAscending
                    ? LucideIcons.chevronUp
                    : LucideIcons.chevronDown)
                : LucideIcons.chevronsUpDown,
            size: 12,
            color: isActive
                ? AppColors.primaryBlue
                : AppColors.textPlaceholder,
          ),
        ],
      ),
    );
  }

  Widget _buildStaticHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  String _maskIdentityCard(String id) {
    if (id.length <= 4) return id;
    return '${id.substring(0, 4)}${'*' * (id.length - 4)}';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) return (parts[0][0] + parts.last[0]).toUpperCase();
    return parts[0][0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue[50]!,
      Colors.teal[50]!,
      Colors.green[50]!,
      Colors.orange[50]!,
      Colors.red[50]!
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  Color _getTextColor(String name) {
    final colors = [
      Colors.blue[800]!,
      Colors.teal[800]!,
      Colors.green[800]!,
      Colors.orange[800]!,
      Colors.red[800]!
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _PatientRowItem extends StatefulWidget {
  final PatientModel patient;
  final bool isLast;
  final VoidCallback onTap;
  final String Function(String) maskId;
  final String initials;
  final Color avatarColor;
  final Color textColor;

  const _PatientRowItem({
    required this.patient,
    required this.isLast,
    required this.onTap,
    required this.maskId,
    required this.initials,
    required this.avatarColor,
    required this.textColor,
  });

  @override
  State<_PatientRowItem> createState() => _PatientRowItemState();
}

class _PatientRowItemState extends State<_PatientRowItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.activeBackground.withAlpha(120)
                : Colors.transparent,
            border: widget.isLast
                ? null
                : const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: widget.avatarColor,
                child: Text(
                  widget.initials,
                  style: TextStyle(
                      color: widget.textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _isHovered
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (p.address.isNotEmpty)
                      Text(
                        p.address,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textPlaceholder),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  p.patientCode ?? '---',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  p.phone.isNotEmpty ? p.phone : '---',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  p.identityCard.isNotEmpty
                      ? widget.maskId(p.identityCard)
                      : '---',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  DateFormat('dd/MM/yyyy').format(p.dob),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildGenderBadge(p.gender),
              ),
              SizedBox(
                width: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _isHovered ? 1.0 : 0.4,
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.eye,
                          size: 16,
                          color: _isHovered
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                        ),
                        onPressed: widget.onTap,
                        tooltip: 'Xem chi tiết',
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderBadge(String gender) {
    Color bg;
    Color text;
    if (gender == 'Nam') {
      bg = AppColors.activeBackground;
      text = AppColors.primaryBlue;
    } else if (gender == 'Nữ') {
      bg = const Color(0xFFFCE7F3);
      text = const Color(0xFFDB2777);
    } else {
      bg = AppColors.border.withAlpha(80);
      text = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        gender,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text),
        textAlign: TextAlign.center,
      ),
    );
  }
}

