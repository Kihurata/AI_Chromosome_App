import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../domain/entities/patient.dart';
import '../../../logic/bloc/patient/patient_cubit.dart';
import '../../../logic/bloc/patient/patient_state.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/shared/data_display/app_data_table.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../patient_detail/patient_detail_screen.dart';
import 'patient_registration_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PatientCubit>().fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainListLayout(
      title: 'Danh sách bệnh nhân',
      subtitle: 'Quản lý hồ sơ và lịch sử khám bệnh',
      child: BlocBuilder<PatientCubit, PatientState>(
        builder: (context, state) {
          final allPatients = state is PatientLoaded ? state.patients : <Patient>[];
          final patients = allPatients.where((p) {
            if (_searchQuery.isEmpty) return true;
            return p.fullName.toLowerCase().contains(_searchQuery) ||
                p.phone.contains(_searchQuery) ||
                (p.patientCode ?? '').toLowerCase().contains(_searchQuery);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(28.0),
            child: AppDataTable(
              searchHint: 'Tìm theo tên, SĐT hoặc mã BN...',
              countText: '${patients.length} bệnh nhân',
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              isLoading: state is PatientLoading,
              headerRow: const _PatientTableHeader(),
              emptyState: _EmptyPatients(onAdd: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
              )),
              rows: patients.map((p) => _PatientRow(
                patient: p,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: PatientModel.fromEntity(p))),
                ),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _PatientTableHeader extends StatelessWidget {
  const _PatientTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
    return const Row(
      children: [
        SizedBox(width: 44),
        Expanded(flex: 3, child: Text('HỌ TÊN', style: style)),
        Expanded(flex: 2, child: Text('MÃ BN', style: style)),
        Expanded(flex: 2, child: Text('SĐT', style: style)),
        Expanded(flex: 2, child: Text('NGÀY SINH', style: style)),
        Expanded(flex: 1, child: Text('GIỚI TÍNH', style: style)),
        SizedBox(width: 60),
      ],
    );
  }
}

class _PatientRow extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const _PatientRow({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: UIUtils.getAvatarColor(patient.fullName),
              child: Text(
                UIUtils.getInitials(patient.fullName),
                style: TextStyle(color: UIUtils.getAvatarTextColor(patient.fullName), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            Expanded(
              flex: 2,
              child: Text(patient.patientCode ?? '---', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              flex: 2,
              child: Text(patient.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 2,
              child: Text(UIUtils.formatDate(patient.dob), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(flex: 1, child: _GenderBadge(gender: patient.gender)),
            const SizedBox(
              width: 60,
              child: Icon(LucideIcons.eye, size: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderBadge extends StatelessWidget {
  final String gender;
  const _GenderBadge({required this.gender});

  @override
  Widget build(BuildContext context) {
    final isNam = gender == 'Nam';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNam ? AppColors.activeBackground : const Color(0xFFFCE7F3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        gender,
        style: TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.w600, 
          color: isNam ? AppColors.primaryBlue : const Color(0xFFDB2777),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPatients({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Icon(LucideIcons.userX, size: 48, color: AppColors.textPlaceholder.withAlpha(120)),
          const SizedBox(height: 16),
          const Text('Chưa có bệnh nhân nào', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          AppPrimaryButton(text: 'Thêm bệnh nhân', icon: LucideIcons.plus, onPressed: onAdd),
        ],
      ),
    );
  }
}
