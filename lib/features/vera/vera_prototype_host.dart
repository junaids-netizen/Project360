import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/features/bank/bank_preview_app.dart';
import 'package:project360/features/pitch/configured_vera_router.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/preview_back.dart';

/// Home, rewards, card, and account — the full tabbed bank, in this repo.
const List<PitchModule> veraAppModules = [
  PitchModule.home,
  PitchModule.rewards,
  PitchModule.card,
  PitchModule.settings,
];

/// Embeds the tabbed bank app with the active Project360 brand palette.
class VeraCardPrototypeHost extends StatefulWidget {
  const VeraCardPrototypeHost({super.key});

  @override
  State<VeraCardPrototypeHost> createState() => _VeraCardPrototypeHostState();
}

class _VeraCardPrototypeHostState extends State<VeraCardPrototypeHost> {
  late final GoRouter _router = createPitchRouter(veraAppModules);

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
