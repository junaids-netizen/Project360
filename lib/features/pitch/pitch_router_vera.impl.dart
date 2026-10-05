import 'package:go_router/go_router.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/pitch_router_bank.dart';

/// Until [tool/vendor_vera_design.sh] runs, Vera routes use the bank demo.
GoRouter createPitchRouterVeraImpl(List<PitchModule> modules) =>
    createPitchRouterBank(modules);
