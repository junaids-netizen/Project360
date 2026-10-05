import 'package:go_router/go_router.dart';
import 'package:project360/features/pitch/pitch_modules.dart';

import 'pitch_router_vera.impl.dart';

/// Vera Design screens for the pitch shell. Implementation is swapped by
/// [tool/vendor_vera_design.sh].
GoRouter createPitchRouterVera(List<PitchModule> modules) =>
    createPitchRouterVeraImpl(modules);
