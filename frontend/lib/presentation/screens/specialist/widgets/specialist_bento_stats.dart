import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/entities/specialist_stats.dart';
import '../../../widgets/shared/cards/stats_card.dart';

class SpecialistBentoStats extends StatelessWidget {
  final SpecialistStats stats;

  const SpecialistBentoStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 4 : 2;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: width > 600 ? 1.5 : 1.2,
      children: [
        StatsCard(
          title: 'Tổng số phiếu',
          value: stats.total.toString(),
          icon: LucideIcons.files,
          color: Colors.blue,
        ),
        StatsCard(
          title: 'Chờ xử lý',
          value: stats.pending.toString(),
          icon: LucideIcons.clock,
          color: Colors.orange,
        ),
        StatsCard(
          title: 'Đang phân tích',
          value: stats.analyzing.toString(),
          icon: LucideIcons.activity,
          color: Colors.indigo,
        ),
        StatsCard(
          title: 'Hoàn thành',
          value: stats.completed.toString(),
          icon: LucideIcons.checkCircle,
          color: Colors.green,
        ),
      ],
    );
  }
}
