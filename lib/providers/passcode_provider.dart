import 'package:flutter/material.dart';

enum PasscodeStatus { entering, success, error }

class PasscodeProvider extends ChangeNotifier {
  static const int _passcodeLength = 4;
  static const List<int> _correctPasscode = [1, 2, 3, 4];

  final List<int> _entered = [];
  PasscodeStatus _status = PasscodeStatus.entering;

  // ─── Getters ──────────────────────────────────────────────────
  List<int> get entered => List.unmodifiable(_entered);
  int get passcodeLength => _passcodeLength;
  PasscodeStatus get status => _status;
  bool get isComplete => _entered.length >= _passcodeLength;

  // ─── Actions ──────────────────────────────────────────────────
  void addDigit(int digit) {
    if (_status != PasscodeStatus.entering) return;
    if (_entered.length >= _passcodeLength) return;

    _entered.add(digit);
    notifyListeners();

    if (isComplete) {
      _evaluate();
    }
  }

  void clear() {
    _entered.clear();
    _status = PasscodeStatus.entering;
    notifyListeners();
  }

  void deleteLast() {
    if (_entered.isEmpty) return;
    _entered.removeLast();
    _status = PasscodeStatus.entering;
    notifyListeners();
  }

  // ─── Internal ─────────────────────────────────────────────────
  void _evaluate() {
    bool correct = true;
    for (int i = 0; i < _passcodeLength; i++) {
      if (_entered[i] != _correctPasscode[i]) {
        correct = false;
        break;
      }
    }

    _status = correct ? PasscodeStatus.success : PasscodeStatus.error;
    notifyListeners();

    // Auto-reset after feedback
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (_status != PasscodeStatus.entering) {
        clear();
      }
    });
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
