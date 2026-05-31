import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const HubiApp());
}

class HubiApp extends StatelessWidget {
  const HubiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hubi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const PaintScreen(),
    );
  }
}

class DrawPoint {
  final Offset position;
  final Color color;
  final double strokeWidth;

  const DrawPoint({
    required this.position,
    required this.color,
    required this.strokeWidth,
  });
}

final _rng = Random();

Color _randomVividColor() {
  const vivid = [
    Color(0xFFE53935), Color(0xFFFF7043), Color(0xFFFFEB3B),
    Color(0xFF43A047), Color(0xFF00BCD4), Color(0xFF1E88E5),
    Color(0xFF8E24AA), Color(0xFFEC407A), Color(0xFFFFD600),
    Color(0xFF00E676), Color(0xFF40C4FF), Color(0xFFFF6D00),
    Color(0xFF69F0AE), Color(0xFFEA80FC), Color(0xFFFF4081),
  ];
  return vivid[_rng.nextInt(vivid.length)];
}

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final List<List<DrawPoint>> _strokes = [];
  List<DrawPoint> _currentStroke = [];

  Color _selectedColor = const Color(0xFFE53935);
  double _brushSize = 14.0;
  bool _randomColors = false;
  Color _activeStrokeColor = const Color(0xFFE53935);

  static const List<Color> _palette = [
    Color(0xFFE53935),
    Color(0xFFFF7043),
    Color(0xFFFFEB3B),
    Color(0xFF43A047),
    Color(0xFF00BCD4),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFEC407A),
    Color(0xFF795548),
    Color(0xFF212121),
    Color(0xFFFFFFFF),
  ];

  void _onPanStart(DragStartDetails d) {
    final color = _randomColors ? _randomVividColor() : _selectedColor;
    setState(() {
      _activeStrokeColor = color;
      _currentStroke = [
        DrawPoint(position: d.localPosition, color: color, strokeWidth: _brushSize),
      ];
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _currentStroke.add(DrawPoint(
        position: d.localPosition,
        color: _activeStrokeColor,
        strokeWidth: _brushSize,
      ));
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      if (_currentStroke.isNotEmpty) _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
  }

  void _undo() => setState(() { if (_strokes.isNotEmpty) _strokes.removeLast(); });
  void _clear() => setState(() { _strokes.clear(); _currentStroke = []; });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: SizedBox.expand(
                  child: CustomPaint(
                    painter: _CanvasPainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                    ),
                  ),
                ),
              ),
            ),
            _BottomToolbar(
              selectedColor: _selectedColor,
              brushSize: _brushSize,
              randomColors: _randomColors,
              palette: _palette,
              onColorSelected: (c) => setState(() {
                _selectedColor = c;
                _randomColors = false;
              }),
              onBrushSizeChanged: (v) => setState(() => _brushSize = v),
              onRandomToggled: () => setState(() => _randomColors = !_randomColors),
              onUndo: _undo,
              onClear: _clear,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomToolbar extends StatelessWidget {
  final Color selectedColor;
  final double brushSize;
  final bool randomColors;
  final List<Color> palette;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<double> onBrushSizeChanged;
  final VoidCallback onRandomToggled;
  final VoidCallback onUndo;
  final VoidCallback onClear;

  const _BottomToolbar({
    required this.selectedColor,
    required this.brushSize,
    required this.randomColors,
    required this.palette,
    required this.onColorSelected,
    required this.onBrushSizeChanged,
    required this.onRandomToggled,
    required this.onUndo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: const Color(0xFFF0F0F0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _IconBtn(icon: Icons.undo_rounded, tooltip: 'Undo', onTap: onUndo, color: Colors.blueGrey),
          _IconBtn(
            icon: Icons.delete_forever_rounded,
            tooltip: 'Clear',
            onTap: onClear,
            color: const Color(0xFFE57373),
          ),
          _IconBtn(
            icon: Icons.auto_awesome_rounded,
            tooltip: 'Random colors',
            onTap: onRandomToggled,
            color: randomColors ? Colors.amber[700]! : Colors.grey,
            active: randomColors,
          ),
          const VerticalDivider(width: 16, indent: 12, endIndent: 12),
          const Text('Size', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 4),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: Slider(
                value: brushSize,
                min: 2,
                max: 48,
                activeColor: randomColors ? Colors.amber[700]! : selectedColor,
                onChanged: onBrushSizeChanged,
              ),
            ),
          ),
          Text(
            brushSize.toInt().toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: randomColors ? Colors.amber[700]! : selectedColor,
            ),
          ),
          const VerticalDivider(width: 16, indent: 12, endIndent: 12),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: palette
                  .map((c) => _ColorDot(
                        color: c,
                        selected: !randomColors && selectedColor == c,
                        onTap: () => onColorSelected(c),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  final bool active;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 44 : 32,
          height: selected ? 44 : 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.black87 : Colors.grey.shade400,
              width: selected ? 3 : 1.5,
            ),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2)]
                : null,
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<List<DrawPoint>> strokes;
  final List<DrawPoint> currentStroke;

  const _CanvasPainter({required this.strokes, required this.currentStroke});

  void _drawStroke(Canvas canvas, List<DrawPoint> stroke) {
    if (stroke.isEmpty) return;
    for (int i = 0; i < stroke.length - 1; i++) {
      final p = stroke[i];
      canvas.drawLine(
        p.position,
        stroke[i + 1].position,
        Paint()
          ..color = p.color
          ..strokeWidth = p.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }
    if (stroke.length == 1) {
      final p = stroke[0];
      canvas.drawCircle(p.position, p.strokeWidth / 2,
          Paint()..color = p.color..style = PaintingStyle.fill);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    for (final stroke in strokes) _drawStroke(canvas, stroke);
    _drawStroke(canvas, currentStroke);
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}
