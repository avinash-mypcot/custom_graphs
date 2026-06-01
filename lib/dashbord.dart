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
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const HealthDashboardScreen(),
    );
  }
}

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Health Dashboard',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Blood Glucose (mmol/L)'),
            const SizedBox(height: 8),
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(height: 260, child: GlucoseLineChart()),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Blood Pressure (mmHg)'),
            const SizedBox(height: 8),
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(height: 300, child: BloodPressureBarChart()),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Heart Rate (BPM)'),
            const SizedBox(height: 8),
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(height: 280, child: HeartRateBarChart()),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Water Intake (Litres)'),
            const SizedBox(height: 8),
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(height: 220, child: WaterIntakeBarChart()),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3748),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 1. GLUCOSE LINE CHART
// ─────────────────────────────────────────────
class GlucoseLineChart extends StatelessWidget {
  const GlucoseLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GlucoseLinePainter(),
    );
  }
}

class GlucoseLinePainter extends CustomPainter {
  // Device data: index → (label, value, highlighted)
  final List<Map<String, dynamic>> devicePoints = const [
    {'label': '6:00 am', 'value': 6.0, 'highlight': false, 'date': '24/01'},
    {'label': '8:00 am', 'value': 7.0, 'highlight': false, 'date': null},
    {'label': '10:00 am', 'value': 8.5, 'highlight': false, 'date': null},
    {'label': '12:30 pm', 'value': 6.5, 'highlight': true, 'date': null},
    {'label': '2:00 pm', 'value': 4.5, 'highlight': false, 'date': null},
    {'label': '4:30 pm', 'value': 9.0, 'highlight': false, 'date': null},
    {'label': '6:00 pm', 'value': 10.5, 'highlight': true, 'date': null},
    {'label': '7:00 pm', 'value': 8.0, 'highlight': false, 'date': null},
    {'label': '9:00 pm', 'value': 15.0, 'highlight': true, 'date': null},
    {'label': '11:00 pm', 'value': 7.9, 'highlight': false, 'date': null},
    {'label': '6:00 am', 'value': 3.0, 'highlight': false, 'date': '24/01'},
    {'label': '8:00 am', 'value': 2.5, 'highlight': true, 'date': null},
    {'label': '10:00 am', 'value': 5.0, 'highlight': false, 'date': null},
    {'label': '12:30 pm', 'value': 8.0, 'highlight': false, 'date': null},
    {'label': '2:00 pm', 'value': 11.0, 'highlight': false, 'date': null},
    {'label': '4:30 pm', 'value': 13.0, 'highlight': false, 'date': null},
  ];

  final List<Map<String, dynamic>> manualPoints = const [
    {'value': 6.5},
    {'value': 7.2},
    {'value': 8.0},
    {'value': 6.0},
    {'value': 5.0},
    {'value': 8.5},
    {'value': 11.5},
    {'value': 9.0},
    {'value': 14.5},
    {'value': 7.0},
    {'value': 3.5},
    {'value': 4.5},
    {'value': 6.0},
    {'value': 9.0},
    {'value': 11.5},
    {'value': 13.0},
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 36;
    const double rightPad = 12;
    const double topPad = 20;
    const double bottomPad = 60;
    const double maxVal = 20.0;
    const double minVal = 0.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;
    for (int i = 0; i <= 10; i++) {
      final y = topPad + chartH - (i * 2 / maxVal) * chartH;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );
      // Y labels
      final tp = TextPainter(
        text: TextSpan(
          text: '${i * 2}',
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    // Axes
    final axisPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(leftPad, topPad), Offset(leftPad, topPad + chartH), axisPaint);
    canvas.drawLine(
        Offset(leftPad, topPad + chartH), Offset(leftPad + chartW, topPad + chartH), axisPaint);

    final int n = devicePoints.length;
    final double step = chartW / (n - 1);

    Offset getOffset(int i, double val) {
      final x = leftPad + i * step;
      final y = topPad + chartH - ((val - minVal) / (maxVal - minVal)) * chartH;
      return Offset(x, y);
    }

    // Device area fill
    final devicePath = Path();
    devicePath.moveTo(getOffset(0, devicePoints[0]['value']).dx, topPad + chartH);
    for (int i = 0; i < n; i++) {
      final o = getOffset(i, devicePoints[i]['value'] as double);
      devicePath.lineTo(o.dx, o.dy);
    }
    devicePath.lineTo(getOffset(n - 1, devicePoints[n - 1]['value']).dx, topPad + chartH);
    devicePath.close();
    canvas.drawPath(
      devicePath,
      Paint()..color = const Color(0xFFFBB9A5).withOpacity(0.35),
    );

    // Device line
    final deviceLinePaint = Paint()
      ..color = const Color(0xFFF9A58C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final deviceLinePath = Path();
    for (int i = 0; i < n; i++) {
      final o = getOffset(i, devicePoints[i]['value'] as double);
      if (i == 0) deviceLinePath.moveTo(o.dx, o.dy);
      else deviceLinePath.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(deviceLinePath, deviceLinePaint);

    // Manual line
    final manualLinePaint = Paint()
      ..color = const Color(0xFF7EB8D4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final manualLinePath = Path();
    for (int i = 0; i < n; i++) {
      final o = getOffset(i, manualPoints[i]['value'] as double);
      if (i == 0) manualLinePath.moveTo(o.dx, o.dy);
      else manualLinePath.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(manualLinePath, manualLinePaint);

    // Highlight dots with labels
    for (int i = 0; i < n; i++) {
      if (devicePoints[i]['highlight'] == true) {
        final o = getOffset(i, devicePoints[i]['value'] as double);
        canvas.drawCircle(o, 6, Paint()..color = const Color(0xFFF48877));
        canvas.drawCircle(o, 4, Paint()..color = Colors.white);
        canvas.drawCircle(o, 3, Paint()..color = const Color(0xFFF48877));

        final val = devicePoints[i]['value'] as double;
        final tp = TextPainter(
          text: TextSpan(
            text: val.toString(),
            style: const TextStyle(fontSize: 10, color: Color(0xFF444444), fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy - 18));
      }
    }

    // X labels + date markers
    for (int i = 0; i < n; i++) {
      final label = devicePoints[i]['label'] as String;
      final date = devicePoints[i]['date'] as String?;
      final x = leftPad + i * step;
      final y = topPad + chartH;

      if (date != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: '24/01/2026',
            style: const TextStyle(fontSize: 9, color: Color(0xFFE57373), fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(x, y + 4);
        canvas.rotate(-pi / 2);
        tp.paint(canvas, Offset(-tp.width, -tp.height / 2));
        canvas.restore();
      } else {
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(x, y + 4);
        canvas.rotate(-pi / 2);
        tp.paint(canvas, Offset(-tp.width, -tp.height / 2));
        canvas.restore();
      }
    }

    // Legend
    _drawLegendDot(canvas, size.width - 130, 4, const Color(0xFFF9A58C), 'Device');
    _drawLegendDot(canvas, size.width - 70, 4, const Color(0xFF7EB8D4), 'Manual');
  }

  void _drawLegendDot(Canvas canvas, double x, double y, Color color, String label) {
    canvas.drawCircle(Offset(x, y + 6), 6, Paint()..color = color.withOpacity(0.5));
    canvas.drawCircle(Offset(x, y + 6), 4, Paint()..color = color);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x + 10, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// 2. BLOOD PRESSURE STACKED BAR CHART
// ─────────────────────────────────────────────
class BloodPressureBarChart extends StatelessWidget {
  const BloodPressureBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BloodPressurePainter());
  }
}

class BloodPressurePainter extends CustomPainter {
  // Each bar: {label, date, systolic, diastolic, gSystolic, gDiastolic, abnormal}
  final List<Map<String, dynamic>> bars = const [
    {'label': '10:20 am', 'date': '24/01', 'systolic': 55, 'diastolic': 90, 'gSystolic': 0, 'gDiastolic': 0, 'abnormal': false},
    {'label': '4:00 pm',  'date': null,     'systolic': 60, 'diastolic': 85, 'gSystolic': 30, 'gDiastolic': 0, 'abnormal': false},
    {'label': '6:00 pm',  'date': null,     'systolic': 55, 'diastolic': 90, 'gSystolic': 0,  'gDiastolic': 5, 'abnormal': true},
    {'label': '8:30 pm',  'date': null,     'systolic': 60, 'diastolic': 90, 'gSystolic': 0,  'gDiastolic': 0, 'abnormal': true},
    {'label': '10:20 am', 'date': '25/01',  'systolic': 55, 'diastolic': 90, 'gSystolic': 0,  'gDiastolic': 0, 'abnormal': false},
    {'label': '4:00 pm',  'date': null,     'systolic': 50, 'diastolic': 88, 'gSystolic': 0,  'gDiastolic': 0, 'abnormal': false},
    {'label': '6:00 pm',  'date': null,     'systolic': 50, 'diastolic': 88, 'gSystolic': 0,  'gDiastolic': 0, 'abnormal': false},
    {'label': '8:30 pm',  'date': null,     'systolic': 30, 'diastolic': 80, 'gSystolic': 0,  'gDiastolic': 0, 'abnormal': false},
    {'label': '',         'date': '25/01',  'systolic': 25, 'diastolic': 75, 'gSystolic': 0,  'gDiastolic': 0, 'abnormal': false},
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 42;
    const double rightPad = 8;
    const double topPad = 10;
    const double bottomPad = 60;
    const double maxVal = 280.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Grid & Y axis
    final gridPaint = Paint()..color = Colors.grey[200]!..strokeWidth = 1;
    for (int i = 0; i <= 7; i++) {
      final val = i * 40;
      final y = topPad + chartH - (val / maxVal) * chartH;
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + chartW, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$val', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 3, y - tp.height / 2));
    }

    // Normal range label
    final normTp = TextPainter(
      text: const TextSpan(
        text: 'Normal range - 90 / 140',
        style: TextStyle(fontSize: 9, color: Color(0xFF888888)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(10, topPad + chartH / 2 + normTp.width / 2);
    canvas.rotate(-pi / 2);
    normTp.paint(canvas, Offset(0, 0));
    canvas.restore();

    final int n = bars.length;
    final double barGroupW = chartW / n;
    const double barW = 16.0;
    const double barGap = 2.0;

    for (int i = 0; i < n; i++) {
      final bar = bars[i];
      final cx = leftPad + i * barGroupW + barGroupW / 2;
      final baseY = topPad + chartH;

      void drawSegment(double startVal, double heightVal, Color color) {
        if (heightVal <= 0) return;
        final y = baseY - ((startVal + heightVal) / maxVal) * chartH;
        final h = (heightVal / maxVal) * chartH;
        final rect = Rect.fromLTWH(cx - barW - barGap / 2, y, barW, h);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = color);
      }

      void drawSegmentRight(double startVal, double heightVal, Color color) {
        if (heightVal <= 0) return;
        final y = baseY - ((startVal + heightVal) / maxVal) * chartH;
        final h = (heightVal / maxVal) * chartH;
        final rect = Rect.fromLTWH(cx + barGap / 2, y, barW, h);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = color);
      }

      // Left bar: Systolic (teal) + Diastolic (purple/blue)
      drawSegment(0, bar['diastolic'] as double, const Color(0xFF8BA5D4));
      drawSegment(bar['diastolic'] as double, bar['systolic'] as double, const Color(0xFFA8DDD0));

      // Abnormal marker
      if (bar['abnormal'] == true) {
        final totalLeft = (bar['diastolic'] as int) + (bar['systolic'] as int);
        final topY = baseY - (totalLeft / maxVal) * chartH;
        final rect = Rect.fromLTWH(cx - barW - barGap / 2, topY - 10, barW, 10);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            Paint()..color = const Color(0xFFF48877));
      }

      // Right bar: G fit Systolic (lavender) + G fit Diastolic (peach)
      int gDia = bar['gDiastolic'] as int;
      int gSys = bar['gSystolic'] as int;
      if (gDia > 0 || gSys > 0) {
        drawSegmentRight(0, gDia > 0 ? 80 : 0, const Color(0xFFB8B0E0));
        drawSegmentRight(gDia > 0 ? 80 : 0, gSys > 0 ? 40 : 0, const Color(0xFFFFC8B0));
      }

      // X label
      final label = bar['label'] as String;
      final date = bar['date'] as String?;

      if (date != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$date/2026',
            style: const TextStyle(fontSize: 8, color: Color(0xFFE57373), fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(cx, baseY + 4);
        canvas.rotate(-pi / 2);
        tp.paint(canvas, Offset(-tp.width, -tp.height / 2));
        canvas.restore();
      } else if (label.isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(text: label, style: TextStyle(fontSize: 8, color: Colors.grey[500])),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(cx, baseY + 4);
        canvas.rotate(-pi / 2);
        tp.paint(canvas, Offset(-tp.width, -tp.height / 2));
        canvas.restore();
      }
    }

    // Legend
    _legend(canvas, size, [
      [const Color(0xFFA8DDD0), 'Systolic'],
      [const Color(0xFF8BA5D4), 'Diastolic'],
      [const Color(0xFFB8B0E0), 'G fit Systolic'],
      [const Color(0xFFFFC8B0), 'G fit Diastolic'],
      [const Color(0xFFF48877), 'Above or below normal'],
    ]);
  }

  void _legend(Canvas canvas, Size size, List<List<dynamic>> items) {
    double x = size.width - 150;
    double y = 4;
    for (final item in items) {
      canvas.drawRect(Rect.fromLTWH(x, y, 10, 10), Paint()..color = item[0] as Color);
      final tp = TextPainter(
        text: TextSpan(text: item[1] as String, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 13, y));
      y += 16;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// 3. HEART RATE 2D BAR CHART
// ─────────────────────────────────────────────
class HeartRateBarChart extends StatelessWidget {
  const HeartRateBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: HeartRatePainter());
  }
}

class HeartRatePainter extends CustomPainter {
  final List<Map<String, dynamic>> data = const [
    {'label': '6:00 am',  'device': 90,  'manual': 75,  'abnormal': false},
    {'label': '8:00 am',  'device': 142, 'manual': 118, 'abnormal': true},
    {'label': '10:00 am', 'device': 92,  'manual': 75,  'abnormal': false},
    {'label': '12:30 pm', 'device': 90,  'manual': 75,  'abnormal': false},
    {'label': '2:30 pm',  'device': 138, 'manual': 75,  'abnormal': true},
    {'label': '4:30 pm',  'device': 0,   'manual': 0,   'abnormal': false},
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 40;
    const double rightPad = 12;
    const double topPad = 16;
    const double bottomPad = 55;
    const double maxVal = 200.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Grid
    final gridPaint = Paint()..color = Colors.grey[200]!..strokeWidth = 1;
    for (int i = 0; i <= 5; i++) {
      final val = i * 40;
      final y = topPad + chartH - (val / maxVal) * chartH;
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + chartW, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$val', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 3, y - tp.height / 2));
    }

    // Axes
    final axisPaint = Paint()..color = Colors.grey[350]!..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(leftPad, topPad), Offset(leftPad, topPad + chartH), axisPaint);
    canvas.drawLine(Offset(leftPad, topPad + chartH), Offset(leftPad + chartW, topPad + chartH), axisPaint);

    final int n = data.length;
    final double groupW = chartW / n;
    const double barW = 18.0;
    const double gap = 3.0;

    for (int i = 0; i < n; i++) {
      final item = data[i];
      final cx = leftPad + i * groupW + groupW / 2;
      final baseY = topPad + chartH;

      final deviceH = ((item['device'] as int) / maxVal) * chartH;
      final manualH = ((item['manual'] as int) / maxVal) * chartH;

      if (item['device'] as int > 0) {
        // Device bar (peach) — right
        final dRect = Rect.fromLTWH(cx + gap / 2, baseY - deviceH, barW, deviceH);
        canvas.drawRRect(
          RRect.fromRectAndCorners(dRect, topLeft: const Radius.circular(3), topRight: const Radius.circular(3)),
          Paint()..color = item['abnormal'] == true ? const Color(0xFFF48877) : const Color(0xFFFBBFAA),
        );

        // Manual bar (blue) — left
        final mRect = Rect.fromLTWH(cx - barW - gap / 2, baseY - manualH, barW, manualH);
        canvas.drawRRect(
          RRect.fromRectAndCorners(mRect, topLeft: const Radius.circular(3), topRight: const Radius.circular(3)),
          Paint()..color = const Color(0xFF7EB8D4),
        );
      }

      // X label
      final tp = TextPainter(
        text: TextSpan(text: item['label'] as String, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(cx, baseY + 4);
      canvas.rotate(-pi / 2);
      tp.paint(canvas, Offset(-tp.width, -tp.height / 2));
      canvas.restore();
    }

    // Date label
    final dateTp = TextPainter(
      text: const TextSpan(
        text: '24/01/2026',
        style: TextStyle(fontSize: 9, color: Color(0xFFE57373), fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(leftPad - 4, topPad + chartH + 4);
    canvas.rotate(-pi / 2);
    dateTp.paint(canvas, Offset(-dateTp.width, -dateTp.height / 2));
    canvas.restore();

    // Legend
    _dot(canvas, size.width - 180, 4, const Color(0xFFFBBFAA), 'Device');
    _dot(canvas, size.width - 110, 4, const Color(0xFF7EB8D4), 'Manual');
    _dot(canvas, size.width - 45, 4, const Color(0xFFF48877), 'Abnormal');
  }

  void _dot(Canvas canvas, double x, double y, Color color, String label) {
    canvas.drawCircle(Offset(x, y + 5), 5, Paint()..color = color.withOpacity(0.6));
    canvas.drawCircle(Offset(x, y + 5), 3.5, Paint()..color = color);
    final tp = TextPainter(
      text: TextSpan(text: label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x + 8, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// 4. WATER INTAKE BAR CHART
// ─────────────────────────────────────────────
class WaterIntakeBarChart extends StatelessWidget {
  const WaterIntakeBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: WaterIntakePainter());
  }
}

class WaterIntakePainter extends CustomPainter {
  final List<Map<String, dynamic>> data = const [
    {'day': 'Mon', 'value': 2.5, 'isToday': false},
    {'day': 'Tue', 'value': 3.9, 'isToday': false},
    {'day': 'Wed', 'value': 2.2, 'isToday': false},
    {'day': 'Thu', 'value': 2.5, 'isToday': false},
    {'day': 'Fri', 'value': 3.8, 'isToday': false},
    {'day': 'Sat', 'value': 4.0, 'isToday': false},
    {'day': 'Sun', 'value': 5.0, 'isToday': true},
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 36;
    const double rightPad = 12;
    const double topPad = 32;
    const double bottomPad = 32;
    const double maxVal = 5.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Y axis grid
    final gridPaint = Paint()..color = Colors.grey[200]!..strokeWidth = 1;
    for (int i = 0; i <= 5; i++) {
      final y = topPad + chartH - (i / maxVal) * chartH;
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + chartW, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$i', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 3, y - tp.height / 2));
    }

    // Y title
    final yTitle = TextPainter(
      text: TextSpan(text: 'Number of litre', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(10, topPad + chartH / 2 + yTitle.width / 2);
    canvas.rotate(-pi / 2);
    yTitle.paint(canvas, Offset(0, 0));
    canvas.restore();

    final int n = data.length;
    final double groupW = chartW / n;
    const double barW = 26.0;

    for (int i = 0; i < n; i++) {
      final item = data[i];
      final double val = item['value'] as double;
      final bool isToday = item['isToday'] as bool;
      final cx = leftPad + i * groupW + groupW / 2;
      final baseY = topPad + chartH;
      final barH = (val / maxVal) * chartH;

      // Bar
      final barColor = isToday ? const Color(0xFFA8DDD0) : const Color(0xFFF9A58C);
      final rect = Rect.fromLTWH(cx - barW / 2, baseY - barH, barW, barH);
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(4), topRight: const Radius.circular(4)),
        Paint()..color = barColor,
      );

      // Value bubble on top
      final bubbleRadius = 14.0;
      final bubbleY = baseY - barH - bubbleRadius - 4;
      canvas.drawCircle(
        Offset(cx, bubbleY),
        bubbleRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(cx, bubbleY),
        bubbleRadius,
        Paint()
          ..color = barColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final valStr = val == val.roundToDouble() ? '${val.toInt()}' : val.toStringAsFixed(1);
      final valTp = TextPainter(
        text: TextSpan(
          text: valStr,
          style: TextStyle(
            fontSize: 10,
            color: isToday ? const Color(0xFF3ABFA3) : const Color(0xFFF48877),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(cx - valTp.width / 2, bubbleY - valTp.height / 2));

      // Day label
      final dayTp = TextPainter(
        text: TextSpan(
          text: item['day'] as String,
          style: TextStyle(
            fontSize: 11,
            color: isToday ? const Color(0xFF3ABFA3) : Colors.grey[600],
            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dayTp.paint(canvas, Offset(cx - dayTp.width / 2, baseY + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}