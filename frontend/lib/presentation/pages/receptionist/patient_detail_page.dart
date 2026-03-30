import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../widgets/shared/status_badge.dart';

class PatientDetailPage extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailPage({super.key, required this.patient});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _mockVisitHistory = [
    {
      'date': '05/10/2023',
      'time': '09:45',
      'doctor': 'BS. Nguyễn Tri Phương',
      'type': 'NGOẠI TRÚ',
      'diagnosis': 'VIÊM HỌNG CẤP (J02.9)',
      'reason': 'Đau họng kéo dài 3 ngày, có sốt nhẹ về chiều, nuốt vướng và mệt mỏi.',
      'vitals': {'pulse': '82 bpm', 'bp': '120/80 mmHg', 'temp': '37.5 °C', 'weight': '70 kg'},
      'symptoms': ['Niêm mạc họng đỏ rực', 'Amidan sưng nhẹ, không có giả mạc', 'Hạch góc hàm sưng đau'],
      'tests': ['Tổng phân tích máu', 'Nội soi TMH'],
      'prescriptions': [
        {'name': 'Augmentin 1g', 'qty': '14 viên', 'usage': 'Sáng 1, Chiều 1, sau ăn'},
        {'name': 'Paracetamol 500mg', 'qty': '10 viên', 'usage': 'Uống khi sốt > 38.5°C'},
      ],
      'notes': 'Nghỉ ngơi, súc miệng nước muối sinh lý thường xuyên. Tái khám sau 7 ngày hoặc khi có dấu hiệu bất thường.',
    },
    {
      'date': '12/03/2023',
      'time': '14:30',
      'doctor': 'BS. Trần Thị Lan',
      'type': 'TÁI KHÁM',
      'diagnosis': 'TĂNG HUYẾT ÁP ĐỘ 1 (I10)',
      'reason': 'Tái khám định kỳ theo lịch sử cao huyết áp.',
      'vitals': {'pulse': '76 bpm', 'bp': '135/85 mmHg', 'temp': '36.8 °C', 'weight': '72 kg'},
      'symptoms': ['Bệnh nhân khai không đau đầu, không chóng mặt', 'Sinh hiệu ổn định'],
      'tests': ['Đo điện tâm đồ (ECG)'],
      'prescriptions': [
        {'name': 'Amlodipine 5mg', 'qty': '30 viên', 'usage': 'Sáng 1 viên, trước ăn'},
      ],
      'notes': 'Ăn nhạt, vận động nhẹ nhàng. Theo dõi HA tại nhà.',
    },
    {
      'date': '15/11/2022',
      'time': '08:15',
      'doctor': 'BS. Lê Văn Hải',
      'type': 'CẤP CỨU',
      'diagnosis': 'VIÊM PHỔI NẶNG (J18.0)',
      'reason': 'Sốt cao, ho nhiều đờm đục, khó thở nhẹ.',
      'vitals': {'pulse': '105 bpm', 'bp': '130/80 mmHg', 'temp': '39.2 °C', 'weight': '69 kg'},
      'symptoms': ['Sốt cao liên tục', 'Khó thở nhịp thở 24 lần/phút', 'Phổi rải rác rales ẩm'],
      'tests': ['X-Quang tim phổi', 'Xét nghiệm máu tổng quát'],
      'prescriptions': [
        {'name': 'Levofloxacin 500mg', 'qty': '10 chai', 'usage': 'Truyền tĩnh mạch (Nội trú)'},
      ],
      'notes': 'Theo dõi sát diễn tiến hô hấp. Nhập viện nội trú.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Chi tiết bệnh nhân', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Card
            _buildProfileHeader(),
            const SizedBox(height: 30),

            // Custom TabBar
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Thông tin Chi tiết'),
                  Tab(text: 'Lịch sử Khám bệnh'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // TabBarView Content
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return _tabController.index == 0
                    ? _buildPatientInfoTab()
                    : _buildVisitHistoryTab();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.patient.fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 14),
                    StatusBadge(
                      text: widget.patient.patientCode?.isNotEmpty == true ? widget.patient.patientCode! : 'Chưa có Mã BN',
                      type: BadgeType.success,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.phone, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      widget.patient.phone.isNotEmpty ? widget.patient.phone : 'Không có số điện thoại',
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions on the right if needed, e.g., Edit
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.edit2, size: 14),
            label: const Text('Chỉnh sửa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoTab() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin chung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('Mã Bệnh Nhân', widget.patient.patientCode ?? '---'),
                    _buildInfoRow('Họ và Tên', widget.patient.fullName),
                    _buildInfoRow('Giới tính', widget.patient.gender),
                    _buildInfoRow('Ngày sinh', DateFormat('dd/MM/yyyy').format(widget.patient.dob)),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('CCCD/CMND', widget.patient.identityCard.isNotEmpty ? widget.patient.identityCard : '---'),
                    _buildInfoRow('Số điện thoại', widget.patient.phone.isNotEmpty ? widget.patient.phone : '---'),
                    _buildInfoRow('Địa chỉ', widget.patient.address.isNotEmpty ? widget.patient.address : '---'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 32),
          const Text('Người liên hệ khẩn cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoRow('Họ tên', widget.patient.emergencyContactName.isNotEmpty ? widget.patient.emergencyContactName : '---'),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: _buildInfoRow('Số điện thoại', widget.patient.emergencyContactPhone.isNotEmpty ? widget.patient.emergencyContactPhone : '---'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lịch sử Khám bệnh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Tổng cộng ${_mockVisitHistory.length} lượt khám', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
            Row(
              children: [
                _buildFilterButton(LucideIcons.search, 'Tìm kiếm hồ sơ...'),
                const SizedBox(width: 12),
                _buildFilterButton(LucideIcons.filter, 'Lọc theo thời gian'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Timeline List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockVisitHistory.length,
          itemBuilder: (context, index) {
            final visit = _mockVisitHistory[index];
            return _TimelineCard(visit: visit, isLast: index == _mockVisitHistory.length - 1);
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tải thêm lịch sử'),
                SizedBox(width: 8),
                Icon(LucideIcons.chevronDown, size: 16),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFilterButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textPlaceholder),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Timeline Expandable Card ──
class _TimelineCard extends StatefulWidget {
  final Map<String, dynamic> visit;
  final bool isLast;

  const _TimelineCard({required this.visit, this.isLast = false});

  @override
  State<_TimelineCard> createState() => _TimelineCardState();
}

class _TimelineCardState extends State<_TimelineCard> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    // Default open if it's the latest (mocking behaviour)
    _isExpanded = widget.visit['date'] == '05/10/2023';
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.visit;
    final isEr = v['type'] == 'CẤP CỨU';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isEr ? AppColors.dangerBg : AppColors.primaryBlue.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEr ? LucideIcons.alertTriangle : LucideIcons.stethoscope,
                    size: 14,
                    color: isEr ? AppColors.dangerText : AppColors.primaryBlue,
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _isExpanded ? AppColors.primaryBlue.withAlpha(80) : AppColors.border),
                    boxShadow: [
                      if (_isExpanded)
                        BoxShadow(color: AppColors.primaryBlue.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header (Always visible)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${v['date']} - ${v['time']}', style: const TextStyle(fontSize: 12, color: AppColors.textPlaceholder, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(v['doctor'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      const SizedBox(width: 12),
                                      _buildTypeBadge(v['type'] as String),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                      children: [
                                        const TextSpan(text: 'Chẩn đoán: '),
                                        TextSpan(text: v['diagnosis'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(_isExpanded ? 'Thu gọn' : 'Xem chi tiết', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _isExpanded ? AppColors.primaryBlue : AppColors.textSecondary)),
                                const SizedBox(width: 4),
                                Icon(_isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronRight, size: 16, color: _isExpanded ? AppColors.primaryBlue : AppColors.textSecondary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Expanded Content
                      if (_isExpanded)
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(color: AppColors.border),
                              const SizedBox(height: 20),
                              
                              // First Row: Reason & Symptoms & Tests
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Reason & Vitals
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('LÝ DO ĐẾN KHÁM'),
                                        Text('"${v['reason']}"', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                                        const SizedBox(height: 24),
                                        _buildSectionTitle('CHỈ SỐ SINH TỒN (VITALS)'),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.border.withAlpha(50)),
                                          ),
                                          child: GridView.count(
                                            crossAxisCount: 2,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            childAspectRatio: 2.2,
                                            children: [
                                              _buildVitalBox('MẠCH', v['vitals']['pulse'] as String),
                                              _buildVitalBox('HUYẾT ÁP', v['vitals']['bp'] as String),
                                              _buildVitalBox('NHIỆT ĐỘ', v['vitals']['temp'] as String),
                                              _buildVitalBox('CÂN NẶNG', v['vitals']['weight'] as String),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  // Symptoms & Tests
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildSectionTitle('TRIỆU CHỨNG & LÂM SÀNG'),
                                                  ...(v['symptoms'] as List<String>).map((s) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 6),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                                                        Expanded(child: Text(s, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
                                                      ],
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildSectionTitle('CẬN LÂM SÀNG'),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: (v['tests'] as List<String>).map((t) => Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
                                                      child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                                    )).toList(),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 30),
                                        _buildSectionTitle('ĐƠN THUỐC'),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.border),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.background,
                                                  border: Border(bottom: BorderSide(color: AppColors.border)),
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Expanded(flex: 3, child: Text('Tên thuốc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                                    Expanded(flex: 1, child: Text('SL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                                    Expanded(flex: 4, child: Text('Cách dùng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                                                  ],
                                                ),
                                              ),
                                              ...(v['prescriptions'] as List<Map<String, String>>).map((med) => Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Expanded(flex: 3, child: Text(med['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                                                    Expanded(flex: 1, child: Text(med['qty']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                                                    Expanded(flex: 4, child: Text(med['usage']!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary))),
                                                  ],
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle('GHI CHÚ & LỜI DẶN'),
                              Text(v['notes'] as String, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPlaceholder, letterSpacing: 0.5)),
    );
  }

  Widget _buildVitalBox(String label, String value) {
    final parts = value.split(' ');
    final val = parts[0];
    final unit = parts.length > 1 ? parts[1] : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textPlaceholder)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.textPrimary),
              children: [
                TextSpan(text: val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (unit.isNotEmpty) TextSpan(text: ' $unit', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color bg;
    Color text;
    if (type == 'CẤP CỨU') {
      bg = AppColors.dangerBg;
      text = AppColors.dangerText;
    } else if (type == 'TÁI KHÁM') {
      bg = AppColors.warningBg;
      text = AppColors.warningText;
    } else {
      bg = AppColors.primaryBlue.withAlpha(20);
      text = AppColors.primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: text)),
    );
  }
}
