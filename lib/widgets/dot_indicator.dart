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
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3, end: 0), weight: 1),
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

    // Trigger shake on error (after build)
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
            dotColor = Theme.of(context).colorScheme.primary;
          } else {
            dotColor = isDark 
                ? const Color(0xFF2D3139) 
                : const Color(0xFFE2E4EB);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: isFilled ? 20 : 14,
            height: isFilled ? 20 : 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? dotColor : Colors.transparent,
              border: Border.all(
                color: dotColor,
                width: isFilled ? 3 : 2,
              ),
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      if (isSuccess)
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.3),
                          blurRadius: 25,
                          spreadRadius: 5,
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
