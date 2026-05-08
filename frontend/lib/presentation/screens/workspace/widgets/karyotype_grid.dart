import 'package:flutter/material.dart';
import '../../../../domain/entities/chromosome.dart';

class KaryotypeGrid extends StatelessWidget {
  final List<Chromosome> chromosomes;

  const KaryotypeGrid({
    super.key,
    required this.chromosomes,
  });

  @override
  Widget build(BuildContext context) {
    // Group chromosomes by label
    final Map<String, List<Chromosome>> grouped = {};
    for (final c in chromosomes) {
      final label = c.label.toUpperCase();
      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(c);
    }

    // Define standard rows
    final rows = [
      ['1', '2', '3', '4', '5'],
      ['6', '7', '8', '9', '10', '11', '12'],
      ['13', '14', '15', '16', '17', '18'],
      ['19', '20', '21', '22', 'X', 'Y'],
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((label) {
                final list = grouped[label] ?? [];
                return _buildCell(label, list);
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCell(String label, List<Chromosome> list) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        maxWidth: 100,
        minHeight: 80,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chromosomes images
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 2,
              children: list.map((c) {
                return c.imageUrl != null
                    ? Image.network(
                        c.imageUrl!,
                        width: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 16, color: Colors.grey),
                      )
                    : Container(
                        width: 20,
                        height: 30,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image, size: 12, color: Colors.grey),
                        ),
                      );
              }).toList(),
            ),
          ),
          // Label
          Container(
            width: double.infinity,
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
