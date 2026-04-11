import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/clinical_repository.dart';
import 'patient_registration_page.dart';
import 'patient_detail_page.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
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
                // Search
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên, SĐT, CCCD hoặc mã BN...',
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
                // Stats
                StreamBuilder<List<PatientModel>>(
                  stream: _clinicalRepo.getAllPatients(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!.length : 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.activeBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.users, size: 14, color: AppColors.primaryBlue),
                          const SizedBox(width: 6),
                          Text('$count bệnh nhân', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Patient Table
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
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFBFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    border:
                        Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 44),
                      Expanded(
                        flex: 3,
                        child: _buildSortableHeader(
                            'HỌ TÊN', 'full_name'),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildSortableHeader(
                            'MÃ BN', 'patient_code'),
                      ),
                      Expanded(
                          flex: 2,
                          child: _buildStaticHeader('SĐT')),
                      Expanded(
                          flex: 2,
                          child: _buildStaticHeader('CCCD')),
                      Expanded(
                        flex: 2,
                        child: _buildSortableHeader(
                            'NGÀY SINH', 'dob'),
                      ),
                      Expanded(
                          flex: 1,
                          child: _buildStaticHeader('GIỚI TÍNH')),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),

                // Data Rows
                StreamBuilder<List<PatientModel>>(
                  stream: _clinicalRepo.getAllPatients(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(60),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(LucideIcons.userX, size: 48, color: AppColors.textPlaceholder.withAlpha(120)),
                              const SizedBox(height: 16),
                              const Text('Chưa có bệnh nhân nào', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
                                ),
                                icon: const Icon(LucideIcons.plus, size: 16),
                                label: const Text('Thêm bệnh nhân đầu tiên'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Filter by search query
                    var patients = snapshot.data!.where((p) {
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
                          cmp = (a.patientCode ?? '').compareTo(
                              b.patientCode ?? '');
                          break;
                        default:
                          cmp = a.fullName
                              .toLowerCase()
                              .compareTo(b.fullName.toLowerCase());
                      }
                      return _sortAscending ? cmp : -cmp;
                    });

                    if (patients.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(LucideIcons.searchX, size: 40, color: AppColors.textPlaceholder),
                              const SizedBox(height: 12),
                              Text('Không tìm thấy kết quả cho "$_searchQuery"', style: const TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: patients.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final p = entry.value;
                        final isLast = idx == patients.length - 1;
                        return _PatientRowItem(
                          patient: p,
                          isLast: isLast,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PatientDetailPage(patient: p),
                            ),
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
              ],
            ),
          ),
        ],
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
