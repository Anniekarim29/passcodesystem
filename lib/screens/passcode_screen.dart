import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/passcode_provider.dart';
import '../widgets/dot_indicator.dart';
import '../widgets/rotary_dial.dart';
import '../widgets/theme_toggle_button.dart';
import '../utils/app_theme.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with TickerProviderStateMixin {
  late AnimationController _successOverlayController;
  late Animation<double> _successOverlayAnimation;
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _successOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _successOverlayAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
    ]).animate(CurvedAnimation(
      parent: _successOverlayController,
      curve: Curves.easeInOut,
    ));

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _successOverlayController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasscodeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Listener for success state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.status == PasscodeStatus.success && !_successOverlayController.isAnimating && _successOverlayController.value == 0) {
        _successOverlayController.forward(from: 0);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated Premium Gradient Background ──────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MeshGradientPainter(
                    isDark: isDark,
                    animValue: _bgAnimController.value,
                  ),
                  size: size,
                );
              },
            ),
          ),

          // ── Floating orb glow 1 (top-right) ──────────────────
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, _) {
              final offset = sin(_bgAnimController.value * pi * 2) * 20;
              return Positioned(
                top: -size.width * 0.15 + offset,
                right: -size.width * 0.05,
                child: Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? AppTheme.darkGlow1 : AppTheme.lightGlow1)
                            .withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Floating orb glow 2 (bottom-left) ────────────────
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, _) {
              final offset = cos(_bgAnimController.value * pi * 2) * 25;
              return Positioned(
                bottom: -size.width * 0.2 + offset,
                left: -size.width * 0.15,
                child: Container(
                  width: size.width * 0.65,
                  height: size.width * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? AppTheme.darkGlow2 : AppTheme.lightGlow2)
                            .withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // subtle noise/grain overlay for premium feel
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (isDark ? Colors.black : Colors.white).withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ─ Top bar with theme toggle ────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      ThemeToggleButton(),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // ─ Title ─────────────────────────────────────
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? [const Color(0xFFE0E0FF), const Color(0xFF9BA2FF)]
                        : [const Color(0xFF2A2D4E), const Color(0xFF5C5FE0)],
                  ).createShader(bounds),
                  child: Text(
                    'Enter Passcode',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: (isDark ? const Color(0xFF8B8EFF) : const Color(0xFF5C5FE0))
                              .withValues(alpha: 0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                // ─ Subtitle ──────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getSubtitleText(provider.status),
                    key: ValueKey(provider.status),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getSubtitleColor(provider.status, isDark),
                          letterSpacing: 0.5,
                        ),
                  ),
                ),

                SizedBox(height: size.height * 0.035),

                // ─ Dot indicators ────────────────────────────
                const DotIndicator(),

                SizedBox(height: size.height * 0.06),

                // ─ Rotary dial ────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const RotaryDial(),
                  ),
                ),

                // ─ Bottom actions ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 30, top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Clear button
                      _buildActionButton(
                        context: context,
                        icon: Icons.backspace_rounded,
                        label: 'Delete',
                        onTap: () => provider.deleteLast(),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 40),
                      // Reset button
                      _buildActionButton(
                        context: context,
                        icon: Icons.refresh_rounded,
                        label: 'Clear',
                        onTap: () => provider.clear(),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Success overlay ──────────────────────────────────
          AnimatedBuilder(
            animation: _successOverlayAnimation,
            builder: (context, _) {
              if (_successOverlayAnimation.value <= 0) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: AppTheme.successGreen
                        .withValues(alpha: _successOverlayAnimation.value * 0.1),
                    child: Center(
                      child: Opacity(
                        opacity: _successOverlayAnimation.value,
                        child: Transform.scale(
                          scale: 0.7 + _successOverlayAnimation.value * 0.3,
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successGreen.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 100,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getSubtitleText(PasscodeStatus status) {
    switch (status) {
      case PasscodeStatus.success:
        return 'Unlocked successfully!';
      case PasscodeStatus.error:
        return 'Wrong passcode, try again';
      case PasscodeStatus.entering:
        return 'Rotate the dial to enter digits';
    }
  }

  Color _getSubtitleColor(PasscodeStatus status, bool isDark) {
    switch (status) {
      case PasscodeStatus.success:
        return AppTheme.successGreen;
      case PasscodeStatus.error:
        return AppTheme.errorRed;
      case PasscodeStatus.entering:
        return isDark
            ? const Color(0xFF8A8FA5)
            : const Color(0xFF7A7E92);
    }
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.6),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark
                  ? const Color(0xFF9BA0B5)
                  : const Color(0xFF5A5E72),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF9BA0B5)
                    : const Color(0xFF5A5E72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Mesh gradient background painter
// ═══════════════════════════════════════════════════════════════════
class _MeshGradientPainter extends CustomPainter {
  final bool isDark;
  final double animValue;

  _MeshGradientPainter({required this.isDark, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                AppTheme.darkGradient1,
                AppTheme.darkGradient2,
                AppTheme.darkGradient3,
                AppTheme.darkGradient1,
              ]
            : [
                AppTheme.lightGradient1,
                AppTheme.lightGradient2,
                AppTheme.lightGradient3,
                AppTheme.lightGradient1,
              ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Animated subtle radial glow in center
    final centerGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.0 + sin(animValue * pi * 2) * 0.2,
          0.1 + cos(animValue * pi * 2) * 0.15,
        ),
        radius: 0.8,
        colors: [
          (isDark ? const Color(0xFF2A1860) : const Color(0xFFC8C4F0))
              .withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), centerGlow);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter old) {
    return old.animValue != animValue || old.isDark != isDark;
  }
}
