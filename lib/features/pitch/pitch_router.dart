import 'package:go_router/go_router.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/pitch_router_bank.dart';
import 'package:project360/features/pitch/pitch_router_vera.dart';
import 'package:project360/generated/vera_vendored.dart';

/// Pitch or Vera preview router — real Vera when vendored, bank demo otherwise.
GoRouter createPitchRouter(List<PitchModule> modules) {
  if (kVeraVendored) return createPitchRouterVera(modules);
  return createPitchRouterBank(modules);
}
