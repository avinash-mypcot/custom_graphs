// ============================================================
// health_charts.dart — Reusable Health Chart Library
// Unified axis/grid theme across ALL charts (matches glucose
// chart design: arrow-tipped axes, fine grid, rotated labels).
// All charts fully configurable via constructors.
// Y-axis values computed dynamically from data.
// ============================================================
// ignore_for_file: deprecated_member_use

library;

import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================
// SECTION 1 — SHARED THEME / SPACING MODELS
// ============================================================

/// Padding around the chart plot area.
class ChartPadding {
  final double left;
  final double right;
  final double top;
  final double bottom;

  const ChartPadding({
    this.left = 34.0,
    this.right = 12.0,
    this.top = 26.0,
    this.bottom = 64.0,
  });
}

/// Visual theme shared across ALL charts.
/// Defaults match the glucose chart screenshot exactly:
///   - light gray grid lines (horizontal + vertical sub-grid)
///   - thin gray axes with arrowhead tips
///   - small tick marks on Y axis
///   - rotated X labels
class ChartTheme {
  // Grid
  final Color gridColor;
  final double gridStrokeWidth;
  final bool showVerticalGrid; // sub-grid vertical lines
  final Color verticalGridColor;
  final double verticalGridStrokeWidth;

  // Axes
  final Color axisColor;
  final double axisStrokeWidth;
  final double arrowSize; // arrowhead half-width & length

  // Tick marks on Y axis
  final bool showYTicks;
  final double yTickLength;
  final Color yTickColor;
  final double yTickStrokeWidth;

  // Labels
  final Color labelColor;
  final Color dateLabelColor;
  final double labelFontSize;

  const ChartTheme({
    this.gridColor = const Color(0xFFE8E8E8),
    this.gridStrokeWidth = 0.8,
    this.showVerticalGrid = true,
    this.verticalGridColor = const Color(0xFFF0F0F0),
    this.verticalGridStrokeWidth = 0.6,
    this.axisColor = const Color(0xFFBBBBBB),
    this.axisStrokeWidth = 1.2,
    this.arrowSize = 5.0,
    this.showYTicks = true,
    this.yTickLength = 4.0,
    this.yTickColor = const Color(0xFFBBBBBB),
    this.yTickStrokeWidth = 1.0,
    this.labelColor = const Color(0xFFAAAAAA),
    this.dateLabelColor = const Color(0xFFE57373),
    this.labelFontSize = 9.0,
  });
}

// ============================================================
// SECTION 2 — SHARED AXIS / GRID PAINTER  (used by all charts)
// ============================================================

/// Draws the complete axis system identical across all charts:
///  • horizontal grid lines at each Y step
///  • optional vertical sub-grid lines
///  • Y axis line with upward arrowhead
///  • X axis line with rightward arrowhead
///  • small tick marks on Y axis beside each grid line
///  • Y-axis numeric labels (right-aligned, left of axis)
void _paintAxisSystem({
  required Canvas canvas,
  required double lP, // left padding
  required double tP, // top padding
  required double cW, // chart width
  required double cH, // chart height
  required int steps,
  required double stepValue,
  required double maxV,
  required ChartTheme theme,
  required int xCount, // number of x points (for vertical sub-grid)
}) {
  final gridPaint = Paint()
    ..color = theme.gridColor
    ..strokeWidth = theme.gridStrokeWidth;

  final vGridPaint = Paint()
    ..color = theme.verticalGridColor
    ..strokeWidth = theme.verticalGridStrokeWidth;

  final axisPaint = Paint()
    ..color = theme.axisColor
    ..strokeWidth = theme.axisStrokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final tickPaint = Paint()
    ..color = theme.yTickColor
    ..strokeWidth = theme.yTickStrokeWidth;

  // ── Horizontal grid lines ───────────────────────────────
  for (int i = 0; i <= steps; i++) {
    final y = tP + cH - (i / steps) * cH;
    canvas.drawLine(Offset(lP, y), Offset(lP + cW, y), gridPaint);

    // tick mark
    if (theme.showYTicks) {
      canvas.drawLine(
        Offset(lP - theme.yTickLength, y),
        Offset(lP, y),
        tickPaint,
      );
    }
  }

  // ── Vertical sub-grid lines ─────────────────────────────
  if (theme.showVerticalGrid && xCount > 1) {
    final xStep = cW / (xCount - 1);
    for (int i = 0; i < xCount; i++) {
      final x = lP + i * xStep;
      canvas.drawLine(Offset(x, tP), Offset(x, tP + cH), vGridPaint);
    }
  }

  // ── Y axis (vertical line + upward arrow) ───────────────
  final a = theme.arrowSize;
  canvas.drawLine(Offset(lP, tP + cH), Offset(lP, tP - a), axisPaint);
  // arrowhead triangle (up)
  final yArrow = Path()
    ..moveTo(lP, tP - a * 2)
    ..lineTo(lP - a * 0.6, tP - a * 0.4)
    ..lineTo(lP + a * 0.6, tP - a * 0.4)
    ..close();
  canvas.drawPath(yArrow, Paint()..color = theme.axisColor);

  // ── X axis (horizontal line + rightward arrow) ──────────
  canvas.drawLine(Offset(lP, tP + cH), Offset(lP + cW + a, tP + cH), axisPaint);
  // arrowhead triangle (right)
  final xArrow = Path()
    ..moveTo(lP + cW + a * 2, tP + cH)
    ..lineTo(lP + cW + a * 0.4, tP + cH - a * 0.6)
    ..lineTo(lP + cW + a * 0.4, tP + cH + a * 0.6)
    ..close();
  canvas.drawPath(xArrow, Paint()..color = theme.axisColor);

  // ── Y-axis numeric labels ───────────────────────────────
  for (int i = 0; i <= steps; i++) {
    final val = i * stepValue;
    final y = tP + cH - (val / maxV) * cH;
    _paintTxt(
      canvas,
      _fmtVal(val),
      Offset(0, y - 6),
      theme.labelFontSize,
      theme.labelColor,
      align: TextAlign.right,
      maxW: lP - theme.yTickLength - 2,
    );
  }
}

// ── Vertical-grid variant for bar charts (uniform spacing) ──
void _paintAxisSystemBar({
  required Canvas canvas,
  required double lP,
  required double tP,
  required double cW,
  required double cH,
  required int steps,
  required double stepValue,
  required double maxV,
  required ChartTheme theme,
  required int barCount,
  required double groupSpacing,
}) {
  final gridPaint = Paint()
    ..color = theme.gridColor
    ..strokeWidth = theme.gridStrokeWidth;

  final vGridPaint = Paint()
    ..color = theme.verticalGridColor
    ..strokeWidth = theme.verticalGridStrokeWidth;

  final axisPaint = Paint()
    ..color = theme.axisColor
    ..strokeWidth = theme.axisStrokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final tickPaint = Paint()
    ..color = theme.yTickColor
    ..strokeWidth = theme.yTickStrokeWidth;

  // Horizontal grid
  for (int i = 0; i <= steps; i++) {
    final y = tP + cH - (i / steps) * cH;
    canvas.drawLine(Offset(lP, y), Offset(lP + cW, y), gridPaint);
    if (theme.showYTicks) {
      canvas.drawLine(
        Offset(lP - theme.yTickLength, y),
        Offset(lP, y),
        tickPaint,
      );
    }
  }

  // Vertical sub-grid (one line per bar group)
  if (theme.showVerticalGrid && barCount > 0) {
    final gW = (cW - (barCount - 1) * groupSpacing) / barCount;
    for (int i = 0; i < barCount; i++) {
      final x = lP + i * (gW + groupSpacing) + gW / 2;
      canvas.drawLine(Offset(x, tP), Offset(x, tP + cH), vGridPaint);
    }
  }

  // Y axis + arrow
  final a = theme.arrowSize;
  canvas.drawLine(Offset(lP, tP + cH), Offset(lP, tP - a), axisPaint);
  final yArrow = Path()
    ..moveTo(lP, tP - a * 2)
    ..lineTo(lP - a * 0.6, tP - a * 0.4)
    ..lineTo(lP + a * 0.6, tP - a * 0.4)
    ..close();
  canvas.drawPath(yArrow, Paint()..color = theme.axisColor);

  // X axis + arrow
  canvas.drawLine(Offset(lP, tP + cH), Offset(lP + cW + a, tP + cH), axisPaint);
  final xArrow = Path()
    ..moveTo(lP + cW + a * 2, tP + cH)
    ..lineTo(lP + cW + a * 0.4, tP + cH - a * 0.6)
    ..lineTo(lP + cW + a * 0.4, tP + cH + a * 0.6)
    ..close();
  canvas.drawPath(xArrow, Paint()..color = theme.axisColor);

  // Y labels
  for (int i = 0; i <= steps; i++) {
    final val = i * stepValue;
    final y = tP + cH - (val / maxV) * cH;
    _paintTxt(
      canvas,
      _fmtVal(val),
      Offset(0, y - 6),
      theme.labelFontSize,
      theme.labelColor,
      align: TextAlign.right,
      maxW: lP - theme.yTickLength - 2,
    );
  }
}

// ============================================================
// SECTION 3 — INTERNAL DRAWING HELPERS
// ============================================================

void _draw3DBar(
  Canvas canvas,
  double x,
  double baseY,
  double barW,
  double barH,
  Color frontColor, {
  double depth = 10,
  double depthAngle = 0.45,
  double notchDepth = 4,
  double shadowWidthFactor = 1.0,
  double sideNotchFactor = 0,
  bool isTopTriangle = false,
}) {
  if (barH <= 0) return;

  barW = barW / 1.5;

  final dy = depth * depthAngle;
  final top = baseY - barH;
  final right = x + barW;
  final shadowWidth = barW * shadowWidthFactor;
  final sideNotch = notchDepth * sideNotchFactor;

  // Left shadow face
  final sidePath = Path()
    ..moveTo(x, top)
    ..lineTo(x - shadowWidth, top - dy)
    ..lineTo(x - shadowWidth, baseY - dy - sideNotch)
    ..lineTo(x, baseY)
    ..close();

  final sideColor = Color.fromARGB(
    frontColor.alpha,
    (frontColor.red * .62).round(),
    (frontColor.green * .62).round(),
    (frontColor.blue * .62).round(),
  );
  canvas.drawPath(sidePath, Paint()..color = sideColor);

  // Top face
  final topColor = Color.fromARGB(
    frontColor.alpha,
    (frontColor.red * .75).round(),
    (frontColor.green * .75).round(),
    (frontColor.blue * .75).round(),
  );

  if (isTopTriangle) {
    canvas.drawPath(
      Path()
        ..moveTo(x, top)
        ..lineTo(x - shadowWidth, top - dy)
        ..lineTo(right - shadowWidth, top - dy)
        ..lineTo(right, top - notchDepth)
        ..close(),
      Paint()..color = topColor,
    );
  } else {
    canvas.drawPath(
      Path()
        ..moveTo(x, top)
        ..lineTo(x - shadowWidth, top - dy)
        ..lineTo(right - shadowWidth, top - dy - notchDepth)
        ..lineTo(right, top - notchDepth)
        ..close(),
      Paint()..color = topColor,
    );
  }

  // Front face
  canvas.drawPath(
    Path()
      ..moveTo(x, top)
      ..lineTo(right, top - notchDepth)
      ..lineTo(right, baseY - notchDepth - sideNotch)
      ..lineTo(x, baseY)
      ..close(),
    Paint()..color = frontColor,
  );
}

void _paintTxt(
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

void _paintRotated(
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

({double niceMax, int steps, double stepValue}) _niceScale(double rawMax) {
  if (rawMax <= 0) return (niceMax: 10, steps: 5, stepValue: 2);
  const List<double> niceSteps = [1, 2, 2.5, 5, 10, 20, 25, 40, 50, 100, 200];
  const targetSteps = 5;
  final roughStep = rawMax / targetSteps;
  final niceStep = niceSteps.firstWhere(
    (s) => s >= roughStep,
    orElse: () => niceSteps.last,
  );
  final niceMax = (rawMax / niceStep).ceil() * niceStep;
  final steps = (niceMax / niceStep).round();
  return (niceMax: niceMax.toDouble(), steps: steps, stepValue: niceStep);
}

String _fmtVal(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

// ============================================================
// SECTION 4 — LEGEND ENTRY
// ============================================================

class LegendEntry {
  final Color color;
  final String label;
  const LegendEntry({required this.color, required this.label});
}

// ============================================================
// SECTION 5 — GLUCOSE LINE CHART
// ============================================================

class GlucosePoint {
  final String label;
  final double deviceValue;
  final double? manualValue;
  final String? dateLabel;
  final bool highlight;

  const GlucosePoint({
    required this.label,
    required this.deviceValue,
    this.manualValue,
    this.dateLabel,
    this.highlight = false,
  });
}

class GlucoseLineChartColors {
  final Color deviceLine;
  final Color manualLine;
  final Color highlightDot;
  final Color highlightRing;

  const GlucoseLineChartColors({
    this.deviceLine = const Color(0xFFF9A58C),
    this.manualLine = const Color(0xFF7EB8D4),
    this.highlightDot = const Color(0xFFF48877),
    this.highlightRing = const Color(0xFFF48877),
  });
}

class GlucoseLineChartStyle {
  final double lineStrokeWidth;
  final double dotRadius;
  final double ringRadius;
  final String deviceLegendLabel;
  final String manualLegendLabel;

  const GlucoseLineChartStyle({
    this.lineStrokeWidth = 2.2,
    this.dotRadius = 3.5,
    this.ringRadius = 5.0,
    this.deviceLegendLabel = 'Device',
    this.manualLegendLabel = 'Manual',
  });
}

class GlucoseLineChart extends StatelessWidget {
  final List<GlucosePoint> points;
  final ChartPadding padding;
  final ChartTheme theme;
  final GlucoseLineChartColors colors;
  final GlucoseLineChartStyle style;

  const GlucoseLineChart({
    super.key,
    required this.points,
    this.padding = const ChartPadding(left: 34, right: 12, top: 26, bottom: 64),
    this.theme = const ChartTheme(),
    this.colors = const GlucoseLineChartColors(),
    this.style = const GlucoseLineChartStyle(),
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: _GlucoseLinePainter(
        points: points,
        padding: padding,
        theme: theme,
        colors: colors,
        style: style,
      ),
    ),
  );
}

class _GlucoseLinePainter extends CustomPainter {
  final List<GlucosePoint> points;
  final ChartPadding padding;
  final ChartTheme theme;
  final GlucoseLineChartColors colors;
  final GlucoseLineChartStyle style;

  _GlucoseLinePainter({
    required this.points,
    required this.padding,
    required this.theme,
    required this.colors,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final lP = padding.left,
        rP = padding.right,
        tP = padding.top,
        bP = padding.bottom;
    final cW = size.width - lP - rP;
    final cH = size.height - tP - bP;
    final n = points.length;

    // Dynamic scale
    double rawMax = 0;
    for (final p in points) {
      if (p.deviceValue > rawMax) rawMax = p.deviceValue;
      if ((p.manualValue ?? 0) > rawMax) rawMax = p.manualValue!;
    }
    final scale = _niceScale(rawMax);
    final maxV = scale.niceMax;
    final steps = scale.steps;
    final stepVal = scale.stepValue;

    final xStep = n > 1 ? cW / (n - 1) : cW;

    Offset pt(int i, double v) =>
        Offset(lP + i * xStep, tP + cH - (v / maxV) * cH);

    // ── Unified axis system ───────────────────────────────
    _paintAxisSystem(
      canvas: canvas,
      lP: lP,
      tP: tP,
      cW: cW,
      cH: cH,
      steps: steps,
      stepValue: stepVal,
      maxV: maxV,
      theme: theme,
      xCount: n,
    );

    // ── Lines ─────────────────────────────────────────────
    void drawLine(List<Offset> os, Color c) {
      final path = Path()..moveTo(os[0].dx, os[0].dy);
      for (int i = 1; i < os.length; i++) path.lineTo(os[i].dx, os[i].dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = c
          ..strokeWidth = style.lineStrokeWidth
          ..style = PaintingStyle.stroke,
      );
    }

    drawLine([
      for (int i = 0; i < n; i++) pt(i, points[i].deviceValue),
    ], colors.deviceLine);

    final manualOffsets = <Offset>[];
    for (int i = 0; i < n; i++) {
      if (points[i].manualValue != null) {
        manualOffsets.add(pt(i, points[i].manualValue!));
      }
    }
    if (manualOffsets.length > 1) drawLine(manualOffsets, colors.manualLine);

    // ── Highlight dots ────────────────────────────────────
    for (int i = 0; i < n; i++) {
      if (!points[i].highlight) continue;
      final o = pt(i, points[i].deviceValue);
      canvas.drawCircle(
        o,
        8,
        Paint()..color = colors.highlightRing.withOpacity(0.25),
      );
      canvas.drawCircle(o, style.ringRadius, Paint()..color = Colors.white);
      canvas.drawCircle(
        o,
        style.dotRadius,
        Paint()..color = colors.highlightDot,
      );
      _paintTxt(
        canvas,
        _fmtVal(points[i].deviceValue),
        Offset(o.dx - 16, o.dy - 20),
        10,
        const Color(0xFF444444),
        bold: true,
        maxW: 32,
        align: TextAlign.center,
      );
    }

    // ── X-axis labels ─────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final x = lP + i * xStep;
      if (points[i].dateLabel != null) {
        _paintRotated(
          canvas,
          points[i].dateLabel!,
          Offset(x, tP + cH + 2),
          8.5,
          theme.dateLabelColor,
          bold: true,
        );
      } else {
        _paintRotated(
          canvas,
          points[i].label,
          Offset(x, tP + cH + 2),
          8.5,
          theme.labelColor,
        );
      }
    }

    // ── Legend ────────────────────────────────────────────
    void legDot(double x, double y, Color c, String lbl) {
      canvas.drawCircle(
        Offset(x, y + 6),
        6,
        Paint()..color = c.withOpacity(0.4),
      );
      canvas.drawCircle(Offset(x, y + 6), 4, Paint()..color = c);
      _paintTxt(
        canvas,
        lbl,
        Offset(x + 10, y),
        10,
        const Color(0xFF777777),
        maxW: 60,
      );
    }

    legDot(size.width - 130, 2, colors.deviceLine, style.deviceLegendLabel);
    legDot(size.width - 68, 2, colors.manualLine, style.manualLegendLabel);
  }

  @override
  bool shouldRepaint(covariant _GlucoseLinePainter old) => old.points != points;
}

// ============================================================
// SECTION 6 — BLOOD PRESSURE BAR CHART
// ============================================================
({double max, double step, int count}) getScale(double value) {
  if (value <= 50) {
    return (max: 50, step: 10, count: 5);
  }

  if (value <= 100) {
    return (max: 100, step: 20, count: 5);
  }

  if (value <= 150) {
    return (max: 150, step: 30, count: 5);
  }

  if (value <= 200) {
    return (max: 200, step: 40, count: 5);
  }

  if (value <= 250) {
    return (max: 250, step: 50, count: 5);
  }

  return (
    max: ((value / 50).ceil() * 50).toDouble(),
    step: 50,
    count: (value / 50).ceil(),
  );
}

enum AbnormalType { none, diastolic, systolic, gFitDiastolic, gFitSystolic }

class BloodPressurePoint {
  final String label;
  final String? dateLabel;
  final int diastolic;
  final int systolic;
  final int gFitDiastolic;
  final int gFitSystolic;
  final AbnormalType abnormalType;

  const BloodPressurePoint({
    required this.label,
    this.dateLabel,
    required this.diastolic,
    required this.systolic,
    this.gFitDiastolic = 0,
    this.gFitSystolic = 0,
    this.abnormalType = AbnormalType.none,
  });
}

class BloodPressureColors {
  final Color systolicColor;
  final Color diastolicColor;
  final Color gFitSystolicColor;
  final Color gFitDiastolicColor;
  final Color abnormalColor;
  final Color axisColor;
  final Color gridColor;

  const BloodPressureColors({
    this.systolicColor = const Color(0xFFA8DDD0), // Light Teal
    this.diastolicColor = const Color(0xFF8BA5D4), // Muted Blue
    this.gFitSystolicColor = const Color(0xFFB0A8E0), // Lavender/Purple
    this.gFitDiastolicColor = const Color(0xFFFFBFA8), // Peach
    this.abnormalColor = const Color(0xFFF48877), // Soft Coral/Red
    this.axisColor = const Color(0xFFB0B0B0),
    this.gridColor = const Color(0xFFE5E5E5),
  });
}

class BloodPressureStyle {
  final double barWidth;
  final double barGap;
  final double groupSpacing;
  final double depth;
  final double abnormalSegmentValue;
  final String? yAxisTitle;

  const BloodPressureStyle({
    this.barWidth = 14.0,
    this.barGap = 4.0,
    this.groupSpacing = 24.0,
    this.depth = 6.0,
    this.abnormalSegmentValue = 15.0,
    this.yAxisTitle = 'Normal range - 90 / 140',
  });
}

class BloodPressureBarChart extends StatelessWidget {
  final List<BloodPressurePoint> points;
  final EdgeInsets padding;
  final ChartTheme theme;
  final BloodPressureColors colors;
  final BloodPressureStyle style;

  const BloodPressureBarChart({
    super.key,
    required this.points,
    this.padding = const EdgeInsets.only(
      left: 55,
      right: 20,
      top: 25,
      bottom: 65,
    ),
    this.theme = const ChartTheme(),
    this.colors = const BloodPressureColors(),
    this.style = const BloodPressureStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _BloodPressurePainter(
          points: points,
          padding: padding,
          theme: theme,
          colors: colors,
          style: style,
        ),
      ),
    );
  }
}

class _BloodPressurePainter extends CustomPainter {
  final List<BloodPressurePoint> points;
  final EdgeInsets padding;
  final ChartTheme theme;
  final BloodPressureColors colors;
  final BloodPressureStyle style;

  _BloodPressurePainter({
    required this.points,
    required this.padding,
    required this.theme,
    required this.colors,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final lP = padding.left;
    final rP = padding.right;
    final tP = padding.top;
    final bP = padding.bottom;

    final cW = size.width - lP - rP;
    final cH = size.height - tP - bP;
    double rawMax = 0;

    for (final b in points) {
      num total = b.systolic + b.diastolic;

      if (b.abnormalType != AbnormalType.none) {
        total += style.abnormalSegmentValue;
      }

      num gFitTotal = b.gFitSystolic + b.gFitDiastolic;

      rawMax = math.max(
        rawMax,
        math.max(total.toDouble(), gFitTotal.toDouble()),
      );
    }

    final scale = getScale(rawMax);

    final maxV = scale.max;
    final stepVal = scale.step;
    final steps = scale.count;
    final baseY = tP + cH;

    double bH(double v) => (v / maxV) * cH;

    // ====================================================
    // AXIS
    // ====================================================
    _paintAxisSystemBar(
      canvas: canvas,
      lP: lP,
      tP: tP,
      cW: cW,
      cH: cH,
      steps: steps,
      stepValue: stepVal,
      maxV: maxV,
      theme: theme,
      barCount: points.length,
      groupSpacing: style.groupSpacing,
    );

    // ====================================================
    // BAR POSITIONING
    // ====================================================

    final n = points.length;

    // Always reserve space for 8 groups
    const double startSpacing = 20; // adjust 15-30 as needed

    final slotWidth = (cW - startSpacing) / n;

    for (int i = 0; i < n; i++) {
      final b = points[i];

      final groupCenterX =
          lP + startSpacing + (i * slotWidth) + (slotWidth / 2);

      final leftBarX = groupCenterX - style.barWidth - (style.barGap / 2);

      final rightBarX = groupCenterX + (style.barGap / 2);

      // =========================
      // BP BARS
      // =========================

      final diastolicX = leftBarX;

      final systolicX = leftBarX + style.barWidth - 14;

      if (b.diastolic > 0) {
        final diaH = bH(b.diastolic.toDouble());

        _draw3DBar(
          canvas,
          diastolicX,
          baseY,
          style.barWidth,
          diaH,
          colors.diastolicColor,
          depth: style.depth,
        );
        // abnormal only on diastolic
        if (b.abnormalType == AbnormalType.diastolic) {
          final abnH = bH(style.abnormalSegmentValue);

          _draw3DBar(
            canvas,
            systolicX,
            baseY - diaH,
            style.barWidth,
            abnH,
            colors.abnormalColor,
            depth: style.depth,
          );
        }
      }

      if (b.systolic > 0) {
        final sysH = bH(b.systolic.toDouble());

        _draw3DBar(
          canvas,
          systolicX,
          baseY,
          style.barWidth,
          sysH,
          colors.systolicColor,
          depth: style.depth,
        );

        // abnormal only on systolic
        if (b.abnormalType == AbnormalType.systolic) {
          final abnH = bH(style.abnormalSegmentValue);

          _draw3DBar(
            canvas,
            systolicX,
            baseY - sysH,
            style.barWidth,
            abnH,
            colors.abnormalColor,
            depth: style.depth,
          );
        }
      }

      // =========================
      // GFIT BARS
      // =========================

      final gDiaX = rightBarX;

      final gSysX = rightBarX + style.barWidth - 14;

      if (b.gFitDiastolic > 0) {
        final h = bH(b.gFitDiastolic.toDouble());

        _draw3DBar(
          canvas,
          gDiaX,
          baseY,
          style.barWidth,
          h,
          colors.gFitDiastolicColor,
          depth: style.depth,
        );
      }

      if (b.gFitSystolic > 0) {
        final h = bH(b.gFitSystolic.toDouble());

        _draw3DBar(
          canvas,
          gSysX,
          baseY,
          style.barWidth,
          h,
          colors.gFitSystolicColor,
          depth: style.depth,
        );
      }

      // =========================
      // LABELS
      // =========================

      // Always draw time
      _paintRotated(
        canvas,
        b.label,
        Offset(groupCenterX, baseY + 14),
        9,
        theme.labelColor,
      );

      // Draw date only when available
      if (b.dateLabel != null) {
        _paintRotated(
          canvas,
          b.dateLabel!,
          Offset(leftBarX, baseY + 14),
          9,
          theme.dateLabelColor,
          bold: true,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BloodPressurePainter oldDelegate) {
    return true;
  }
}

// ============================================================
// SECTION 7 — HEART RATE BAR CHART
// ============================================================

class HeartRatePoint {
  final String label;
  final String? dateLabel;
  final double? deviceValue;
  final double? manualValue;
  final double? abnormalValue;

  const HeartRatePoint({
    required this.label,
    this.dateLabel,
    this.deviceValue,
    this.manualValue,
    this.abnormalValue,
  });
}

class HeartRateColors {
  final Color deviceColor;
  final Color manualColor;
  final Color abnormalColor;

  const HeartRateColors({
    this.deviceColor = const Color(0xFFFBBFAA),
    this.manualColor = const Color(0xFF7EB8D4),
    this.abnormalColor = const Color(0xFFF48877),
  });
}

class HeartRateStyle {
  final double barWidth;
  final double overlapOffset;
  final double depth;
  final double groupSpacing;
  final String deviceLabel;
  final String manualLabel;
  final String abnormalLabel;

  const HeartRateStyle({
    this.barWidth = 22.0,
    this.overlapOffset = 20.0,
    this.depth = 10.0,
    this.groupSpacing = 12.0,
    this.deviceLabel = 'Device',
    this.manualLabel = 'Manual',
    this.abnormalLabel = 'Abnormal',
  });
}

class HeartRateBarChart extends StatelessWidget {
  final List<HeartRatePoint> points;
  final String? dateLabel;
  final ChartPadding padding;
  final ChartTheme theme;
  final HeartRateColors colors;
  final HeartRateStyle style;

  const HeartRateBarChart({
    super.key,
    required this.points,
    this.dateLabel,
    this.padding = const ChartPadding(left: 34, right: 12, top: 26, bottom: 56),
    this.theme = const ChartTheme(),
    this.colors = const HeartRateColors(),
    this.style = const HeartRateStyle(),
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: _HeartRatePainter(
        points: points,
        dateLabel: dateLabel,
        padding: padding,
        theme: theme,
        colors: colors,
        style: style,
      ),
    ),
  );
}

class _HeartRatePainter extends CustomPainter {
  final List<HeartRatePoint> points;
  final String? dateLabel;
  final ChartPadding padding;
  final ChartTheme theme;
  final HeartRateColors colors;
  final HeartRateStyle style;

  _HeartRatePainter({
    required this.points,
    required this.dateLabel,
    required this.padding,
    required this.theme,
    required this.colors,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final lP = padding.left,
        rP = padding.right,
        tP = padding.top,
        bP = padding.bottom;
    final cW = size.width - lP - rP;
    final cH = size.height - tP - bP;
    final n = points.length;

    double rawMax = 0;
    for (final p in points) {
      if ((p.deviceValue ?? 0) > rawMax) rawMax = p.deviceValue!;
      if ((p.manualValue ?? 0) > rawMax) rawMax = p.manualValue!;
      if ((p.abnormalValue ?? 0) > rawMax) rawMax = p.abnormalValue!;
    }
    final scale = _niceScale(rawMax);
    final maxV = scale.niceMax;
    final steps = scale.steps;
    final stepVal = scale.stepValue;

    const totalSlots = 5;
    final gW = cW / totalSlots;
    final depth = style.depth;
    final oo = style.overlapOffset;
    final bw = style.barWidth;

    // ── Unified axis system ───────────────────────────────
    _paintAxisSystemBar(
      canvas: canvas,
      lP: lP,
      tP: tP,
      cW: cW,
      cH: cH,
      steps: steps,
      stepValue: stepVal,
      maxV: maxV,
      theme: theme,
      barCount: n,
      groupSpacing: style.groupSpacing,
    );

    // ── Legend ────────────────────────────────────────────
    void legDot(double x, double y, Color c, String lbl) {
      canvas.drawCircle(
        Offset(x, y + 6),
        6,
        Paint()..color = c.withOpacity(0.4),
      );
      canvas.drawCircle(Offset(x, y + 6), 4, Paint()..color = c);
      _paintTxt(
        canvas,
        lbl,
        Offset(x + 10, y),
        9.5,
        const Color(0xFF777777),
        maxW: 72,
      );
    }

    legDot(size.width - 210, 2, colors.deviceColor, style.deviceLabel);
    legDot(size.width - 140, 2, colors.manualColor, style.manualLabel);
    legDot(size.width - 68, 2, colors.abnormalColor, style.abnormalLabel);

    // ── Bars ──────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final item = points[i];
      final cx = lP + (i + 0.75) * gW;
      final baseY = tP + cH;
      double currentX = cx;

      if (item.abnormalValue != null) {
        _draw3DBar(
          canvas,
          currentX,
          baseY,
          bw,
          (item.abnormalValue! / maxV) * cH,
          colors.abnormalColor,
          depth: depth,
          sideNotchFactor: 1,
          isTopTriangle: true,
        );
        currentX -= oo;
      }
      if (item.deviceValue != null) {
        _draw3DBar(
          canvas,
          currentX,
          baseY,
          bw,
          (item.deviceValue! / maxV) * cH,
          colors.deviceColor,
          depth: depth,
          sideNotchFactor: 1,
          isTopTriangle: true,
        );
        currentX -= oo;
      }
      if (item.manualValue != null) {
        _draw3DBar(
          canvas,
          currentX,
          baseY,
          bw,
          (item.manualValue! / maxV) * cH,
          colors.manualColor,
          depth: depth,
          sideNotchFactor: 1,
          isTopTriangle: true,
        );
        currentX -= oo;
      }

      if (item.dateLabel != null) {
        _paintRotated(
          canvas,
          item.dateLabel!,
          Offset(cx - 20, baseY + 10),
          8.5,
          theme.dateLabelColor,
          bold: true,
        );
      } else {
        _paintRotated(
          canvas,
          item.label,
          Offset(cx - 20, baseY + 10),
          10,
          theme.labelColor,
        );
      }
    }

    if (dateLabel != null) {
      _paintRotated(
        canvas,
        dateLabel!,
        Offset(lP + gW * 0.25, tP + cH + 2),
        8.5,
        theme.dateLabelColor,
        bold: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeartRatePainter old) => old.points != points;
}

// ============================================================
// SECTION 8 — WATER INTAKE BAR CHART
// ============================================================

class WaterIntakePoint {
  final String label;
  final double value;
  final bool isToday;
  final bool isHighlight;

  const WaterIntakePoint({
    required this.label,
    required this.value,
    this.isToday = false,
    this.isHighlight = false,
  });
}

class WaterIntakeColors {
  final Color todayBar;
  final Color todayBorder;
  final Color highlightBar;
  final Color highlightBorder;
  final Color defaultBar;
  final Color defaultBorder;

  const WaterIntakeColors({
    this.todayBar = const Color(0xFFA8DDD0),
    this.todayBorder = const Color(0xFF3ABFA3),
    this.highlightBar = const Color(0xFF8BA5C8),
    this.highlightBorder = const Color(0xFF6688AA),
    this.defaultBar = const Color(0xFFF9A58C),
    this.defaultBorder = const Color(0xFFF48877),
  });
}

class WaterIntakeStyle {
  final double depth;
  final double bubbleRadius;
  final double bubbleStrokeWidth;
  final double bubbleFontSize;
  final double labelFontSize;
  final double groupSpacing;
  final String yAxisTitle;

  const WaterIntakeStyle({
    this.depth = 10.0,
    this.bubbleRadius = 16.0,
    this.bubbleStrokeWidth = 2.2,
    this.bubbleFontSize = 11.0,
    this.labelFontSize = 11.0,
    this.groupSpacing = 0.0,
    this.yAxisTitle = 'Number of litre',
  });
}

class WaterIntakeBarChart extends StatelessWidget {
  final List<WaterIntakePoint> points;
  final ChartPadding padding;
  final ChartTheme theme;
  final WaterIntakeColors colors;
  final WaterIntakeStyle style;

  const WaterIntakeBarChart({
    super.key,
    required this.points,
    this.padding = const ChartPadding(left: 34, right: 12, top: 34, bottom: 30),
    this.theme = const ChartTheme(),
    this.colors = const WaterIntakeColors(),
    this.style = const WaterIntakeStyle(),
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: _WaterIntakePainter(
        points: points,
        padding: padding,
        theme: theme,
        colors: colors,
        style: style,
      ),
    ),
  );
}

class _WaterIntakePainter extends CustomPainter {
  final List<WaterIntakePoint> points;
  final ChartPadding padding;
  final ChartTheme theme;
  final WaterIntakeColors colors;
  final WaterIntakeStyle style;

  _WaterIntakePainter({
    required this.points,
    required this.padding,
    required this.theme,
    required this.colors,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final lP = padding.left,
        rP = padding.right,
        tP = padding.top,
        bP = padding.bottom;
    final cW = size.width - lP - rP;
    final cH = size.height - tP - bP;
    final n = points.length;

    double rawMax = points.map((p) => p.value).reduce(max);
    final scale = _niceScale(rawMax);
    final maxV = scale.niceMax;
    final steps = scale.steps;
    final stepVal = scale.stepValue;

    final gW = cW / n;
    final depth = style.depth;

    // ── Unified axis system ───────────────────────────────
    _paintAxisSystemBar(
      canvas: canvas,
      lP: lP,
      tP: tP,
      cW: cW,
      cH: cH,
      steps: steps,
      stepValue: stepVal,
      maxV: maxV,
      theme: theme,
      barCount: n,
      groupSpacing: style.groupSpacing,
    );

    // Y title
    _paintRotated(
      canvas,
      style.yAxisTitle,
      Offset(10, tP + cH / 2 + 38),
      8.5,
      const Color(0xFF999999),
    );

    final barW = (gW * 0.48).clamp(18.0, 38.0);

    for (int i = 0; i < n; i++) {
      final item = points[i];
      final cx = lP + i * gW + gW / 2 + depth * 0.5;
      final baseY = tP + cH;
      final barHpx = (item.value / maxV) * cH;

      Color frontColor, borderColor;
      if (item.isToday) {
        frontColor = colors.todayBar;
        borderColor = colors.todayBorder;
      } else if (item.isHighlight) {
        frontColor = colors.highlightBar;
        borderColor = colors.highlightBorder;
      } else {
        frontColor = colors.defaultBar;
        borderColor = colors.defaultBorder;
      }

      _draw3DBar(
        canvas,
        cx - barW / 2,
        baseY,
        barW,
        barHpx,
        frontColor,
        depth: depth,
      );

      // Bubble
      final r = style.bubbleRadius;
      final bubbleY = baseY - barHpx - depth * 0.45 - r - 5;
      canvas.drawCircle(Offset(cx, bubbleY), r, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(cx, bubbleY),
        r,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.bubbleStrokeWidth,
      );

      final tp2 = TextPainter(
        text: TextSpan(
          text: _fmtVal(item.value),
          style: TextStyle(
            fontSize: style.bubbleFontSize,
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
          text: item.label,
          style: TextStyle(
            fontSize: style.labelFontSize,
            color: item.isToday ? colors.todayBorder : const Color(0xFF888888),
            fontWeight: item.isToday ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dp.paint(canvas, Offset(cx - dp.width / 2, baseY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _WaterIntakePainter old) => old.points != points;
}

// ============================================================
// SECTION 9 — CHART CARD WRAPPER
// ============================================================

class ChartCard extends StatelessWidget {
  final Widget chart;
  final double height;
  final String? title;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final List<BoxShadow> shadows;

  const ChartCard({
    super.key,
    required this.chart,
    this.height = 280,
    this.title,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.padding = const EdgeInsets.fromLTRB(10, 14, 14, 10),
    this.shadows = const [
      BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 5)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: shadows,
          ),
          padding: padding,
          child: chart,
        ),
      ],
    );
  }
}

// ============================================================
// SECTION 10 — EXAMPLE USAGE
// ============================================================
//
// Paste the block below into your main.dart and remove comments:

void main() => runApp(const _ExampleApp());

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF4F6FA)),
      home: Scaffold(
        appBar: AppBar(title: const Text('Health Dashboard')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ChartCard(
                title: 'Blood Glucose (mmol/L)',
                height: 280,
                chart: GlucoseLineChart(
                  points: const [
                    GlucosePoint(
                      label: '6:00 am',
                      deviceValue: 6.0,
                      manualValue: 6.5,
                      dateLabel: '24/01/2026',
                      highlight: true,
                    ),
                    GlucosePoint(
                      label: '7:00 am',
                      deviceValue: 6.0,
                      manualValue: 6.5,
                    ),
                    GlucosePoint(
                      label: '7:30 am',
                      deviceValue: 16.0,
                      manualValue: 16.5,
                    ),
                    GlucosePoint(
                      label: '8:00 am',
                      deviceValue: 7.2,
                      manualValue: 7.0,
                    ),
                    GlucosePoint(
                      label: '12:30 pm',
                      deviceValue: 6.5,
                      manualValue: 6.0,
                      highlight: true,
                    ),
                    GlucosePoint(
                      label: '6:00 pm',
                      deviceValue: 10.5,
                      manualValue: 11.5,
                      highlight: true,
                    ),
                    GlucosePoint(
                      label: '11:00 pm',
                      deviceValue: 7.9,
                      manualValue: 7.2,
                      highlight: true,
                    ),
                    GlucosePoint(
                      label: '11:00 pm',
                      deviceValue: 7.9,
                      manualValue: 7.2,
                      highlight: true,
                    ),
                    GlucosePoint(
                      label: '11:00 pm',
                      deviceValue: 7.9,
                      manualValue: 7.2,
                      highlight: true,
                    ),
                    GlucosePoint(
                      label: '11:00 pm',
                      deviceValue: 7.9,
                      manualValue: 7.2,
                      highlight: true,
                    ),
                    GlucosePoint(
                      label: '6:00 am',
                      deviceValue: 3.2,
                      manualValue: 3.5,
                      dateLabel: '25/01/2026',
                    ),
                    GlucosePoint(
                      label: '8:00 am',
                      deviceValue: 2.5,
                      manualValue: 4.5,
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ChartCard(
                title: 'Blood Pressure (mmHg)',
                height: 320,
                chart: BloodPressureBarChart(
                  points: const [
                    BloodPressurePoint(
                      label: '10:20 am',
                      dateLabel: '24/01/2026',
                      diastolic: 180,
                      systolic: 55,
                    ),
                    BloodPressurePoint(
                      label: '4:00 pm',
                      diastolic: 85,
                      systolic: 60,
                      gFitDiastolic: 30,
                    ),
                    BloodPressurePoint(
                      label: '4:30 pm',
                      diastolic: 85,
                      systolic: 60,
                      gFitDiastolic: 30,
                    ),
                    BloodPressurePoint(
                      label: '5:00 pm',
                      diastolic: 85,
                      systolic: 60,
                      gFitDiastolic: 30,
                    ),
                    BloodPressurePoint(
                      label: '6:00 pm',
                      diastolic: 90,
                      systolic: 55,
                      abnormalType: AbnormalType.diastolic,
                    ),
                    BloodPressurePoint(
                      label: '8:30 pm',
                      diastolic: 90,
                      systolic: 60,
                      gFitSystolic: 5,
                      abnormalType: AbnormalType.systolic,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ChartCard(
                title: 'Heart Rate (BPM)',
                height: 300,
                chart: HeartRateBarChart(
                  dateLabel: '24/01/2026',
                  points: const [
                    HeartRatePoint(
                      label: '6:00 am',
                      deviceValue: 90,
                      manualValue: 75,
                    ),
                    HeartRatePoint(
                      label: '8:00 am',
                      // deviceValue: 142,
                      manualValue: 118,
                      abnormalValue: 135,
                    ),
                    HeartRatePoint(
                      label: '10:00 am',
                      deviceValue: 92,
                      manualValue: 75,
                    ),
                    HeartRatePoint(
                      label: '12:30 pm',
                      deviceValue: 90,
                      manualValue: 75,
                    ),
                    HeartRatePoint(
                      label: '2:30 pm',
                      deviceValue: 138,
                      manualValue: 75,
                      abnormalValue: 145,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ChartCard(
                title: 'Water Intake (Litres)',
                height: 240,
                chart: WaterIntakeBarChart(
                  points: const [
                    WaterIntakePoint(label: 'Mon', value: 2.5),
                    WaterIntakePoint(
                      label: 'Tue',
                      value: 3.9,
                      isHighlight: true,
                    ),
                    WaterIntakePoint(label: 'Wed', value: 2.2),
                    WaterIntakePoint(label: 'Thu', value: 2.5),
                    WaterIntakePoint(
                      label: 'Fri',
                      value: 3.8,
                      isHighlight: true,
                    ),
                    WaterIntakePoint(
                      label: 'Sat',
                      value: 4.0,
                      isHighlight: true,
                    ),
                    WaterIntakePoint(label: 'Sun', value: 5.0, isToday: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
