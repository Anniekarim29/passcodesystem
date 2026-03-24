import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/passcode_provider.dart';
import '../utils/app_theme.dart';

class DotIndicator extends StatefulWidget {
  const DotIndicator({super.key});

  @override
  State<DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 3.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasscodeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.status == PasscodeStatus.error && !_shakeController.isAnimating) {
        _shakeController.forward(from: 0);
      }
    });

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(provider.passcodeLength, (index) {
          final isFilled = index < provider.entered.length;
          final isSuccess = provider.status == PasscodeStatus.success;
          final isError = provider.status == PasscodeStatus.error;

          Color dotColor;
          if (isSuccess) {
            dotColor = AppTheme.successGreen;
          } else if (isError) {
            dotColor = AppTheme.errorRed;
          } else if (isFilled) {
            dotColor = isDark ? const Color(0xFF8B8EFF) : const Color(0xFF5C5FE0);
          } else {
            dotColor = isDark
                ? const Color(0xFF252840)
                : const Color(0xFFD0D2E8);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: isFilled ? 20 : 14,
            height: isFilled ? 20 : 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // 3D gradient fill when filled
              gradient: isFilled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSuccess
                          ? [
                              AppTheme.successGreen.withValues(alpha: 0.9),
                              const Color(0xFF00A060),
                            ]
                          : isError
                              ? [
                                  AppTheme.errorRed.withValues(alpha: 0.9),
                                  const Color(0xFFCC2020),
                                ]
                              : [
                                  dotColor.withValues(alpha: 0.95),
                                  dotColor.withValues(alpha: 0.7),
                                ],
                    )
                  : null,
              color: isFilled ? null : dotColor.withValues(alpha: 0.3),
              border: Border.all(
                color: isFilled
                    ? dotColor.withValues(alpha: 0.6)
                    : dotColor.withValues(alpha: 0.5),
                width: isFilled ? 0 : 1.5,
              ),
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.45),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                      if (isSuccess)
                        BoxShadow(
                          color: AppTheme.successGreen.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
