import 'package:flutter/material.dart';


class SlicingStep extends StatefulWidget {
  const SlicingStep({super.key});

  @override
  State<SlicingStep> createState() => _SlicingStepState();
}

// Dummy model for demonstration
class ChromosomeItem {
  final String id;
  final String imageUrl;
  final bool isCluster;

  ChromosomeItem({required this.id, required this.imageUrl, this.isCluster = false});
}

class _SlicingStepState extends State<SlicingStep> {
  // Unclassified pool
  final List<ChromosomeItem> _unclassifiedPool = [
    ChromosomeItem(id: 'c1', imageUrl: 'https://via.placeholder.com/100x100?text=C1'),
    ChromosomeItem(id: 'c2', imageUrl: 'https://via.placeholder.com/100x100?text=C2'),
    ChromosomeItem(id: 'cluster1', imageUrl: 'https://via.placeholder.com/150x150?text=Cluster', isCluster: true),
  ];

  // Karyotype Grid State
  final Map<String, List<ChromosomeItem>> _karyotypeGrid = {
    for (var i = 1; i <= 22; i++) i.toString(): [],
    'X': [],
    'Y': [],
  };

  // Lasso State
  bool _isLassoMode = false;
  final List<Offset> _currentPolygon = [];
  String? _activeClusterId;

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isLassoMode) return;
    setState(() {
      _currentPolygon.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isLassoMode) return;
    if (_currentPolygon.length > 2) {
      // Simulate separation
      setState(() {
        _unclassifiedPool.add(ChromosomeItem(
          id: 'new_${DateTime.now().millisecondsSinceEpoch}',
          imageUrl: 'https://via.placeholder.com/100x100?text=New',
        ));
        _currentPolygon.clear();
        _isLassoMode = false;
        _activeClusterId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tách thành công một NST từ cụm.')),
      );
    } else {
      setState(() {
        _currentPolygon.clear();
      });
    }
  }

  void _onAcceptChromosome(String targetKey, ChromosomeItem item) {
    setState(() {
      // Remove from pool
      _unclassifiedPool.removeWhere((element) => element.id == item.id);
      
      // Remove from any other grid cell if it came from there
      _karyotypeGrid.forEach((key, list) {
        list.removeWhere((element) => element.id == item.id);
      });

      // Add to new target
      _karyotypeGrid[targetKey]!.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bước 2: Phân loại - Tách NST',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kéo thả để phân loại. Dùng Lasso để khoanh vùng tách cụm dính.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã lưu nháp (Local)')),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu nháp'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Move to next step logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hoàn thành Bước 2')),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Hoàn thành'),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel: Unclassified Pool
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unclassified Pool',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Divider(),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _unclassifiedPool.length,
                            itemBuilder: (context, index) {
                              final item = _unclassifiedPool[index];
                              return _buildDraggableItem(item);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Right Panel: Karyotype Grid
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lưới Karyotype',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Divider(),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: _karyotypeGrid.keys.length,
                            itemBuilder: (context, index) {
                              final key = _karyotypeGrid.keys.elementAt(index);
                              final items = _karyotypeGrid[key]!;
                              return _buildDragTarget(key, items);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(ChromosomeItem item) {
    Widget child = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _isLassoMode && _activeClusterId == item.id ? Colors.blue : Colors.grey.shade300,
          width: _isLassoMode && _activeClusterId == item.id ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Image.network(item.imageUrl, fit: BoxFit.contain),
          ),
          if (item.isCluster)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  Icons.gesture,
                  color: _isLassoMode && _activeClusterId == item.id ? Colors.blue : Colors.grey,
                ),
                tooltip: 'Sử dụng Lasso tách cụm',
                onPressed: () {
                  setState(() {
                    _isLassoMode = true;
                    _activeClusterId = item.id;
                    _currentPolygon.clear();
                  });
                },
              ),
            ),
          if (_isLassoMode && _activeClusterId == item.id)
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: _PolygonPainter(_currentPolygon),
                  size: Size.infinite,
                ),
              ),
            ),
        ],
      ),
    );

    // If it's in lasso mode, disable dragging for the active cluster
    if (_isLassoMode && _activeClusterId == item.id) {
      return child;
    }

    return Draggable<ChromosomeItem>(
      data: item,
      feedback: Material(
        elevation: 4.0,
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: 100,
            height: 100,
            child: child,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      child: child,
    );
  }

  Widget _buildDragTarget(String key, List<ChromosomeItem> items) {
    return DragTarget<ChromosomeItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        _onAcceptChromosome(key, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovered = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue.shade50 : Colors.grey.shade100,
            border: Border.all(
              color: isHovered ? Colors.blue : Colors.grey.shade300,
              width: isHovered ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Text(
                  key,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: items.isEmpty
                      ? const Center(child: Text('Trống', style: TextStyle(color: Colors.grey, fontSize: 12)))
                      : Stack(
                          children: items.map((item) {
                            return _buildDraggableItem(item);
                          }).toList(),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PolygonPainter extends CustomPainter {
  final List<Offset> currentPolygon;

  _PolygonPainter(this.currentPolygon);

  @override
  void paint(Canvas canvas, Size size) {
    if (currentPolygon.isEmpty) return;

    final currentPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(currentPolygon.first.dx, currentPolygon.first.dy);
    for (int i = 1; i < currentPolygon.length; i++) {
      path.lineTo(currentPolygon[i].dx, currentPolygon[i].dy);
    }
    canvas.drawPath(path, currentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
