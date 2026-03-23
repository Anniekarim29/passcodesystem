import 'package:flutter_test/flutter_test.dart';
import 'package:passcode_system/providers/passcode_provider.dart';

void main() {
  group('PasscodeProvider', () {
    late PasscodeProvider provider;

    setUp(() {
      provider = PasscodeProvider();
    });

    test('starts with empty entered list', () {
      expect(provider.entered, isEmpty);
      expect(provider.status, PasscodeStatus.entering);
    });

    test('adds digit correctly', () {
      provider.addDigit(1);
      expect(provider.entered, [1]);
    });

    test('detects correct passcode (1234)', () {
      provider.addDigit(1);
      provider.addDigit(2);
      provider.addDigit(3);
      provider.addDigit(4);
      expect(provider.status, PasscodeStatus.success);
    });

    test('detects wrong passcode', () {
      provider.addDigit(9);
      provider.addDigit(9);
      provider.addDigit(9);
      provider.addDigit(9);
      expect(provider.status, PasscodeStatus.error);
    });

    test('clear resets state', () {
      provider.addDigit(5);
      provider.clear();
      expect(provider.entered, isEmpty);
      expect(provider.status, PasscodeStatus.entering);
    });
  });
}
