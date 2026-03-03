import 'dart:math';
import 'package:flutter/material.dart';
import '../data/ingredients_data.dart';

class SmoothieCupWidget extends StatefulWidget {
  final Color cupColor;
  final List<String> fruits;
  final double size;

  /// Constructor แบบดั้งเดิม - ใส่สีและ emoji เอง
  const SmoothieCupWidget({
    super.key,
    required this.cupColor,
    required this.fruits,
    this.size = 120,
  });

  /// Constructor ใหม่ - สะดวกกว่า ใส่ indexes และคำนวณสีให้เอง
  factory SmoothieCupWidget.fromIndexes({
    Key? key,
    required List<int> fruitIndexes,
    List<int> extrasIndexes = const [],
    List<int> veggieIndexes = const [],
    List<int> herbsIndexes = const [],
    double size = 60,
  }) {
    final cupColor = _computeBlendedColor(
      fruitIndexes: fruitIndexes,
      extrasIndexes: extrasIndexes,
      veggieIndexes: veggieIndexes,
      herbsIndexes: herbsIndexes,
    );

    final fruits = _getFruitEmojis(
      fruitIndexes: fruitIndexes,
      extrasIndexes: extrasIndexes,
      veggieIndexes: veggieIndexes,
      herbsIndexes: herbsIndexes,
    );

    return SmoothieCupWidget(
      key: key,
      cupColor: cupColor,
      fruits: fruits,
      size: size,
    );
  }

  /// คำนวณสี blend จาก ingredient indexes
  /// indexes ที่ได้รับมามี offset อยู่แล้ว (extras=30+, veggies=100+, herbs=260+)
  static Color _computeBlendedColor({
    required List<int> fruitIndexes,
    required List<int> extrasIndexes,
    required List<int> veggieIndexes,
    required List<int> herbsIndexes,
  }) {
    final allIndices = [
      ...fruitIndexes,
      ...extrasIndexes,
      ...veggieIndexes,
      ...herbsIndexes,
    ];

    if (allIndices.isEmpty) {
      return const Color(0xFFE8F5E9);
    }

    int r = 0, g = 0, b = 0;
    int count = 0;

    for (final i in fruitIndexes) {
      final color = kIngredientColors[i] ?? Colors.green;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    for (final i in extrasIndexes) {
      final color = kIngredientColors[i] ?? Colors.brown;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    for (final i in veggieIndexes) {
      final color = kIngredientColors[i] ?? Colors.green;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    for (final i in herbsIndexes) {
      final color = kIngredientColors[i] ?? Colors.green;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    return Color.fromARGB(255, r ~/ count, g ~/ count, b ~/ count);
  }

  /// ดึง emoji จาก indexes
  /// indexes ที่ได้รับมามี offset อยู่แล้ว (extras=30+, veggies=100+, herbs=260+)
  static List<String> _getFruitEmojis({
    required List<int> fruitIndexes,
    required List<int> extrasIndexes,
    required List<int> veggieIndexes,
    required List<int> herbsIndexes,
  }) {
    final emojis = <String>[];

    for (final i in fruitIndexes) {
      if (i >= 0 && i < kFruitsData.length) {
        emojis.add(kFruitsData[i].$1);
      }
    }

    for (final i in extrasIndexes) {
      final adjustedIndex = i - 30;
      if (adjustedIndex >= 0 && adjustedIndex < kExtrasData.length) {
        emojis.add(kExtrasData[adjustedIndex].$1);
      }
    }

    for (final i in veggieIndexes) {
      final adjustedIndex = i - 100;
      if (adjustedIndex >= 0 && adjustedIndex < kVeggiesData.length) {
        emojis.add(kVeggiesData[adjustedIndex].$1);
      }
    }

    for (final i in herbsIndexes) {
      final adjustedIndex = i - 260;
      if (adjustedIndex >= 0 && adjustedIndex < kHerbsData.length) {
        emojis.add(kHerbsData[adjustedIndex].$1);
      }
    }

    return emojis;
  }

  @override
  State<SmoothieCupWidget> createState() => _SmoothieCupWidgetState();
}

class _SmoothieCupWidgetState extends State<SmoothieCupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.2,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(
            painter: _SmoothieCupPainter(
              cupColor: widget.cupColor,
              fruits: widget.fruits,
              t: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _SmoothieCupPainter extends CustomPainter {
  final Color cupColor;
  final List<String> fruits;
  final double t; // 0.0 → 1.0 animation progress

  _SmoothieCupPainter({
    required this.cupColor,
    required this.fruits,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── ขนาดแก้ว ──────────────────────────────────
    final cupTop = h * 0.12; // ตำแหน่ง top ของแก้ว
    final cupBot = h * 0.95; // ตำแหน่ง bottom ของแก้ว
    final cupTopW = w * 0.78; // ความกว้างบน
    final cupBotW = w * 0.58; // ความกว้างล่าง
    final cupCenterX = w / 2;

    // trapezoid path ของแก้ว
    Path cupPath = Path()
      ..moveTo(cupCenterX - cupTopW / 2, cupTop)
      ..lineTo(cupCenterX + cupTopW / 2, cupTop)
      ..lineTo(cupCenterX + cupBotW / 2, cupBot)
      ..lineTo(cupCenterX - cupBotW / 2, cupBot)
      ..close();

    // ── เงาแก้ว ──────────────────────────────────
    canvas.drawShadow(cupPath, Colors.black26, 6, false);

    // ── พื้นแก้ว (น้ำ smoothie) ──────────────────
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cupColor.withOpacity(0.85),
          cupColor,
          cupColor.withOpacity(0.9),
        ],
      ).createShader(Rect.fromLTWH(0, cupTop, w, cupBot - cupTop));
    canvas.drawPath(cupPath, liquidPaint);

    // ── ไฮไลท์ด้านซ้าย (สะท้อนแสง) ──────────────
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.white.withOpacity(0.35), Colors.white.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, cupTop, w * 0.4, cupBot - cupTop));
    final highlightPath = Path()
      ..moveTo(cupCenterX - cupTopW / 2, cupTop)
      ..lineTo(cupCenterX - cupTopW / 2 + w * 0.22, cupTop)
      ..lineTo(cupCenterX - cupBotW / 2 + w * 0.16, cupBot)
      ..lineTo(cupCenterX - cupBotW / 2, cupBot)
      ..close();
    canvas.drawPath(highlightPath, highlightPaint);

    // ── ฝาแก้ว ───────────────────────────────────
    final lidY = cupTop - h * 0.01;
    final lidH = h * 0.055;
    final lidPaint = Paint()..color = Colors.white.withOpacity(0.92);
    final lidPath = Path()
      ..moveTo(cupCenterX - cupTopW / 2 - 2, lidY)
      ..lineTo(cupCenterX + cupTopW / 2 + 2, lidY)
      ..lineTo(cupCenterX + cupTopW / 2 - 2, lidY + lidH)
      ..lineTo(cupCenterX - cupTopW / 2 + 2, lidY + lidH)
      ..close();
    canvas.drawPath(lidPath, lidPaint);
    // ขอบฝา
    canvas.drawPath(
      lidPath,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // ── หลอด ─────────────────────────────────────
    final strawX = cupCenterX + w * 0.1;
    final strawTop = h * -0.04;
    final strawBot = cupBot * 0.6;
    final strawW = w * 0.055;
    final strawPaint = Paint()
      ..color = const Color(0xFF9C27B0)
      ..style = PaintingStyle.fill;
    final strawPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strawX - strawW / 2,
            strawTop,
            strawW,
            strawBot - strawTop,
          ),
          const Radius.circular(4),
        ),
      );
    canvas.drawPath(strawPath, strawPaint);
    // ไฮไลท์หลอด
    canvas.drawRect(
      Rect.fromLTWH(
        strawX - strawW / 2 + 1.5,
        strawTop + 4,
        strawW * 0.35,
        (strawBot - strawTop) * 0.7,
      ),
      Paint()..color = Colors.white.withOpacity(0.3),
    );

    // ── ฟองอากาศเล็กๆ ในแก้ว ─────────────────────
    final rng = Random(7);
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final bx = cupCenterX - cupBotW * 0.3 + rng.nextDouble() * cupBotW * 0.6;
      final phase = rng.nextDouble();
      final by =
          cupTop +
          (cupBot - cupTop) * 0.4 +
          (cupBot - cupTop) * 0.5 * ((t + phase) % 1.0);
      final br = 2.0 + rng.nextDouble() * 3;
      canvas.drawCircle(Offset(bx, by), br, bubblePaint);
    }

    // ── ผลไม้ลอยๆ (emoji) ────────────────────────
    if (fruits.isNotEmpty) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      final rngF = Random(42);
      final count = fruits.length.clamp(1, 4);

      for (int i = 0; i < count; i++) {
        final emoji = fruits[i % fruits.length];
        final phase = i / count;

        // ลอยขึ้นลงช้าๆ แต่ละผลต่างเฟส
        final floatY = sin((t + phase) * 2 * pi) * h * 0.045;

        // กระจายตำแหน่ง X ในแก้ว
        final xFrac = 0.2 + (i % 3) * 0.28 + rngF.nextDouble() * 0.05;
        final yFrac = 0.35 + (i ~/ 3) * 0.3;

        final ex = cupCenterX - cupBotW * 0.4 + xFrac * cupBotW * 0.9;
        final ey = cupTop + (cupBot - cupTop) * yFrac + floatY;

        // clamp ให้อยู่ในแก้ว
        final clampedEy = ey.clamp(cupTop + 8, cupBot - 18).toDouble();

        tp.text = TextSpan(
          text: emoji,
          style: TextStyle(fontSize: w * 0.18),
        );
        tp.layout();

        // clip วาด emoji ให้อยู่ในแก้วเท่านั้น
        canvas.save();
        canvas.clipPath(cupPath);
        tp.paint(canvas, Offset(ex - tp.width / 2, clampedEy - tp.height / 2));
        canvas.restore();
      }
    }

    canvas.drawPath(
      cupPath,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_SmoothieCupPainter old) =>
      old.t != t || old.fruits != fruits || old.cupColor != cupColor;
}

const Map<String, Color> menuCupColors = {
  'Berry Blast': Color(0xFFE91E8C),
  'Mango Tango': Color(0xFFFFB347),
  'Green Power': Color(0xFF66BB6A),
  'Banana Boost': Color(0xFFFFEB3B),
  'Tropical Blast': Color(0xFFFF7043),
  'Dragon Glow': Color(0xFFCE93D8),
};

const Map<String, List<String>> menuFruitEmojis = {
  'Berry Blast': ['🍓', '🫐'],
  'Mango Tango': ['🥭', '🍍', '🍋'],
  'Green Power': ['🥬', '🍏', '🫚'],
  'Banana Boost': ['🍌', '🥛'],
  'Tropical Blast': ['🥭', '🍍', '🍊'],
  'Dragon Glow': ['🐉', '🍈'],
};
