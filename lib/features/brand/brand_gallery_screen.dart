import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_colors.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/brand/brand_picker_sheet.dart';

/// Every token and every primitive on one page.
///
/// The point is detection: switch brand, open this, and anything still wearing
/// Vera's colours is obvious immediately. Worth opening after touching any
/// screen, because a hardcoded colour looks perfectly fine until the day
/// someone else's brand is on screen.
class BrandGalleryScreen extends StatelessWidget {
  const BrandGalleryScreen({super.key});

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
              title: 'Brand: ${brand.name}',
              showBack: false,
              onInfo: () => showBrandPicker(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                children: [
                  const _Heading('Brand'),
                  _Swatches(const {
                    'accent': _Ref.accent,
                    'accentSecondary': _Ref.accentSecondary,
                    'cardSurface': _Ref.cardSurface,
                    'navActive': _Ref.navActive,
                    'sliderThumb': _Ref.sliderThumb,
                    'frostTint': _Ref.frostTint,
                    'letterbox': _Ref.letterbox,
                  }),
                  const _Heading('Ink'),
                  _Swatches(const {
                    'textPrimary': _Ref.textPrimary,
                    'textSecondary': _Ref.textSecondary,
                    'textTertiary': _Ref.textTertiary,
                    'headerPrimary': _Ref.headerPrimary,
                    'toastInk': _Ref.toastInk,
                    'sliderValueInk': _Ref.sliderValueInk,
                  }),
                  const _Heading('Surfaces'),
                  _Swatches(const {
                    'white': _Ref.white,
                    'background': _Ref.background,
                    'border': _Ref.border,
                    'surfaceMuted': _Ref.surfaceMuted,
                    'borderMuted': _Ref.borderMuted,
                    'navSurface': _Ref.navSurface,
                    'navSelection': _Ref.navSelection,
                  }),
                  const _Heading('Status'),
                  _Swatches(const {
                    'badge': _Ref.badge,
                    'success': _Ref.success,
                    'warning': _Ref.warning,
                    'danger': _Ref.danger,
                  }),
                  const _Heading('Gradients'),
                  const _Ramp('darkGradient', _RampRef.dark),
                  const _Ramp('buttonGradient', _RampRef.button),
                  const _Ramp('progressGradient', _RampRef.progress),
                  const _Ramp('pointsGlow', _RampRef.pointsGlow),
                  const _Ramp('programGlow', _RampRef.programGlow),
                  const _Ramp('wordmarkGradient', _RampRef.wordmark),
                  const _Heading('Type'),
                  VeraCapsule(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Heading 1', style: context.type.h1),
                        Text('Heading 2', style: context.type.h2),
                        Text('Heading 3', style: context.type.h3),
                        Text('Heading 4', style: context.type.h4),
                        Text('Paragraph 1', style: context.type.p1),
                        Text('Paragraph 2', style: context.type.p2),
                        Text('TAB LABEL', style: context.type.tab),
                      ],
                    ),
                  ),
                  const _Heading('Primitives'),
                  const VeraCardFace(showCvv: true),
                  const SizedBox(height: 12),
                  const VeraBalanceBar(),
                  const SizedBox(height: 12),
                  VeraCapsule(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const VeraProfileAvatar(),
                            const SizedBox(width: 16),
                            VeraPrimaryButton(label: 'Pay now', onTap: () {}),
                            const Spacer(),
                            const VeraToggle(on: true),
                            const SizedBox(width: 8),
                            const VeraToggle(on: false),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const VeraDentonAmount(dollars: '4,500', cents: '.88'),
                        VeraSectionTitle(
                          title: 'Section title',
                          titleSuffix: 'by Jul 15',
                          showChevron: true,
                          onTap: () {},
                        ),
                        VeraListRow(
                          icon: VeraAssets.wallet,
                          label: 'List row',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Names of the flat colour tokens, so the gallery lists them without every
/// entry needing a closure.
enum _Ref {
  accent,
  accentSecondary,
  cardSurface,
  navActive,
  sliderThumb,
  frostTint,
  letterbox,
  textPrimary,
  textSecondary,
  textTertiary,
  headerPrimary,
  toastInk,
  sliderValueInk,
  white,
  background,
  border,
  surfaceMuted,
  borderMuted,
  navSurface,
  navSelection,
  badge,
  success,
  warning,
  danger;

  Color resolve(BrandColors c) => switch (this) {
    _Ref.accent => c.accent,
    _Ref.accentSecondary => c.accentSecondary,
    _Ref.cardSurface => c.cardSurface,
    _Ref.navActive => c.navActive,
    _Ref.sliderThumb => c.sliderThumb,
    _Ref.frostTint => c.frostTint,
    _Ref.letterbox => c.letterbox,
    _Ref.textPrimary => c.textPrimary,
    _Ref.textSecondary => c.textSecondary,
    _Ref.textTertiary => c.textTertiary,
    _Ref.headerPrimary => c.headerPrimary,
    _Ref.toastInk => c.toastInk,
    _Ref.sliderValueInk => c.sliderValueInk,
    _Ref.white => c.white,
    _Ref.background => c.background,
    _Ref.border => c.border,
    _Ref.surfaceMuted => c.surfaceMuted,
    _Ref.borderMuted => c.borderMuted,
    _Ref.navSurface => c.navSurface,
    _Ref.navSelection => c.navSelection,
    _Ref.badge => c.badge,
    _Ref.success => c.success,
    _Ref.warning => c.warning,
    _Ref.danger => c.danger,
  };
}

enum _RampRef {
  dark,
  button,
  progress,
  pointsGlow,
  programGlow,
  wordmark;

  List<Color> resolve(BrandColors c) => switch (this) {
    _RampRef.dark => c.darkGradient,
    _RampRef.button => c.buttonGradient,
    _RampRef.progress => c.progressGradient,
    _RampRef.pointsGlow => c.pointsGlow,
    _RampRef.programGlow => c.programGlow,
    _RampRef.wordmark => c.wordmarkGradient,
  };
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: VeraSpacing.s24,
        bottom: VeraSpacing.s8,
      ),
      child: Text(label, style: context.type.h3),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches(this.entries);

  final Map<String, _Ref> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return VeraCapsule(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final entry in entries.entries)
            SizedBox(
              width: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: entry.value.resolve(colors),
                      borderRadius: BorderRadius.circular(VeraRadii.card),
                      border: Border.all(color: colors.border),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key,
                    style: context.type.p2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Ramp extends StatelessWidget {
  const _Ramp(this.label, this.ref);

  final String label;
  final _RampRef ref;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: context.type.p2),
          ),
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: ref.resolve(colors)),
                borderRadius: BorderRadius.circular(VeraRadii.card),
                border: Border.all(color: colors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
