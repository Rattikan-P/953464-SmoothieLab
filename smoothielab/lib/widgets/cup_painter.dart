import 'package:flutter/material.dart';

/// CustomPainter สำหรับวาดแก้วสมูทตี้
class CupPainter extends CustomPainter {
  final double cupWidth;
  final double cupHeight;
  final Color liquidColor;
  final bool hasIngredients;
  final double strawLength; // 0.0 = สั้น, 1.0 = ยาวปกติ

  CupPainter({
    required this.cupWidth,
    required this.cupHeight,
    required this.liquidColor,
    required this.hasIngredients,
    this.strawLength = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final topY = 0.0;

    // วาดหลอดก่อน (อยู่ด้านหลังแก้ว)
    _drawStraw(canvas, cx, topY);

    // เงาแก้ว
    canvas.save();
    canvas.translate(3, 3);
    _drawCupBody(canvas, cx, topY, Colors.black.withValues(alpha: 0.08), false);
    canvas.restore();

    // ตัวแก้วหลัก
    _drawCupBody(canvas, cx, topY, Colors.white.withValues(alpha: 0.9), true);

    // ขอบบน (Rim)
    _drawRim(canvas, cx, topY);

    // เติมน้ำในแก้ว
    _drawLiquid(canvas, cx, topY);

    // แสงสะท้อน
    _drawReflections(canvas, cx, topY);

    // ขอบนอก
    _drawOutline(canvas, cx, topY);
  }

  void _drawStraw(Canvas canvas, double cx, double topY) {
    // ความยาวหลอดปรับตามขนาดแก้ว (สั้นลง)
    final baseStrawHeight = cupHeight * 0.5;
    final strawHeight = baseStrawHeight * strawLength;
    final strawWidth = 6.0;

    // ตำแหน่งหลอด (เอียงนิดหน่อย)
    final strawX = cx + cupWidth * 0.15;
    final strawTopY = topY - strawHeight;
    final strawBottomY = topY + cupHeight * 0.6;

    // เงาหลอด
    canvas.save();
    canvas.translate(2, 2);
    _drawSingleStraw(canvas, strawX + 2, strawTopY, strawBottomY, strawWidth,
        Colors.black.withValues(alpha: 0.15));
    canvas.restore();

    // หลอดหลัก - สีแดงเข้ม
    _drawSingleStraw(canvas, strawX, strawTopY, strawBottomY, strawWidth,
        const Color(0xFFB71C1C)); // สีแดงเข้ม

    // ลายขาว-แดงบนหลอด (ลดความสว่าง)
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // วาดลายขีดขาวบนหลอด
    for (double y = strawTopY + 20; y < strawBottomY; y += 25) {
      canvas.drawLine(
        Offset(strawX - 2, y),
        Offset(strawX + 2, y + 8),
        stripePaint,
      );
    }
  }

  void _drawSingleStraw(Canvas canvas, double x, double topY, double bottomY,
      double width, Color color) {
    final strawPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // วาดหลอดแบบเอียง
    final path = Path()
      ..moveTo(x - width / 2, topY)
      ..lineTo(x + width / 2, topY)
      ..lineTo(x + width / 2 + 3, bottomY)
      ..lineTo(x - width / 2 + 3, bottomY)
      ..close();

    canvas.drawPath(path, strawPaint);
  }

  void _drawCupBody(Canvas canvas, double cx, double topY, Color color, bool isMain) {
    final path = Path()
      ..moveTo(cx - cupWidth / 2, topY + 10)
      ..lineTo(cx + cupWidth / 2, topY + 10)
      ..lineTo(cx + cupWidth / 2 - 6, topY + cupHeight)
      ..quadraticBezierTo(
        cx,
        topY + cupHeight + 8,
        cx - cupWidth / 2 + 6,
        topY + cupHeight,
      )
      ..close();

    final paint = Paint()
      ..color = color
      ..style = isMain ? PaintingStyle.fill : PaintingStyle.fill;

    if (isMain) {
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(cx - cupWidth / 2, topY, cupWidth, cupHeight));
    }

    canvas.drawPath(path, paint);
  }

  void _drawRim(Canvas canvas, double cx, double topY) {
    // เงา rim
    canvas.save();
    canvas.translate(2, 2);
    final shadowRim = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - cupWidth / 2 - 4, topY + 4, cupWidth + 8, 10),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      shadowRim,
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
    canvas.restore();

    // Rim หลัก
    final rim = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - cupWidth / 2 - 4, topY + 4, cupWidth + 8, 10),
      const Radius.circular(6),
    );

    // พื้นหลัง rim
    canvas.drawRRect(
      rim,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );

    // ขอบ rim
    canvas.drawRRect(
      rim,
      Paint()
        ..color = Colors.grey.shade300.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawLiquid(Canvas canvas, double cx, double topY) {
    if (!hasIngredients) return;

    final liquidHeight = cupHeight * 0.85;
    final liquidTop = topY + cupHeight - liquidHeight + 12;

    // คลิปเฉพาะพื้นที่แก้ว
    final clipPath = Path()
      ..moveTo(cx - cupWidth / 2, topY + 10)
      ..lineTo(cx + cupWidth / 2, topY + 10)
      ..lineTo(cx + cupWidth / 2 - 6, topY + cupHeight)
      ..quadraticBezierTo(
        cx,
        topY + cupHeight + 8,
        cx - cupWidth / 2 + 6,
        topY + cupHeight,
      )
      ..close();

    canvas.save();
    canvas.clipPath(clipPath);

    // น้ำในแก้ว - gradient
    final liquidRect = Rect.fromLTWH(cx - cupWidth / 2, liquidTop, cupWidth, liquidHeight);
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          liquidColor.withValues(alpha: 0.7),
          liquidColor.withValues(alpha: 0.85),
          liquidColor.withValues(alpha: 0.75),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(liquidRect);
    canvas.drawRect(liquidRect, liquidPaint);

    // เส้นผิวน้ำ
    canvas.drawRect(
      Rect.fromLTWH(cx - cupWidth / 2, liquidTop, cupWidth, 3),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    canvas.restore();
  }

  void _drawReflections(Canvas canvas, double cx, double topY) {
    // แสงสะท้อนซ้าย
    final leftReflection = Path()
      ..moveTo(cx - cupWidth / 2 + 8, topY + 15)
      ..lineTo(cx - cupWidth / 2 + 8, topY + cupHeight * 0.6)
      ..lineTo(cx - cupWidth / 2 + 14, topY + cupHeight * 0.55)
      ..lineTo(cx - cupWidth / 2 + 14, topY + 15)
      ..close();

    canvas.drawPath(
      leftReflection,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    // แสงสะท้อนขวา
    final rightReflection = Path()
      ..moveTo(cx + cupWidth / 2 - 12, topY + 20)
      ..lineTo(cx + cupWidth / 2 - 12, topY + 45)
      ..lineTo(cx + cupWidth / 2 - 6, topY + 43)
      ..lineTo(cx + cupWidth / 2 - 6, topY + 18)
      ..close();

    canvas.drawPath(
      rightReflection,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawOutline(Canvas canvas, double cx, double topY) {
    final outlinePath = Path()
      ..moveTo(cx - cupWidth / 2, topY + 10)
      ..lineTo(cx + cupWidth / 2, topY + 10)
      ..lineTo(cx + cupWidth / 2 - 6, topY + cupHeight)
      ..quadraticBezierTo(
        cx,
        topY + cupHeight + 8,
        cx - cupWidth / 2 + 6,
        topY + cupHeight,
      )
      ..close();

    canvas.drawPath(
      outlinePath,
      Paint()
        ..color = Colors.grey.shade400.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CupPainter old) =>
      old.liquidColor != liquidColor ||
      old.hasIngredients != hasIngredients ||
      old.strawLength != strawLength;
}
