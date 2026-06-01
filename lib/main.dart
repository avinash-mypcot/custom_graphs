import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const HealthDashboardApp());
}

class HealthDashboardApp extends StatelessWidget {
  const HealthDashboardApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF4F6FA)),
      home: const HealthDashboardScreen(),
    );
  }
}

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Health Dashboard',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('Blood Glucose (mmol/L)'),
            const SizedBox(height: 8),
            _chartCard(const GlucoseLineChart(), 280),
            const SizedBox(height: 20),
            _sectionTitle('Blood Pressure (mmHg)'),
            const SizedBox(height: 8),
            _chartCard(const BloodPressureBarChart(), 320),
            const SizedBox(height: 20),
            _sectionTitle('Heart Rate (BPM)'),
            const SizedBox(height: 8),
            _chartCard(const HeartRateBarChart(), 300),
            const SizedBox(height: 20),
            _sectionTitle('Water Intake (Litres)'),
            const SizedBox(height: 8),
            _chartCard(const WaterIntakeBarChart(), 240),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: Color(0xFF2D3748),
    ),
  );

  Widget _chartCard(Widget chart, double height) => Container(
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(10, 14, 14, 10),
    child: chart,
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3D BAR HELPER
// Draws a bar with a front face, top face, and right side face to create depth
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
void draw3DBar(
  Canvas canvas,
  double x,
  double baseY,
  double barW,
  double barH,
  Color frontColor, {
  double depth = 10,
  double depthAngle = 0.45,

  // Customization
  double notchDepth = 4,
  double shadowWidthFactor = 1.0,
  double sideNotchFactor = 0,
  double topSlopeDepth = 4.0,
  bool isTopTrangle = false,
}) {
  if (barH <= 0) return;

  barW = barW / 1.5;

  final dy = depth * depthAngle;

  final top = baseY - barH;
  final right = x + barW;

  final shadowWidth = barW * shadowWidthFactor;

  // Amount of notch applied on left shadow side
  final sideNotch = notchDepth * sideNotchFactor;

  // ─────────────────────────────────────────────
  // LEFT SHADOW FACE
  // ─────────────────────────────────────────────
  final sidePath = Path()
    ..moveTo(x, top)
    ..lineTo(x - shadowWidth, top - dy) // top-left notch
    ..lineTo(x - shadowWidth, baseY - dy - sideNotch) // bottom-left notch
    ..lineTo(x, baseY)
    ..close();

  final sideColor = Color.fromARGB(
    frontColor.alpha,
    (frontColor.red * .62).round(),
    (frontColor.green * .62).round(),
    (frontColor.blue * .62).round(),
  );

  canvas.drawPath(sidePath, Paint()..color = sideColor);

  // ─────────────────────────────────────────────
  // TOP FACE
  // ─────────────────────────────────────────────
  if (isTopTrangle) {
    final topPath = Path()
      ..moveTo(x, top)
      ..lineTo(x - shadowWidth, top - dy)
      ..lineTo(right - shadowWidth, top - dy)
      ..lineTo(right, top - notchDepth)
      ..close();

    final topColor = Color.fromARGB(
      frontColor.alpha,
      (frontColor.red * 0.75).round(),
      (frontColor.green * 0.75).round(),
      (frontColor.blue * 0.75).round(),
    );

    canvas.drawPath(topPath, Paint()..color = topColor);
  } else {
    final topPath = Path()
      ..moveTo(x, top)
      ..lineTo(x - shadowWidth, top - dy)
      ..lineTo(right - shadowWidth, top - dy - notchDepth)
      ..lineTo(right, top - notchDepth)
      ..close();

    final topColor = Color.fromARGB(
      frontColor.alpha,
      (frontColor.red * .75).round(),
      (frontColor.green * .75).round(),
      (frontColor.blue * .75).round(),
    );

    canvas.drawPath(topPath, Paint()..color = topColor);
  }

  // ─────────────────────────────────────────────
  // FRONT FACE
  // ─────────────────────────────────────────────
  final frontPath = Path()
    ..moveTo(x, top)
    ..lineTo(right, top - notchDepth) // DO NOT TOUCH
    ..lineTo(right, baseY - notchDepth - sideNotch) // only bottom affected
    ..lineTo(x, baseY)
    ..close();
  canvas.drawPath(frontPath, Paint()..color = frontColor);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHARED TEXT HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
void paintTxt(
  Canvas canvas,
  String text,
  Offset origin,
  double fs,
  Color color, {
  bool bold = false,
  TextAlign align = TextAlign.left,
  double maxW = 200,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fs,
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
  )..layout(maxWidth: maxW);
  final ox = align == TextAlign.right ? origin.dx + maxW - tp.width : origin.dx;
  tp.paint(canvas, Offset(ox, origin.dy));
}

void paintRotated(
  Canvas canvas,
  String text,
  Offset pivot,
  double fs,
  Color color, {
  bool bold = false,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fs,
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  canvas.save();
  canvas.translate(pivot.dx, pivot.dy);
  canvas.rotate(-pi / 2);
  tp.paint(canvas, Offset(-tp.width, -tp.height / 2));
  canvas.restore();
}

void paintGrid(
  Canvas canvas,
  double leftPad,
  double topPad,
  double cW,
  double cH,
  int steps,
  double maxVal,
) {
  final p = Paint()
    ..color = const Color(0xFFEEEEEE)
    ..strokeWidth = 1;
  for (int i = 0; i <= steps; i++) {
    final y = topPad + cH - (i / steps) * cH;
    canvas.drawLine(Offset(leftPad, y), Offset(leftPad + cW, y), p);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. GLUCOSE LINE CHART  (no 3D bars — keeps lines clean)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GlucoseLineChart extends StatelessWidget {
  const GlucoseLineChart({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: GlucoseLinePainter(),
    ),
  );
}

class _GP {
  final String label;
  final double val;
  final String? date;
  final bool hl;
  const _GP(this.label, this.val, this.date, this.hl);
}

class GlucoseLinePainter extends CustomPainter {
  final pts = const [
    _GP('6:00 am', 6.0, '24/01', false),
    _GP('8:00 am', 7.2, null, false),
    _GP('10:00 am', 8.5, null, false),
    _GP('12:30 pm', 6.5, null, true),
    _GP('2:00 pm', 4.5, null, false),
    _GP('4:30 pm', 9.0, null, false),
    _GP('6:00 pm', 10.5, null, true),
    _GP('7:00 pm', 8.0, null, false),
    _GP('9:00 pm', 15.0, null, false),
    _GP('11:00 pm', 7.9, null, true),
    _GP('6:00 am', 3.2, '24/01', false),
    _GP('8:00 am', 2.5, null, true),
    _GP('10:00 am', 5.0, null, false),
    _GP('12:30 pm', 8.0, null, false),
    _GP('2:00 pm', 11.0, null, false),
    _GP('4:30 pm', 13.0, null, false),
  ];
  final manV = const [
    6.5,
    7.0,
    8.2,
    6.0,
    5.0,
    8.8,
    11.5,
    9.0,
    14.5,
    7.2,
    3.5,
    4.5,
    6.0,
    9.0,
    11.5,
    13.0,
  ];

  static const lP = 34.0, rP = 12.0, tP = 26.0, bP = 64.0, maxV = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cW = size.width - lP - rP, cH = size.height - tP - bP, n = pts.length;
    final step = cW / (n - 1);
    Offset p(int i, double v) =>
        Offset(lP + i * step, tP + cH - (v / maxV) * cH);

    paintGrid(canvas, lP, tP, cW, cH, 10, maxV);
    for (int i = 0; i <= 10; i++) {
      final y = tP + cH - (i * 2 / maxV) * cH;
      paintTxt(
        canvas,
        '${i * 2}',
        Offset(0, y - 6),
        9,
        const Color(0xFFAAAAAA),
        align: TextAlign.right,
        maxW: lP - 3,
      );
    }

    // device fill
    final aPath = Path()..moveTo(p(0, pts[0].val).dx, tP + cH);
    for (int i = 0; i < n; i++)
      aPath.lineTo(p(i, pts[i].val).dx, p(i, pts[i].val).dy);
    aPath
      ..lineTo(p(n - 1, pts[n - 1].val).dx, tP + cH)
      ..close();
    canvas.drawPath(
      aPath,
      Paint()..color = const Color(0xFFF9A58C).withOpacity(0.20),
    );

    // lines
    void drawLine(List<Offset> os, Color c) {
      final path = Path()..moveTo(os[0].dx, os[0].dy);
      for (int i = 1; i < os.length; i++) path.lineTo(os[i].dx, os[i].dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = c
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke,
      );
    }

    drawLine([
      for (int i = 0; i < n; i++) p(i, pts[i].val),
    ], const Color(0xFFF9A58C));
    drawLine([
      for (int i = 0; i < n; i++) p(i, manV[i]),
    ], const Color(0xFF7EB8D4));

    // dots
    for (int i = 0; i < n; i++) {
      if (!pts[i].hl) continue;
      final o = p(i, pts[i].val);
      canvas.drawCircle(
        o,
        8,
        Paint()..color = const Color(0xFFF48877).withOpacity(0.25),
      );
      canvas.drawCircle(o, 5, Paint()..color = Colors.white);
      canvas.drawCircle(o, 3.5, Paint()..color = const Color(0xFFF48877));
      final s = pts[i].val % 1 == 0
          ? '${pts[i].val.toInt()}'
          : pts[i].val.toStringAsFixed(1);
      paintTxt(
        canvas,
        s,
        Offset(o.dx - 16, o.dy - 20),
        10,
        const Color(0xFF444444),
        bold: true,
        maxW: 32,
        align: TextAlign.center,
      );
    }

    // X labels
    for (int i = 0; i < n; i++) {
      final x = lP + i * step, y = tP + cH;
      if (pts[i].date != null) {
        paintRotated(
          canvas,
          '24/01/2026',
          Offset(x, y + 2),
          8.5,
          const Color(0xFFE57373),
          bold: true,
        );
      } else {
        paintRotated(
          canvas,
          pts[i].label,
          Offset(x, y + 2),
          8.5,
          const Color(0xFFAAAAAA),
        );
      }
    }

    // axes
    final axP = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(lP, tP), Offset(lP, tP + cH), axP);
    canvas.drawLine(Offset(lP, tP + cH), Offset(lP + cW, tP + cH), axP);

    // legend
    void legDot(double x, double y, Color c, String lbl) {
      canvas.drawCircle(
        Offset(x, y + 6),
        6,
        Paint()..color = c.withOpacity(0.4),
      );
      canvas.drawCircle(Offset(x, y + 6), 4, Paint()..color = c);
      paintTxt(
        canvas,
        lbl,
        Offset(x + 10, y),
        10,
        const Color(0xFF777777),
        maxW: 60,
      );
    }

    legDot(size.width - 130, 2, const Color(0xFFF9A58C), 'Device');
    legDot(size.width - 68, 2, const Color(0xFF7EB8D4), 'Manual');
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. BLOOD PRESSURE — 3D STACKED BARS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BloodPressureBarChart extends StatelessWidget {
  const BloodPressureBarChart({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: BloodPressurePainter(),
    ),
  );
}

class _BP {
  final String label;
  final String? date;
  final int dia, sys, gDia, gSys;
  final bool abnormal;
  const _BP(
    this.label,
    this.date,
    this.dia,
    this.sys,
    this.gDia,
    this.gSys,
    this.abnormal,
  );
}

class BloodPressurePainter extends CustomPainter {
  final bars = const [
    _BP('10:20 am', '24/01', 90, 55, 0, 0, false),
    _BP('4:00 pm', null, 85, 60, 30, 0, false),
    _BP('6:00 pm', null, 90, 55, 0, 0, true),
    _BP('8:30 pm', null, 90, 60, 0, 5, true),
    _BP('10:20 am', '25/01', 90, 55, 0, 0, false),
    _BP('4:00 pm', null, 88, 50, 0, 0, false),
    _BP('6:00 pm', null, 88, 50, 0, 0, false),
    _BP('8:30 pm', null, 80, 30, 0, 0, false),
    _BP('', '25/01', 75, 25, 0, 0, false),
  ];

  static const lP = 10.0;
  static const rP = 150.0;
  static const tP = 22.0;
  static const bP = 110.0;
  static const maxV = 280.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cW = size.width - lP - rP;
    final cH = size.height - tP - bP;

    final n = bars.length;

    const groupSpacing = 12.0;
    final gW = (cW - ((n - 1) * groupSpacing)) / n;

    const barW = 14.0;
    const gap = 10.0;
    const segmentGap = 0.0;
    const depth = 7.0;

    paintGrid(canvas, lP, tP, cW, cH, 7, maxV);

    for (int i = 0; i <= 7; i++) {
      final val = i * 40;
      final y = tP + cH - (val / maxV) * cH;

      paintTxt(canvas, '$val', Offset(lP, y - 6), 9, const Color(0xFFAAAAAA));
    }

    double barH(double v) => (v / maxV) * cH;

    for (int i = 0; i < n; i++) {
      final b = bars[i];

      final cx = lP + i * (gW + groupSpacing) + gW / 2 + depth * 0.6;

      final baseY = tP + cH;

      // Left Bar
      double curH = 0;

      final diaH = barH(b.dia.toDouble());
      final sysH = barH(b.sys.toDouble());

      draw3DBar(
        canvas,
        cx - barW - gap,
        baseY - curH,
        barW,
        diaH,
        const Color(0xFF8BA5D4),
        depth: depth,
      );

      curH += diaH + segmentGap;

      draw3DBar(
        canvas,
        cx - barW - gap,
        baseY - curH,
        barW,
        sysH,
        const Color(0xFFA8DDD0),
        depth: depth,
      );

      curH += sysH + segmentGap;

      if (b.abnormal) {
        draw3DBar(
          canvas,
          cx - barW - gap,
          baseY - curH,
          barW,
          14,
          const Color(0xFFF48877),
          depth: depth,
        );
      }

      // Right Bar (G Fit)
      if (b.gDia > 0 || b.gSys > 0) {
        double cr = 0;

        if (b.gDia > 0) {
          final gDiaH = barH(90);

          draw3DBar(
            canvas,
            cx + gap,
            baseY - cr,
            barW,
            gDiaH,
            const Color(0xFFB0A8E0),
            depth: depth,
          );

          cr += gDiaH + segmentGap;
        }

        if (b.gSys > 0) {
          final gSysH = barH(50);

          draw3DBar(
            canvas,
            cx + gap,
            baseY - cr,
            barW,
            gSysH,
            const Color(0xFFFFBFA8),
            depth: depth,
          );
        }
      }

      // Labels
      if (b.date != null) {
        paintRotated(
          canvas,
          '${b.date}/2026',
          Offset(cx, tP + cH + 18),
          8.5,
          const Color(0xFFE57373),
          bold: true,
        );
      } else if (b.label.isNotEmpty) {
        paintRotated(
          canvas,
          b.label,
          Offset(cx, tP + cH + 18),
          8.5,
          const Color(0xFF888888),
        );
      }
    }

    // Axes
    final axP = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(lP, tP), Offset(lP, tP + cH), axP);

    canvas.drawLine(Offset(lP, tP + cH), Offset(lP + cW, tP + cH), axP);

    // Legend
    final lx = lP + cW + 20;
    double ly = tP + 12;

    void leg(Color c, String lbl) {
      canvas.drawRect(Rect.fromLTWH(lx, ly, 10, 10), Paint()..color = c);

      paintTxt(
        canvas,
        lbl,
        Offset(lx + 16, ly - 1),
        9.5,
        const Color(0xFF666666),
        maxW: 120,
      );

      ly += 24;
    }

    leg(const Color(0xFFA8DDD0), 'Systolic');
    leg(const Color(0xFF8BA5D4), 'Diastolic');
    leg(const Color(0xFFB0A8E0), 'G fit Systolic');
    leg(const Color(0xFFFFBFA8), 'G fit Diastolic');
    leg(const Color(0xFFF48877), 'Above / below normal');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. HEART RATE — 3D GROUPED BARS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HeartRateBarChart extends StatelessWidget {
  const HeartRateBarChart({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: HeartRatePainter(),
    ),
  );
}

class _HR {
  final String label;
  final int? device;
  final int? manual;
  final int? abnormal;

  const _HR({required this.label, this.device, this.manual, this.abnormal});
}

class HeartRatePainter extends CustomPainter {
  final data = const [
    _HR(label: '6:00 am', device: 90, manual: 75),
    _HR(label: '8:00 am', device: 142, manual: 118, abnormal: 135),
    _HR(label: '10:00 am', device: 92, manual: 75),
    _HR(label: '12:30 pm', device: 90, manual: 75),
    _HR(label: '2:30 pm', device: 138, manual: 75, abnormal: 145),
  ];

  static const lP = 34.0, rP = 12.0, tP = 26.0, bP = 56.0, maxV = 200.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cW = size.width - lP - rP,
        cH = size.height - tP - bP,
        n = data.length;
    final gW = cW / (n + 1);
    const barW = 22.0, gap = 3.0, depth = 10.0;

    paintGrid(canvas, lP, tP, cW, cH, 5, maxV);
    for (int i = 0; i <= 5; i++) {
      final val = i * 40;
      final y = tP + cH - (val / maxV) * cH;
      paintTxt(
        canvas,
        '$val',
        Offset(0, y - 6),
        9,
        const Color(0xFFAAAAAA),
        align: TextAlign.right,
        maxW: lP - 3,
      );
    }

    // legend at top right
    void legDot(double x, double y, Color c, String lbl) {
      canvas.drawCircle(
        Offset(x, y + 6),
        6,
        Paint()..color = c.withOpacity(0.4),
      );
      canvas.drawCircle(Offset(x, y + 6), 4, Paint()..color = c);
      paintTxt(
        canvas,
        lbl,
        Offset(x + 10, y),
        9.5,
        const Color(0xFF777777),
        maxW: 72,
      );
    }

    legDot(size.width - 210, 2, const Color(0xFFFBBFAA), 'Device');
    legDot(size.width - 140, 2, const Color(0xFF7EB8D4), 'Manual');
    legDot(size.width - 68, 2, const Color(0xFFF48877), 'Abnormal');

    for (int i = 0; i < n; i++) {
      final item = data[i];

      final cx = lP + (i + 0.75) * gW;
      final baseY = tP + cH;

      const overlapOffset = 20.0;
      const barWidth = 22.0;

      // Manual
      if (item.abnormal != null) {
        final h = (item.abnormal! / maxV) * cH;

        draw3DBar(
          canvas,
          cx + overlapOffset * 2,
          baseY,
          barWidth,
          h,
          const Color(0xFFF48877),
          depth: depth,
          sideNotchFactor: 1,
          isTopTrangle: true,
        );
      }

      if (item.device != null) {
        final h = (item.device! / maxV) * cH;

        draw3DBar(
          canvas,
          cx + overlapOffset,
          baseY,
          barWidth,
          h,
          const Color(0xFFFBBFAA),
          depth: depth,
          sideNotchFactor: 1,
          isTopTrangle: true,
        );
      }

      if (item.manual != null) {
        final h = (item.manual! / maxV) * cH;

        draw3DBar(
          canvas,
          cx,
          baseY,
          barWidth,
          h,
          const Color(0xFF7EB8D4),
          depth: depth,
          sideNotchFactor: 1,
          isTopTrangle: true,
        );
      }
      paintRotated(
        canvas,
        item.label,
        Offset(cx, baseY + 2),
        9,
        const Color(0xFFAAAAAA),
      );
    }

    // date label
    paintRotated(
      canvas,
      '24/01/2026',
      Offset(lP + gW * 0.25, tP + cH + 2),
      8.5,
      const Color(0xFFE57373),
      bold: true,
    );

    // axes
    final axP = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(lP, tP), Offset(lP, tP + cH), axP);
    canvas.drawLine(Offset(lP, tP + cH), Offset(lP + cW, tP + cH), axP);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. WATER INTAKE — 3D SINGLE BARS with bubbles
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class WaterIntakeBarChart extends StatelessWidget {
  const WaterIntakeBarChart({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: WaterIntakePainter(),
    ),
  );
}

class _WB {
  final String day;
  final double value;
  final bool isToday;
  final bool isBlue;
  const _WB(this.day, this.value, this.isToday, this.isBlue);
}

class WaterIntakePainter extends CustomPainter {
  final data = const [
    _WB('Mon', 2.5, false, false),
    _WB('Tue', 3.9, false, true),
    _WB('Wed', 2.2, false, false),
    _WB('Thu', 2.5, false, false),
    _WB('Fri', 3.8, false, true),
    _WB('Sat', 4.0, false, true),
    _WB('Sun', 5.0, true, true),
  ];

  static const lP = 34.0, rP = 12.0, tP = 34.0, bP = 30.0, maxV = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cW = size.width - lP - rP,
        cH = size.height - tP - bP,
        n = data.length;
    final gW = cW / n;

    paintGrid(canvas, lP, tP, cW, cH, 5, maxV);
    for (int i = 0; i <= 5; i++) {
      final y = tP + cH - (i / maxV) * cH;
      paintTxt(
        canvas,
        '$i',
        Offset(0, y - 6),
        9,
        const Color(0xFFAAAAAA),
        align: TextAlign.right,
        maxW: lP - 3,
      );
    }

    // Y title
    paintRotated(
      canvas,
      'Number of litre',
      Offset(10, tP + cH / 2 + 38),
      8.5,
      const Color(0xFF999999),
    );

    final double barW = (gW * 0.48).clamp(18.0, 38.0);
    const double depth = 10.0;

    for (int i = 0; i < n; i++) {
      final item = data[i];
      final cx = lP + i * gW + gW / 2 + depth * 0.5;
      final baseY = tP + cH;
      final barH = (item.value / maxV) * cH;

      // pick colour
      Color frontColor;
      Color borderColor;
      if (item.isToday) {
        frontColor = const Color(0xFFA8DDD0);
        borderColor = const Color(0xFF3ABFA3);
      } else if (item.isBlue) {
        frontColor = const Color(0xFF8BA5C8);
        borderColor = const Color(0xFF6688AA);
      } else {
        frontColor = const Color(0xFFF9A58C);
        borderColor = const Color(0xFFF48877);
      }

      draw3DBar(
        canvas,
        cx - barW / 2,
        baseY,
        barW,
        barH,
        frontColor,
        depth: depth,
      );

      // Bubble
      const r = 16.0;
      final bubbleY = baseY - barH - depth * 0.45 - r - 5;
      canvas.drawCircle(Offset(cx, bubbleY), r, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(cx, bubbleY),
        r,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );

      final vs = item.value % 1 == 0
          ? '${item.value.toInt()}'
          : item.value.toStringAsFixed(1);
      final tp2 = TextPainter(
        text: TextSpan(
          text: vs,
          style: TextStyle(
            fontSize: 11,
            color: borderColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp2.paint(canvas, Offset(cx - tp2.width / 2, bubbleY - tp2.height / 2));

      // Day label
      final dp = TextPainter(
        text: TextSpan(
          text: item.day,
          style: TextStyle(
            fontSize: 11,
            color: item.isToday
                ? const Color(0xFF3ABFA3)
                : const Color(0xFF888888),
            fontWeight: item.isToday ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dp.paint(canvas, Offset(cx - dp.width / 2, baseY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
