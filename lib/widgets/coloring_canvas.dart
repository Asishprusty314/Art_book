import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/rendering.dart';

class ColoringCanvas extends StatefulWidget {
  final String svgAsset;
  const ColoringCanvas({super.key, required this.svgAsset});

  @override
  ColoringCanvasState createState() => ColoringCanvasState();
}

class ColoringCanvasState extends State<ColoringCanvas> {
  Color selectedColor = Colors.red;
  double brushThickness = 8.0;
  List<List<Offset?>> strokes = [];
  List<Color> strokeColors = [];
  List<double> strokeThicknesses = [];
  List<Offset?> currentStroke = [];
  bool isErasing = false;
  List<double> thicknesses = [4.0, 8.0, 16.0, 24.0];
  final GlobalKey _repaintKey = GlobalKey();

  List<Color> colors = [
    Color(0xFFE57373), // Red
    Color(0xFFF06292), // Pink
    Color(0xFFBA68C8), // Purple
    Color(0xFF64B5F6), // Blue
    Color(0xFF4DD0E1), // Cyan
    Color(0xFF81C784), // Green
    Color(0xFFFFD54F), // Yellow
    Color(0xFFFFB74D), // Orange
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Grey
    Colors.black,
    Colors.white,
  ];

  void _showColorPicker() async {
    Color pickerColor = selectedColor;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: false,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                setState(() {
                  colors.insert(0, pickerColor);
                  selectedColor = pickerColor;
                  isErasing = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void startStroke(Offset pos) {
    setState(() {
      currentStroke = [pos];
    });
  }

  void addPoint(Offset pos) {
    setState(() {
      currentStroke = List.from(currentStroke)..add(pos);
    });
  }

  void endStroke() {
    if (currentStroke.isNotEmpty) {
      setState(() {
        strokes.add(List.from(currentStroke));
        strokeColors.add(isErasing ? Colors.white : selectedColor);
        strokeThicknesses.add(brushThickness);
        currentStroke = [];
      });
    }
  }

  void undo() {
    if (strokes.isNotEmpty) {
      setState(() {
        strokes.removeLast();
        strokeColors.removeLast();
        strokeThicknesses.removeLast();
      });
    }
  }

  void clearCanvas() {
    setState(() {
      strokes.clear();
      strokeColors.clear();
      strokeThicknesses.clear();
      currentStroke.clear();
    });
  }

  Future<void> saveImage() async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to gallery!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  Widget _buildBackgroundImage() {
    final String path = widget.svgAsset;
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: 300,
        height: 400,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        path,
        width: 300,
        height: 400,
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Centered drawing area
        Align(
          alignment: Alignment.center,
          child: RepaintBoundary(
            key: _repaintKey,
            child: Stack(
              children: [
                _buildBackgroundImage(),
                Builder(
                  builder: (canvasContext) => GestureDetector(
                    onPanStart: (details) {
                      RenderBox renderBox = canvasContext.findRenderObject() as RenderBox;
                      Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                      startStroke(localPosition);
                    },
                    onPanUpdate: (details) {
                      RenderBox renderBox = canvasContext.findRenderObject() as RenderBox;
                      Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                      addPoint(localPosition);
                    },
                    onPanEnd: (_) => endStroke(),
                    child: CustomPaint(
                      painter: _DrawingPainter(
                        strokes: strokes,
                        strokeColors: strokeColors,
                        strokeThicknesses: strokeThicknesses,
                        currentStroke: currentStroke,
                        currentColor: isErasing ? Colors.white : selectedColor,
                        currentThickness: brushThickness,
                      ),
                      size: const Size(300, 400),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Color palette (top-left)
        Positioned(
          top: 12,
          left: 12,
          child: Column(
            children: [
              ...colors.map((color) => GestureDetector(
                onTap: () => setState(() {
                  selectedColor = color;
                  isErasing = false;
                }),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == color && !isErasing ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: selectedColor == color && !isErasing
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
                ),
              )),
              // Custom Color Picker Button
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepPurple, width: 2),
                  ),
                  child: const Icon(Icons.add, color: Colors.deepPurple, size: 20),
                ),
              ),
            ],
          ),
        ),
        // Brush, eraser, undo, clear (top-right)
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              // Brush thicknesses
              ...thicknesses.map((thickness) => GestureDetector(
                onTap: () => setState(() {
                  brushThickness = thickness;
                  isErasing = false;
                }),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: brushThickness == thickness && !isErasing ? Colors.deepPurple : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: brushThickness == thickness && !isErasing ? Colors.orangeAccent : Colors.grey,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: thickness,
                      height: thickness,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1),
                      ),
                    ),
                  ),
                ),
              )),
              // Eraser
              IconButton(
                icon: Icon(Icons.cleaning_services_rounded, color: isErasing ? Colors.orange : Colors.grey, size: 28),
                tooltip: 'Eraser',
                onPressed: () => setState(() => isErasing = true),
              ),
              // Undo
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.blue, size: 28),
                tooltip: 'Undo',
                onPressed: undo,
              ),
              // Clear
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                tooltip: 'Clear',
                onPressed: clearCanvas,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Color> strokeColors;
  final List<double> strokeThicknesses;
  final List<Offset?> currentStroke;
  final Color currentColor;
  final double currentThickness;
  _DrawingPainter({
    required this.strokes,
    required this.strokeColors,
    required this.strokeThicknesses,
    required this.currentStroke,
    required this.currentColor,
    required this.currentThickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int s = 0; s < strokes.length; s++) {
      final points = strokes[s];
      final paint = Paint()
        ..color = strokeColors[s].withOpacity(0.5)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeThicknesses[s];
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
      }
    }
    // Draw current stroke
    final paint = Paint()
      ..color = currentColor.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = currentThickness;
    for (int i = 0; i < currentStroke.length - 1; i++) {
      if (currentStroke[i] != null && currentStroke[i + 1] != null) {
        canvas.drawLine(currentStroke[i]!, currentStroke[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.strokeColors != strokeColors ||
      oldDelegate.strokeThicknesses != strokeThicknesses ||
      oldDelegate.currentStroke != currentStroke ||
      oldDelegate.currentColor != currentColor ||
      oldDelegate.currentThickness != currentThickness;
}

