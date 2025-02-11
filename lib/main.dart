import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const DirectionPickerApp());
}

class DirectionPickerApp extends StatelessWidget {
  const DirectionPickerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '16 Directions Picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DirectionPickerScreen(),
    );
  }
}

class DirectionPickerScreen extends StatefulWidget {
  const DirectionPickerScreen({Key? key}) : super(key: key);

  @override
  State<DirectionPickerScreen> createState() => _DirectionPickerScreenState();
}

class _DirectionPickerScreenState extends State<DirectionPickerScreen> {
  String? selectedDirection;
  final List<String> directions = [
    "北", "北北東", "北東", "東北東",
    "東", "東南東", "南東", "南南東",
    "南", "南南西", "南西", "西南西",
    "西", "西北西", "北西", "北北西",
  ];

  late List<List<Offset>> triangles;

  @override
  void initState() {
    super.initState();
    // 三角形領域の初期化 (中心を (150, 150)、半径を150に設定)
    triangles = generateTriangles(150, 150, 150);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('16 Directions Picker'),
      ),
      body: Center(
        child: GestureDetector(
          onTapUp: (details) {
            final tapPosition = details.localPosition;
            final direction = findDirection(tapPosition, triangles, directions);
            setState(() {
              selectedDirection = direction;
            });
          },
          child: CustomPaint(
            size: const Size(300, 300),
            painter: DirectionPainter(triangles, selectedDirection, directions),
          ),
        ),
      ),
    );
  }
}

class DirectionPainter extends CustomPainter {
  final List<List<Offset>> triangles;
  final String? selectedDirection;
  final List<String> directions;

  DirectionPainter(this.triangles, this.selectedDirection, this.directions);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < triangles.length; i++) {
      paint.color = selectedDirection == directions[i]
          ? Colors.blue.shade300
          : Colors.grey.shade300;

      final path = Path()
        ..moveTo(triangles[i][0].dx, triangles[i][0].dy)
        ..lineTo(triangles[i][1].dx, triangles[i][1].dy)
        ..lineTo(triangles[i][2].dx, triangles[i][2].dy)
        ..close();

      canvas.drawPath(path, paint);
    }

    // 方角テキストの描画
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < directions.length; i++) {
      final angle = (i * 2 * pi / 16) - pi / 2 ;
      final Offset center = Offset(
        size.width / 2 + 100 * cos(angle),
        size.height / 2 + 100 * sin(angle),
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: const TextStyle(fontSize: 12, color: Colors.black),
      );

      textPainter.layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}
bool isPointInTriangle(Offset p, Offset a, Offset b, Offset c) {
  double cross(Offset v1, Offset v2) => (v1.dx * v2.dy) - (v1.dy * v2.dx);

  Offset v0 = Offset(c.dx - a.dx, c.dy - a.dy);
  Offset v1 = Offset(b.dx - a.dx, b.dy - a.dy);
  Offset v2 = Offset(p.dx - a.dx, p.dy - a.dy);

  double dot00 = v0.dx * v0.dx + v0.dy * v0.dy;
  double dot01 = v0.dx * v1.dx + v0.dy * v1.dy;
  double dot02 = v0.dx * v2.dx + v0.dy * v2.dy;
  double dot11 = v1.dx * v1.dx + v1.dy * v1.dy;
  double dot12 = v1.dx * v2.dx + v1.dy * v2.dy;

  double invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
  double u = (dot11 * dot02 - dot01 * dot12) * invDenom;
  double v = (dot00 * dot12 - dot01 * dot02) * invDenom;

  return (u >= 0) && (v >= 0) && (u + v < 1);
}
List<List<Offset>> generateTriangles(double cx, double cy, double radius) {
  List<List<Offset>> triangles = [];
  for (int i = 0; i < 16; i++) {
    double angle1 = ((i * 2 * pi / 16) - pi / 2 )-11.2; // 始点角度 (北を-11.25～11.25°に調整)
    double angle2 = (((i + 1) * 2 * pi / 16) - pi / 2 )- 11.2; // 終点角度

    Offset point1 = Offset(
      cx + radius * cos(angle1),
      cy + radius * sin(angle1),
    );
    Offset point2 = Offset(
      cx + radius * cos(angle2),
      cy + radius * sin(angle2),
    );

    triangles.add([
      Offset(cx, cy), // 中心
      point1,         // 外周の1点目
      point2,         // 外周の2点目
    ]);
  }
  return triangles;
}
String? findDirection(Offset tapPosition, List<List<Offset>> triangles, List<String> directions) {
  for (int i = 0; i < triangles.length; i++) {
    if (isPointInTriangle(tapPosition, triangles[i][0], triangles[i][1], triangles[i][2])) {
      return directions[i];
    }
  }
  return null; // 該当なし
}
