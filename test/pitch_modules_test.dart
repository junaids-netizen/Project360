import 'package:flutter_test/flutter_test.dart';
import 'package:project360/features/pitch/pitch_modules.dart';

void main() {
  test('home stays first and cannot be turned off', () {
    final selection = PitchSelection.initial();
    expect(selection.previewModules.first, PitchModule.home);
    expect(selection.previewModules, pitchModuleOrder);

    selection.toggle(PitchModule.home);
    expect(selection.enabled(PitchModule.home), isTrue);

    selection.toggle(PitchModule.rewards);
    selection.toggle(PitchModule.notifications);
    expect(selection.previewModules, [
      PitchModule.home,
      PitchModule.card,
      PitchModule.settings,
    ]);
  });

  test('card-only preview blocks rewards, settings, and notifications', () {
    final enabled = {PitchModule.home, PitchModule.card};

    expect(pitchAllowsPath(enabled, '/home'), isTrue);
    expect(pitchAllowsPath(enabled, '/card'), isTrue);
    expect(pitchAllowsPath(enabled, '/card/wallets'), isTrue);
    expect(pitchAllowsPath(enabled, '/card/replace'), isTrue);
    expect(pitchAllowsPath(enabled, '/pay'), isTrue);

    expect(pitchAllowsPath(enabled, '/rewards'), isFalse);
    expect(pitchAllowsPath(enabled, '/account'), isFalse);
    expect(pitchAllowsPath(enabled, '/settings/profile'), isFalse);
    expect(pitchAllowsPath(enabled, '/inbox'), isFalse);
    expect(pitchAllowsPath(enabled, '/notifications'), isFalse);
    expect(pitchAllowsPath(enabled, '/3-tabs/home'), isFalse);

    expect(hiddenHomeShortcutLabels(enabled), {
      'Rewards',
      'Account',
      'Inbox',
      'Notifications',
    });
  });

  test('full module set allows every pitch route', () {
    final enabled = pitchModuleOrder.toSet();
    for (final path in [
      '/home',
      '/rewards',
      '/card',
      '/card/cvc',
      '/notifications',
      '/inbox',
      '/account',
      '/settings/security',
      '/pay',
    ]) {
      expect(pitchAllowsPath(enabled, path), isTrue, reason: path);
    }
    expect(hiddenHomeShortcutLabels(enabled), isEmpty);
  });
}
