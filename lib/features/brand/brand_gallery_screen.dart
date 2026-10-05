import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/brand/brand_picker_sheet.dart';
import 'package:project360/features/design_system/brand_token_panel.dart';

/// Every token and every primitive on one page.
///
/// The point is detection: switch brand, open this, and anything still wearing
/// Vera's colours is obvious immediately. Worth opening after touching any
/// screen, because a hardcoded colour looks perfectly fine until the day
/// someone's brand is on screen.
class BrandGalleryScreen extends StatelessWidget {
  const BrandGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = BrandScope.of(context).brand;

    return Material(
      color: context.brand.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            VeraToolbar(
              title: 'Brand: ${brand.name}',
              showBack: Navigator.of(context).canPop(),
              onBack: () => Navigator.of(context).pop(),
              onInfo: () => showBrandPicker(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                children: [
                  const BrandTokenHeading('Brand'),
                  _swatchCapsule(const {
                    'accent': BrandColorToken.accent,
                    'accentSecondary': BrandColorToken.accentSecondary,
                    'cardSurface': BrandColorToken.cardSurface,
                    'navActive': BrandColorToken.navActive,
                    'sliderThumb': BrandColorToken.sliderThumb,
                    'frostTint': BrandColorToken.frostTint,
                    'letterbox': BrandColorToken.letterbox,
                  }),
                  const BrandTokenHeading('Ink'),
                  _swatchCapsule(const {
                    'textPrimary': BrandColorToken.textPrimary,
                    'textSecondary': BrandColorToken.textSecondary,
                    'textTertiary': BrandColorToken.textTertiary,
                    'headerPrimary': BrandColorToken.headerPrimary,
                    'toastInk': BrandColorToken.toastInk,
                    'sliderValueInk': BrandColorToken.sliderValueInk,
                  }),
                  const BrandTokenHeading('Surfaces'),
                  _swatchCapsule(const {
                    'white': BrandColorToken.white,
                    'background': BrandColorToken.background,
                    'border': BrandColorToken.border,
                    'surfaceMuted': BrandColorToken.surfaceMuted,
                    'borderMuted': BrandColorToken.borderMuted,
                    'navSurface': BrandColorToken.navSurface,
                    'navSelection': BrandColorToken.navSelection,
                  }),
                  const BrandTokenHeading('Status'),
                  _swatchCapsule(const {
                    'badge': BrandColorToken.badge,
                    'success': BrandColorToken.success,
                    'warning': BrandColorToken.warning,
                    'danger': BrandColorToken.danger,
                  }),
                  const BrandTokenHeading('Gradients'),
                  const BrandGradientRampRow(
                    label: 'darkGradient',
                    token: BrandGradientToken.dark,
                  ),
                  const BrandGradientRampRow(
                    label: 'buttonGradient',
                    token: BrandGradientToken.button,
                  ),
                  const BrandGradientRampRow(
                    label: 'progressGradient',
                    token: BrandGradientToken.progress,
                  ),
                  const BrandGradientRampRow(
                    label: 'pointsGlow',
                    token: BrandGradientToken.pointsGlow,
                  ),
                  const BrandGradientRampRow(
                    label: 'programGlow',
                    token: BrandGradientToken.programGlow,
                  ),
                  const BrandGradientRampRow(
                    label: 'wordmarkGradient',
                    token: BrandGradientToken.wordmark,
                  ),
                  const BrandTokenHeading('Type'),
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
                  const BrandTokenHeading('Primitives'),
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

Widget _swatchCapsule(Map<String, BrandColorToken> entries) {
  return VeraCapsule(
    padding: const EdgeInsets.all(12),
    child: BrandColorSwatchGrid(entries: entries),
  );
}
