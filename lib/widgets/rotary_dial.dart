import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/passcode_provider.dart';


class RotaryDial extends StatefulWidget {
  const RotaryDial({super.key});

  @override
  State<RotaryDial> createState() => _RotaryDialState();
}

class _RotaryDialState extends State<RotaryDial> with TickerProviderStateMixin {
  // ─── Rotation state ────────────────────────────────────────────
  double _currentAngle = 0;
  double _startAngle = 0;

  int? _selectedNumber;
  int? _highlightedNumber;

  late AnimationController _returnController;
  late AnimationController _highlightController;
  late AnimationController _inertiaController;
  late Animation<double> _returnAnimation;
  late Animation<double> _highlightAnimation;

  // Number arrangement: 1-9 then 0, clockwise from top-right
  static const List<int> _numberOrder = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

  @override
  void initState() {
    super.initState();

    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _returnAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.easeOutCubic),
    );
    _returnController.addListener(() {
      setState(() {
        _currentAngle = _returnAnimation.value;
      });
    });
    _returnController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentAngle = 0;
      }
    });

    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _highlightAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeOut,
    ));

    _inertiaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _returnController.dispose();
    _highlightController.dispose();
    _inertiaController.dispose();
    super.dispose();
  }

  // ─── Angle helpers ──────────────────────────────────────────────

  int? _getNumberAtAngle(double rotationAngle) {
    if (rotationAngle < pi / 12) return null;

    double stepAngle = (2 * pi * 0.8) / 10;
    int steps = (rotationAngle / stepAngle).round();
    
    if (steps < 1) return null;
    if (steps > 10) steps = 10;

    return _numberOrder[steps - 1];
  }

  double _angleBetween(Offset center, Offset point) {
    return atan2(point.dy - center.dy, point.dx - center.dx);
  }

  // ─── Gesture handling ─────────────────────────────────────────
  void _onPanStart(DragStartDetails details, double dialSize) {
    _returnController.stop();
    _inertiaController.stop();
    final center = Offset(dialSize / 2, dialSize / 2);
    _startAngle = _angleBetween(center, details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details, double dialSize) {
    final center = Offset(dialSize / 2, dialSize / 2);
    final currentTouchAngle = _angleBetween(center, details.localPosition);
    double delta = currentTouchAngle - _startAngle;

    if (delta > pi) delta -= 2 * pi;
    if (delta < -pi) delta += 2 * pi;

    setState(() {
      _currentAngle += delta;
      if (_currentAngle < 0) _currentAngle = 0;
      if (_currentAngle > 2 * pi * 0.92) _currentAngle = 2 * pi * 0.92;

      _startAngle = currentTouchAngle;
      _highlightedNumber = _getNumberAtAngle(_currentAngle);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final number = _getNumberAtAngle(_currentAngle);

    if (number != null) {
      _selectedNumber = number;
      _highlightController.forward(from: 0);

      final provider = Provider.of<PasscodeProvider>(context, listen: false);
      provider.addDigit(number);
    }

    _highlightedNumber = null;

    _returnAnimation = Tween<double>(
      begin: _currentAngle,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.easeOutCubic,
    ));
    _returnController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dialSize = min(constraints.maxWidth, constraints.maxHeight) * 0.85;
        final outerRadius = dialSize / 2;
        final numberRadius = outerRadius * 0.72;
        final numberCircleRadius = outerRadius * 0.135;
        final centerHubRadius = outerRadius * 0.28;

        return Center(
          child: SizedBox(
            width: dialSize,
            height: dialSize,
            child: GestureDetector(
              onPanStart: (d) => _onPanStart(d, dialSize),
              onPanUpdate: (d) => _onPanUpdate(d, dialSize),
              onPanEnd: _onPanEnd,
              child: AnimatedBuilder(
                animation: _highlightAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _DialPainter(
                      isDark: isDark,
                      colorScheme: colorScheme,
                      rotationAngle: _currentAngle,
                      numberRadius: numberRadius,
                      numberCircleRadius: numberCircleRadius,
                      centerHubRadius: centerHubRadius,
                      selectedNumber: _selectedNumber,
                      highlightedNumber: _highlightedNumber,
                      highlightScale: _highlightAnimation.value,
                      numberOrder: _numberOrder,
                    ),
                    size: Size(dialSize, dialSize),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Premium 3D CustomPainter for the dial
// ═══════════════════════════════════════════════════════════════════
class _DialPainter extends CustomPainter {
  final bool isDark;
  final ColorScheme colorScheme;
  final double rotationAngle;
  final double numberRadius;
  final double numberCircleRadius;
  final double centerHubRadius;
  final int? selectedNumber;
  final int? highlightedNumber;
  final double highlightScale;
  final List<int> numberOrder;

  _DialPainter({
    required this.isDark,
    required this.colorScheme,
    required this.rotationAngle,
    required this.numberRadius,
    required this.numberCircleRadius,
    required this.centerHubRadius,
    required this.selectedNumber,
    required this.highlightedNumber,
    required this.highlightScale,
    required this.numberOrder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    // ═══════════════════════════════════════════════════════════════
    // LAYER 1: Deep outer shadow (3D lift effect)
    // ═══════════════════════════════════════════════════════════════
    final deepShadow = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.6 : 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center + const Offset(6, 8), outerRadius, deepShadow);

    // Secondary softer shadow
    final softShadow = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.3 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center + const Offset(3, 5), outerRadius + 5, softShadow);

    // ═══════════════════════════════════════════════════════════════
    // LAYER 2: Outer ring (metallic bezel)
    // ═══════════════════════════════════════════════════════════════
    // Outermost metallic bezel ring
    final bezelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF2A2D40), const Color(0xFF15172A), const Color(0xFF1E2035)]
            : [const Color(0xFFF0F0F8), const Color(0xFFD8DAE8), const Color(0xFFE6E8F2)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, bezelPaint);

    // Metallic top highlight on bezel
    final bezelHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.12 : 0.6),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius))
      ..style = PaintingStyle.fill;
    // Draw half circle for top shine
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height / 2));
    canvas.drawCircle(center, outerRadius - 1, bezelHighlight);
    canvas.restore();

    // ═══════════════════════════════════════════════════════════════
    // LAYER 3: Inner dial face (recessed area)
    // ═══════════════════════════════════════════════════════════════
    final innerRadius = outerRadius * 0.92;

    // Inner shadow (3D recess effect)
    final innerShadow = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.4 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center + const Offset(0, 2), innerRadius, innerShadow);

    // Inner face gradient
    final innerFace = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.2,
        colors: isDark
            ? [const Color(0xFF1E2038), const Color(0xFF141628), const Color(0xFF0E1020)]
            : [const Color(0xFFFFFFFF), const Color(0xFFECEDF6), const Color(0xFFE2E4F0)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, innerFace);

    // Inner bezel ring (subtle inset border)
    final innerBezel = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [Colors.white.withValues(alpha: 0.08), Colors.black.withValues(alpha: 0.3)]
            : [Colors.white.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.05)],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, innerRadius, innerBezel);

    // ═══════════════════════════════════════════════════════════════
    // LAYER 4: Track ring (where numbers sit)
    // ═══════════════════════════════════════════════════════════════
    final trackPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [Colors.white.withValues(alpha: 0.04), Colors.white.withValues(alpha: 0.01)]
            : [Colors.black.withValues(alpha: 0.04), Colors.black.withValues(alpha: 0.02)],
      ).createShader(Rect.fromCircle(center: center, radius: numberRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = numberCircleRadius * 2.6;
    canvas.drawCircle(center, numberRadius, trackPaint);

    // ═══════════════════════════════════════════════════════════════
    // LAYER 5: Finger stop indicator
    // ═══════════════════════════════════════════════════════════════
    final stopAngle = -pi / 2 - pi / 10;
    final stopPos = Offset(
      center.dx + (outerRadius * 0.88) * cos(stopAngle),
      center.dy + (outerRadius * 0.88) * sin(stopAngle),
    );

    // Glow behind stop
    final stopGlow = Paint()
      ..color = (isDark ? const Color(0xFF8B8EFF) : const Color(0xFF5C5FE0))
          .withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(stopPos, numberCircleRadius * 0.5, stopGlow);

    final stopPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isDark ? const Color(0xFFA0A3FF) : const Color(0xFF6B6EE8),
          isDark ? const Color(0xFF6C73FF) : const Color(0xFF4245B0),
        ],
      ).createShader(Rect.fromCircle(center: stopPos, radius: numberCircleRadius * 0.4));
    canvas.drawCircle(stopPos, numberCircleRadius * 0.35, stopPaint);

    // Stop highlight dot
    final stopShine = Paint()
      ..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(
      stopPos + const Offset(-1.5, -1.5),
      numberCircleRadius * 0.1,
      stopShine,
    );

    // ═══════════════════════════════════════════════════════════════
    // LAYER 6: Number circles (3D buttons)
    // ═══════════════════════════════════════════════════════════════
    for (int i = 0; i < 10; i++) {
      int number = numberOrder[i];
      double baseAngle = (2 * pi / 10) * i - pi / 2;
      double angle = baseAngle + rotationAngle;

      Offset numPos = Offset(
        center.dx + numberRadius * cos(angle),
        center.dy + numberRadius * sin(angle),
      );

      bool isHighlighted = highlightedNumber == number;
      bool isSelected = selectedNumber == number && highlightScale > 1.0;

      double scale = 1.0;
      if (isSelected) scale = highlightScale;
      if (isHighlighted) scale = 1.15;

      double effectiveRadius = numberCircleRadius * scale;

      // ── Deep shadow beneath button ──
      final btnDeepShadow = Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.5 : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(numPos + const Offset(2, 4), effectiveRadius, btnDeepShadow);

      // ── Ambient occlusion (dark ring) ──
      final aoShadow = Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.25 : 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(numPos + const Offset(0, 1), effectiveRadius + 1, aoShadow);

      // ── Button base fill (3D gradient) ──
      final btnBase = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHighlighted
              ? [
                  isDark ? const Color(0xFF9598FF) : const Color(0xFF7072E8),
                  isDark ? const Color(0xFF6568E8) : const Color(0xFF4A4DC0),
                ]
              : [
                  isDark ? const Color(0xFF2C2F48) : const Color(0xFFFFFFFF),
                  isDark ? const Color(0xFF1A1D32) : const Color(0xFFE0E2EE),
                ],
        ).createShader(Rect.fromCircle(center: numPos, radius: effectiveRadius));
      canvas.drawCircle(numPos, effectiveRadius, btnBase);

      // ── Top half highlight (3D dome effect) ──
      canvas.save();
      canvas.clipRect(Rect.fromCenter(
        center: numPos - Offset(0, effectiveRadius * 0.15),
        width: effectiveRadius * 2,
        height: effectiveRadius * 1.2,
      ));
      final domeHighlight = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.6),
          radius: 1.0,
          colors: [
            Colors.white.withValues(alpha: isHighlighted
                ? 0.35
                : (isDark ? 0.12 : 0.7)),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: numPos, radius: effectiveRadius));
      canvas.drawCircle(numPos, effectiveRadius, domeHighlight);
      canvas.restore();

      // ── Rim light (bottom edge reflection) ──
      final rimArc = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.06 : 0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: numPos, radius: effectiveRadius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawArc(
        Rect.fromCircle(center: numPos, radius: effectiveRadius - 0.5),
        pi * 0.15,
        pi * 0.7,
        false,
        rimArc,
      );

      // ── Outer border (crisp edge) ──
      final btnBorder = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHighlighted
              ? [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.15),
                ]
              : [
                  Colors.white.withValues(alpha: isDark ? 0.1 : 0.5),
                  Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                ],
        ).createShader(Rect.fromCircle(center: numPos, radius: effectiveRadius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(numPos, effectiveRadius, btnBorder);

      // ── Highlight glow ──
      if (isHighlighted) {
        final glowPaint = Paint()
          ..color = (isDark ? const Color(0xFF8B8EFF) : const Color(0xFF5C5FE0))
              .withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(numPos, effectiveRadius + 3, glowPaint);
      }

      // ── Number text ──
      final textPainter = TextPainter(
        text: TextSpan(
          text: number.toString(),
          style: TextStyle(
            color: isHighlighted
                ? Colors.white
                : (isDark ? const Color(0xFFD5D8F0) : const Color(0xFF2A2D4E)),
            fontSize: effectiveRadius * 0.95,
            fontWeight: FontWeight.w700,
            shadows: [
              if (isHighlighted)
                const Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              // Subtle text shadow for depth
              Shadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          numPos.dx - textPainter.width / 2,
          numPos.dy - textPainter.height / 2,
        ),
      );
    }

    // ═══════════════════════════════════════════════════════════════
    // LAYER 7: Center hub (3D metal knob)
    // ═══════════════════════════════════════════════════════════════
    
    // Hub deep shadow
    final hubDeepShadow = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.6 : 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center + const Offset(3, 5), centerHubRadius, hubDeepShadow);

    // Hub base (metallic gradient)
    final hubBase = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.2,
        colors: isDark
            ? [const Color(0xFF252845), const Color(0xFF181A30), const Color(0xFF101225)]
            : [const Color(0xFFF5F5FF), const Color(0xFFE0E2F0), const Color(0xFFD0D2E2)],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: centerHubRadius));
    canvas.drawCircle(center, centerHubRadius, hubBase);

    // Hub top shine (dome highlight)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
      center.dx - centerHubRadius,
      center.dy - centerHubRadius,
      centerHubRadius * 2,
      centerHubRadius * 1.1,
    ));
    final hubShine = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.7),
        radius: 0.9,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.15 : 0.6),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerHubRadius));
    canvas.drawCircle(center, centerHubRadius, hubShine);
    canvas.restore();

    // Hub metallic border ring
    final hubRing = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.2 : 0.7),
          Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerHubRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, centerHubRadius, hubRing);

    // Inner accent glow ring
    final innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? const Color(0xFF8B8EFF) : const Color(0xFF5C5FE0))
              .withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerHubRadius * 0.7));
    canvas.drawCircle(center, centerHubRadius * 0.65, innerGlow);

    // Tiny center dot (like a real dial)
    final centerDot = Paint()
      ..shader = RadialGradient(
        colors: [
          isDark ? const Color(0xFF8B8EFF) : const Color(0xFF5C5FE0),
          isDark ? const Color(0xFF4548A0) : const Color(0xFF3A3D80),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerHubRadius * 0.15));
    canvas.drawCircle(center, centerHubRadius * 0.12, centerDot);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return rotationAngle != oldDelegate.rotationAngle ||
        selectedNumber != oldDelegate.selectedNumber ||
        highlightedNumber != oldDelegate.highlightedNumber ||
        highlightScale != oldDelegate.highlightScale ||
        isDark != oldDelegate.isDark;
  }
}
