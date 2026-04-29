import 'package:flutter/material.dart';

class SlicingStep extends StatefulWidget {
  const SlicingStep({super.key});

  @override
  State<SlicingStep> createState() => _SlicingStepState();
}

class _SlicingStepState extends State<SlicingStep> {
  List<Offset> _currentPolygon = [];
  final List<List<Offset>> _polygons = [];

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPolygon.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPolygon.length > 2) {
      setState(() {
        _polygons.add(List.from(_currentPolygon));
        _currentPolygon.clear();
      });
    } else {
      setState(() {
        _currentPolygon.clear();
      });
    }
  }

  void _undo() {
    if (_polygons.isNotEmpty) {
      setState(() {
        _polygons.removeLast();
      });
    }
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
                    'Sử dụng chuột để khoanh vùng (Lasso) tách các cụm NST dính nhau.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _polygons.isNotEmpty ? _undo : null,
                icon: const Icon(Icons.undo),
                label: const Text('Undo khoanh vùng'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/800x600'), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: CustomPaint(
                      painter: _PolygonPainter(_polygons, _currentPolygon),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolygonPainter extends CustomPainter {
  final List<List<Offset>> polygons;
  final List<Offset> currentPolygon;

  _PolygonPainter(this.polygons, this.currentPolygon);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Draw completed polygons
    for (var polygon in polygons) {
      if (polygon.isEmpty) continue;
      final path = Path()..moveTo(polygon.first.dx, polygon.first.dy);
      for (int i = 1; i < polygon.length; i++) {
        path.lineTo(polygon[i].dx, polygon[i].dy);
      }
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, fillPaint);
    }

    // Draw current polygon
    if (currentPolygon.isNotEmpty) {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
