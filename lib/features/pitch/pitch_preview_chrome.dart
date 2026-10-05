import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/pitch/preview_back.dart';

/// Back control over pitch preview shells (glass tab, bank, Vera).
class PitchPreviewChrome extends StatelessWidget {
  const PitchPreviewChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final back = PreviewBack.maybeOf(context);
    if (back == null) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              key: const Key('preview-back'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Haptics.light();
                back.onBack();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VeraSvg(VeraAssets.back, size: 24),
                    const SizedBox(width: 8),
                    Text('Back', style: context.type.h4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
