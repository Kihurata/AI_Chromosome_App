import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/entities/test_order.dart';
import 'specialist_order_card.dart';

class SpecialistOrderList extends StatelessWidget {
  final List<TestOrder> orders;

  const SpecialistOrderList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 64),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Column(
          children: [
            Icon(LucideIcons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không tìm thấy phiếu xét nghiệm nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return SpecialistOrderCard(order: orders[index]);
      },
    );
  }
}
