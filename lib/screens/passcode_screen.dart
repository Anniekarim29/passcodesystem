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
    with SingleTickerProviderStateMixin {
  late AnimationController _successOverlayController;
  late Animation<double> _successOverlayAnimation;

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
  }

  @override
  void dispose() {
    _successOverlayController.dispose();
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
          // ── Premium Gradient Background ─────────────────────
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F1115),
                          const Color(0xFF1A1C22),
                          const Color(0xFF121418),
                        ]
                      : [
                          const Color(0xFFF0F2F8),
                          const Color(0xFFE6E9F0),
                          const Color(0xFFF8F9FF),
                        ],
                ),
              ),
            ),
          ),
          
          // Subtle accent glows
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF333750) : const Color(0xFFD0D6E8))
                        .withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
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
                Text(
                  'Enter Passcode',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
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
                          letterSpacing: 0.2,
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
            ? const Color(0xFF8E8E93)
            : const Color(0xFF8E8E93);
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark
                  ? const Color(0xFF8E8E93)
                  : const Color(0xFF636366),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF636366),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
