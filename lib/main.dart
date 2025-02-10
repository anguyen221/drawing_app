import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DrawingApp(),
    );
  }
}

class DrawingApp extends StatefulWidget {
  @override
  _DrawingAppState createState() => _DrawingAppState();
}

enum DrawMode { freehand, square, circle, arc, emoji }

class _DrawingAppState extends State<DrawingApp> {
  List<List<Offset>> lines = [];
  List<Map<String, dynamic>> shapes = [];
  DrawMode _selectedMode = DrawMode.freehand;
  String _selectedEmoji = "smiley";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<DrawMode>(
                  value: _selectedMode,
                  onChanged: (mode) {
                    setState(() {
                      _selectedMode = mode!;
                    });
                  },
                  items: DrawMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.toString().split('.').last),
                    );
                  }).toList(),
                ),
                if (_selectedMode == DrawMode.emoji)
                  DropdownButton<String>(
                    value: _selectedEmoji,
                    onChanged: (emoji) {
                      setState(() {
                        _selectedEmoji = emoji!;
                      });
                    },
                    items: ["smiley", "heart", "party"].map((emoji) {
                      return DropdownMenuItem(
                        value: emoji,
                        child: Text(emoji),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.globalPosition);
                  if (_selectedMode == DrawMode.freehand) {
                    if (lines.isEmpty || lines.last.isEmpty) {
                      lines.add([localPosition]);
                    } else {
                      lines.last.add(localPosition);
                    }
                  }
                });
              },
              onPanEnd: (_) {
                setState(() {
                  if (_selectedMode == DrawMode.freehand) {
                    lines.add([]);
                  }
                });
              },
              onTapDown: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                setState(() {
                  if (_selectedMode != DrawMode.freehand) {
                    shapes.add({
                      'mode': _selectedMode,
                      'position': localPosition,
                      'emoji': _selectedMode == DrawMode.emoji ? _selectedEmoji : null,
                    });
                  }
                });
              },
              child: CustomPaint(
                painter: MyPainter(lines, shapes),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            lines.clear();
            shapes.clear();
          });
        },
        child: Icon(Icons.clear),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Map<String, dynamic>> shapes;
  MyPainter(this.lines, this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (final line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    for (final shape in shapes) {
      Offset position = shape['position'];
      switch (shape['mode']) {
        case DrawMode.square:
          canvas.drawRect(Rect.fromCenter(center: position, width: 50, height: 50), paint);
          break;
        case DrawMode.circle:
          canvas.drawCircle(position, 25, paint);
          break;
        case DrawMode.arc:
          canvas.drawArc(Rect.fromCenter(center: position, width: 50, height: 50), 0, 3.14, false, paint);
          break;
        case DrawMode.emoji:
          if (shape['emoji'] == "smiley") _drawSmiley(canvas, position);
          if (shape['emoji'] == "heart") _drawHeart(canvas, position);
          if (shape['emoji'] == "party") _drawParty(canvas, position);
          break;
        default:
          break;
      }
    }
  }

  void _drawSmiley(Canvas canvas, Offset position) {
    Paint paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 25, paint);

    Paint eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position + Offset(-10, -5), 3, eyePaint);
    canvas.drawCircle(position + Offset(10, -5), 3, eyePaint);

    Paint mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(Rect.fromCenter(center: position + Offset(0, 5), width: 20, height: 10), 0, 3.14, false, mouthPaint);
  }

  void _drawHeart(Canvas canvas, Offset position) {
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(position.dx, position.dy);
    path.cubicTo(position.dx - 15, position.dy - 15, position.dx - 30, position.dy + 10, position.dx, position.dy + 20);
    path.cubicTo(position.dx + 30, position.dy + 10, position.dx + 15, position.dy - 15, position.dx, position.dy);
    canvas.drawPath(path, paint);
  }

  void _drawParty(Canvas canvas, Offset position) {
    Paint facePaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(position, 25, facePaint);

    Paint hatPaint = Paint()..color = Colors.blue;
    Path hatPath = Path();
    hatPath.moveTo(position.dx - 15, position.dy - 20);
    hatPath.lineTo(position.dx + 15, position.dy - 20);
    hatPath.lineTo(position.dx, position.dy - 40);
    hatPath.close();
    canvas.drawPath(hatPath, hatPaint);

    Paint hornPaint = Paint()..color = Colors.purple;
    canvas.drawLine(position + Offset(10, 5), position + Offset(25, 10), hornPaint..strokeWidth = 4);

    Paint eyes = Paint()..color = const Color.fromARGB(255, 0, 0, 0);
    canvas.drawCircle(position + Offset(-15, -10), 3, eyes);
    canvas.drawCircle(position + Offset(15, -15), 3, eyes);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
