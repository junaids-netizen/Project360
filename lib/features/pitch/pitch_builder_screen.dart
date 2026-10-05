import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/brand/brand_picker_sheet.dart';
import 'package:project360/features/pitch/pitch_modules.dart';

/// Sales step: pick the bank brand, toggle modules, then preview.
///
/// [onPreview] is injected so this screen does not depend on the Vera embed.
/// The index passes the real preview opener.
class PitchBuilderScreen extends StatefulWidget {
  const PitchBuilderScreen({super.key, required this.onPreview});

  final void Function(BuildContext context, List<PitchModule> modules)
  onPreview;

  @override
  State<PitchBuilderScreen> createState() => _PitchBuilderScreenState();
}

class _PitchBuilderScreenState extends State<PitchBuilderScreen> {
  final PitchSelection _selection = PitchSelection.initial();

  void _toggle(PitchModule module) {
    setState(() => _selection.toggle(module));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final brand = BrandScope.of(context).brand;

    return Material(
      color: colors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            VeraToolbar(
              title: 'Build an app',
              showBack: Navigator.of(context).canPop(),
              onBack: () => Navigator.of(context).pop(),
              onInfo: () => showBrandPicker(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(
                    'Choose what this bank gets. Home stays on; everything else is a module.',
                    style: context.type.p1.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _BrandRow(
                    name: brand.name,
                    seed: brand.seed,
                    onTap: Haptics.wrap(() => showBrandPicker(context)),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Modules',
                    style: TextStyle(
                      fontFamily: VeraTypography.geist,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1.2,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  VeraCapsule(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        for (final module in pitchModuleOrder) ...[
                          _ModuleRow(
                            module: module,
                            on: _selection.enabled(module),
                            onChanged: module == PitchModule.home
                                ? null
                                : (_) => _toggle(module),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.paddingOf(context).bottom + 16,
              ),
              child: VeraPrimaryButton(
                key: const Key('pitch-preview'),
                label: 'Preview app',
                width: double.infinity,
                height: 48,
                onTap: Haptics.wrap(
                  () => widget.onPreview(context, _selection.previewModules),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({
    required this.name,
    required this.seed,
    required this.onTap,
  });

  final String name;
  final Color seed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VeraSpacing.page,
            vertical: VeraSpacing.s12,
          ),
          child: Row(
            children: [
              Expanded(child: Text('Brand', style: context.type.h4)),
              Text(
                name,
                style: context.type.p1.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(width: VeraSpacing.s8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: seed,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 1.25),
                ),
              ),
              const SizedBox(width: VeraSpacing.s4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.module,
    required this.on,
    required this.onChanged,
  });

  final PitchModule module;
  final bool on;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          VeraSvg(_iconFor(module), size: 24, color: colors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.rowLabel, style: context.type.h4),
                Text(
                  module.rowDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.p2.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          KeyedSubtree(
            key: ValueKey('pitch-toggle-${module.name}'),
            child: VeraToggle(on: on, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

String _iconFor(PitchModule module) => switch (module) {
  PitchModule.home => VeraAssets.logo,
  PitchModule.rewards => VeraAssets.rewardsSparkle,
  PitchModule.card => VeraAssets.wallet,
  PitchModule.notifications => VeraAssets.bell,
  PitchModule.settings => VeraAssets.settings,
};
