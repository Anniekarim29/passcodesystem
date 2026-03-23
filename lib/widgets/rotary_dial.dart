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

  // The finger-stop position (like on a real rotary dial)
  static const double _fingerStopAngle = pi * 0.75; // ~135 degrees from start
  
  // Number arrangement: 1-9 then 0, clockwise from top-right
  // Like a real rotary phone
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
    if (rotationAngle < pi / 12) return null; // Dead zone at start

    // Each number is roughly 25-30 degrees apart on the dial
    // We map the rotation amount to which hole was pulled to the stop
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

    // Handle wrapping around -pi/pi boundary
    if (delta > pi) delta -= 2 * pi;
    if (delta < -pi) delta += 2 * pi;

    // Only allow clockwise rotation (negative angle in standard math)
    // but we'll treat clockwise drag as negative for our system
    setState(() {
      _currentAngle += delta;
      // Clamp: only allow rotation in one direction (clockwise = positive here)
      if (_currentAngle < 0) _currentAngle = 0;
      // Max rotation ~ 330 degrees
      if (_currentAngle > 2 * pi * 0.92) _currentAngle = 2 * pi * 0.92;


      _startAngle = currentTouchAngle;

      // Determine highlighted number based on current rotation
      _highlightedNumber = _getNumberAtAngle(_currentAngle);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Determine which number was dialled
    final number = _getNumberAtAngle(_currentAngle);

    if (number != null) {
      _selectedNumber = number;
      _highlightController.forward(from: 0);

      // Add digit to passcode
      final provider = Provider.of<PasscodeProvider>(context, listen: false);
      provider.addDigit(number);
    }

    _highlightedNumber = null;

    // Animate return to zero (like a real rotary dial spring-back)
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
// CustomPainter for the entire dial
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

    // ── Outer ring shadow ──────────────────────────────────────
    final shadowPaint = Paint()
      ..color = (isDark ? Colors.black : Colors.black).withValues(alpha: isDark ? 0.4 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center + const Offset(3, 3), outerRadius - 2, shadowPaint);

    // Light shadow for neumorphic
    final lightShadowPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.05 : 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center + const Offset(-2, -2), outerRadius - 2, lightShadowPaint);

    // ── Outer ring fill ────────────────────────────────────────
    final outerPaint = Paint()
      ..color = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8ED)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outerPaint);

    // ── Outer ring border ──────────────────────────────────────
    final borderPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, outerRadius - 1, borderPaint);

    // ── Inner track (where numbers sit) ────────────────────────
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, numberRadius, trackPaint);

    // ── Finger stop indicator ──────────────────────────────────
    final stopAngle = -pi / 2 - pi / 10;
    final stopPos = Offset(
      center.dx + (outerRadius * 0.88) * cos(stopAngle),
      center.dy + (outerRadius * 0.88) * sin(stopAngle),
    );
    final stopPaint = Paint()
      ..color = isDark ? const Color(0xFF636366) : const Color(0xFFAEAEB2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(stopPos, numberCircleRadius * 0.4, stopPaint);

    // ── Number circles ─────────────────────────────────────────
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

      // Number circle shadow
      final numShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.3 : 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(numPos + const Offset(1, 2), effectiveRadius, numShadowPaint);

      // Number circle fill
      Color circleFillColor;
      if (isHighlighted) {
        circleFillColor = isDark ? const Color(0xFF48484A) : const Color(0xFF3A3A3C);
      } else {
        circleFillColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFF2C2C2E);
      }
      final numCirclePaint = Paint()
        ..color = circleFillColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(numPos, effectiveRadius, numCirclePaint);

      // Number circle border
      final numBorderPaint = Paint()
        ..color = isHighlighted
            ? (isDark ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.5))
            : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(numPos, effectiveRadius, numBorderPaint);

      // Number text
      final textPainter = TextPainter(
        text: TextSpan(
          text: number.toString(),
          style: TextStyle(
            color: isHighlighted
                ? Colors.white
                : (isDark ? const Color(0xFFD1D1D6) : const Color(0xFFE5E5EA)),
            fontSize: effectiveRadius * 0.95,
            fontWeight: FontWeight.w600,
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

    // ── Center hub ─────────────────────────────────────────────
    // Hub shadow
    final hubShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.5 : 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center + const Offset(2, 2), centerHubRadius, hubShadowPaint);

    // Hub fill
    final hubPaint = Paint()
      ..color = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerHubRadius, hubPaint);

    // Hub border
    final hubBorderPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, centerHubRadius, hubBorderPaint);

    // Hub inner detail circle
    final hubInnerPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, centerHubRadius * 0.6, hubInnerPaint);
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
