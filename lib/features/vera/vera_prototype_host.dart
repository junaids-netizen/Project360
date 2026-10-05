import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/features/embed/preview_app.dart';
import 'package:project360/features/pitch/preview_back.dart';
import 'package:project360/features/vera/full_vera_router.dart';

/// Embeds the tabbed bank or Vera app with the active Project360 brand palette.
class VeraCardPrototypeHost extends StatefulWidget {
  const VeraCardPrototypeHost({super.key});

  @override
  State<VeraCardPrototypeHost> createState() => _VeraCardPrototypeHostState();
}

class _VeraCardPrototypeHostState extends State<VeraCardPrototypeHost> {
  late final GoRouter _router = createFullVeraRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewBack(
      onBack: () => Navigator.of(context).pop(),
      child: buildPreviewApp(router: _router),
    );
  }
}
