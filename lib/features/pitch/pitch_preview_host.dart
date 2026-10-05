import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/features/bank/bank_preview_app.dart';
import 'package:project360/features/pitch/configured_vera_router.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/preview_back.dart';

/// Opens the configured preview on top of the builder.
void openPitchPreview(BuildContext context, List<PitchModule> modules) {
  Navigator.of(context).push(
    CupertinoPageRoute<void>(
      builder: (_) => PitchPreviewHost(modules: modules),
    ),
  );
}

/// Embedded bank app whose tabs match [modules], in the active brand.
class PitchPreviewHost extends StatefulWidget {
  const PitchPreviewHost({super.key, required this.modules});

  final List<PitchModule> modules;

  @override
  State<PitchPreviewHost> createState() => _PitchPreviewHostState();
}

class _PitchPreviewHostState extends State<PitchPreviewHost> {
  late final GoRouter _router = createPitchRouter(widget.modules);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewBack(
      onBack: () => Navigator.of(context).pop(),
      child: BankPreviewApp(router: _router),
    );
  }
}
