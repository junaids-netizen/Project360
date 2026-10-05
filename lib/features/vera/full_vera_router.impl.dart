import 'package:go_router/go_router.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/pitch_router.dart';

GoRouter createFullVeraRouterImpl() => createPitchRouter(const [
  PitchModule.home,
  PitchModule.rewards,
  PitchModule.card,
  PitchModule.settings,
]);
