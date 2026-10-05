import 'package:flutter/material.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';

/// Atomic design levels used in Project360's shared widget layer.
enum DesignSystemLevel {
  tokens('Tokens', 'Colour, type, spacing, and radii from BrandColors'),
  atoms('Atoms', 'Single-purpose controls and glyphs'),
  molecules('Molecules', 'Composable UI built from atoms'),
  organisms('Organisms', 'Multi-part blocks with layout'),
  audit('Audit', 'Known hardcoded colours and follow-ups');

  const DesignSystemLevel(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class DesignSystemEntry {
  const DesignSystemEntry({
    required this.level,
    required this.name,
    required this.description,
    required this.preview,
    this.sourcePath,
  });

  final DesignSystemLevel level;
  final String name;
  final String description;
  final WidgetBuilder preview;
  final String? sourcePath;
}

/// Live previews for the design system browser (Project360 lib only).
List<DesignSystemEntry> buildDesignSystemCatalog() {
  return [
    const DesignSystemEntry(
      level: DesignSystemLevel.tokens,
      name: 'Spacing',
      description: 'VeraSpacing page grid (brand-independent today).',
      sourcePath: 'lib/app/theme/vera_metrics.dart',
      preview: _spacingPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.tokens,
      name: 'Radii',
      description: 'VeraRadii.card and pill corners.',
      sourcePath: 'lib/app/theme/vera_metrics.dart',
      preview: _radiiPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.atoms,
      name: 'VeraSvg',
      description: 'Vector icons tinted via BrandColors.',
      sourcePath: 'lib/core/widgets/vera_assets.dart',
      preview: _svgPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.atoms,
      name: 'VeraToggle',
      description: 'Switch using navActive / border.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _togglePreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.atoms,
      name: 'VeraProfileAvatar',
      description: 'Header avatar with initials.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _avatarPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.molecules,
      name: 'VeraPrimaryButton',
      description: 'Gradient CTA from buttonGradient.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _primaryButtonPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.molecules,
      name: 'VeraListRow',
      description: 'Icon + label + chevron row.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _listRowPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.molecules,
      name: 'VeraDentonAmount',
      description: 'Currency display with darkGradient shader.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _amountPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.molecules,
      name: 'VeraSectionTitle',
      description: 'Section header with optional suffix.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _sectionTitlePreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.molecules,
      name: 'VeraCapsule',
      description: 'Elevated surface card wrapper.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _capsulePreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.molecules,
      name: 'VeraToolbar',
      description: 'Screen header with back + info.',
      sourcePath: 'lib/core/widgets/vera_primitives.dart',
      preview: _toolbarPreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.organisms,
      name: 'VeraCardFace',
      description: 'Physical card with freeze + reveal.',
      sourcePath: 'lib/core/widgets/vera_card.dart',
      preview: _cardFacePreview,
    ),
    const DesignSystemEntry(
      level: DesignSystemLevel.organisms,
      name: 'VeraBalanceBar',
      description: 'Balance / available credit summary bar.',
      sourcePath: 'lib/core/widgets/vera_card.dart',
      preview: _balanceBarPreview,
    ),
  ];
}

Widget _spacingPreview(BuildContext context) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final step in [
        ('s8', VeraSpacing.s8),
        ('s12', VeraSpacing.s12),
        ('s16', VeraSpacing.s16),
        ('s20', VeraSpacing.s20),
        ('page', VeraSpacing.page),
      ])
        Column(
          children: [
            Container(
              width: step.$2,
              height: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(step.$1, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
    ],
  );
}

Widget _radiiPreview(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(VeraRadii.card),
          ),
          alignment: Alignment.center,
          child: const Text('card (4)'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(VeraRadii.pill),
          ),
          alignment: Alignment.center,
          child: const Text('pill'),
        ),
      ),
    ],
  );
}

Widget _svgPreview(BuildContext context) {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      VeraSvg(VeraAssets.wallet, size: 28),
      VeraSvg(VeraAssets.chevron, size: 28),
      VeraSvg(VeraAssets.info, size: 28),
    ],
  );
}

Widget _togglePreview(BuildContext context) {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      VeraToggle(on: true),
      SizedBox(width: 16),
      VeraToggle(on: false),
    ],
  );
}

Widget _avatarPreview(BuildContext context) {
  return const Center(child: VeraProfileAvatar());
}

Widget _primaryButtonPreview(BuildContext context) {
  return Center(
    child: VeraPrimaryButton(label: 'Pay now', onTap: () {}),
  );
}

Widget _listRowPreview(BuildContext context) {
  return VeraListRow(
    icon: VeraAssets.wallet,
    label: 'List row',
    onTap: () {},
  );
}

Widget _amountPreview(BuildContext context) {
  return const Center(
    child: VeraDentonAmount(dollars: '4,500', cents: '.88'),
  );
}

Widget _sectionTitlePreview(BuildContext context) {
  return VeraSectionTitle(
    title: 'Section title',
    titleSuffix: 'by Jul 15',
    showChevron: true,
    onTap: () {},
  );
}

Widget _capsulePreview(BuildContext context) {
  return const VeraCapsule(
    padding: EdgeInsets.all(16),
    child: Text('Capsule surface'),
  );
}

Widget _toolbarPreview(BuildContext context) {
  return const VeraToolbar(title: 'Toolbar', showBack: false);
}

Widget _cardFacePreview(BuildContext context) {
  return const VeraCardFace(showCvv: true);
}

Widget _balanceBarPreview(BuildContext context) {
  return const VeraBalanceBar();
}
