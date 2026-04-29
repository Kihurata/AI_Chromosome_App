import 'package:flutter/material.dart';

class ScreeningStep extends StatefulWidget {
  const ScreeningStep({super.key});

  @override
  State<ScreeningStep> createState() => _ScreeningStepState();
}

class _ScreeningStepState extends State<ScreeningStep> {
  final List<int> _selectedIndices = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bước 1: Sàng lọc ảnh Metaphase',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn các ảnh rõ nét nhất (đã được AI đánh giá sơ bộ) để tiến hành bóc tách.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: 8, // Placeholder count
              itemBuilder: (context, index) {
                final isSelected = _selectedIndices.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIndices.remove(index);
                      } else {
                        _selectedIndices.add(index);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                        width: 3,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/300'), // Placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: isSelected
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
