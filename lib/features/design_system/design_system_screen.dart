import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/brand/brand_picker_sheet.dart';
import 'package:project360/features/design_system/brand_token_panel.dart';
import 'package:project360/features/design_system/color_audit_entries.dart';
import 'package:project360/features/design_system/design_system_catalog.dart';

/// Browsable component library under the active Project360 brand.
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final brand = BrandScope.of(context).brand;
    final catalog = buildDesignSystemCatalog();

    return Material(
      color: colors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            VeraToolbar(
              title: 'Design system',
              showBack: Navigator.of(context).canPop(),
              onBack: () => Navigator.of(context).pop(),
              onInfo: () => showBrandPicker(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${brand.name} · switch brand from ⓘ to validate tokens',
                  style: context.type.p2.copyWith(color: colors.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                children: [
                  for (final level in DesignSystemLevel.values) ...[
                    _LevelHeader(level: level),
                    if (level == DesignSystemLevel.tokens) ...[
                      const _TokenPanels(),
                    ] else if (level == DesignSystemLevel.audit) ...[
                      const _AuditPanel(),
                    ] else ...[
                      for (final entry in catalog.where(
                        (e) => e.level == level,
                      ))
                        _ComponentTile(entry: entry),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.level});

  final DesignSystemLevel level;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: VeraSpacing.s24, bottom: VeraSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(level.title, style: context.type.h2),
          Text(
            level.subtitle,
            style: context.type.p2.copyWith(color: context.brand.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TokenPanels extends StatelessWidget {
  const _TokenPanels();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandTokenHeading('Brand colours'),
        VeraCapsule(
          padding: const EdgeInsets.all(12),
          child: BrandColorSwatchGrid(
            entries: const {
              'accent': BrandColorToken.accent,
              'accentSecondary': BrandColorToken.accentSecondary,
              'cardSurface': BrandColorToken.cardSurface,
              'navActive': BrandColorToken.navActive,
              'textPrimary': BrandColorToken.textPrimary,
              'textSecondary': BrandColorToken.textSecondary,
              'background': BrandColorToken.background,
              'border': BrandColorToken.border,
            },
          ),
        ),
        const BrandTokenHeading('Ink & surfaces'),
        VeraCapsule(
          padding: const EdgeInsets.all(12),
          child: BrandColorSwatchGrid(
            entries: const {
              'textTertiary': BrandColorToken.textTertiary,
              'headerPrimary': BrandColorToken.headerPrimary,
              'white': BrandColorToken.white,
              'surfaceMuted': BrandColorToken.surfaceMuted,
              'navSurface': BrandColorToken.navSurface,
              'navSelection': BrandColorToken.navSelection,
            },
          ),
        ),
        const BrandTokenHeading('Status'),
        VeraCapsule(
          padding: const EdgeInsets.all(12),
          child: BrandColorSwatchGrid(
            entries: const {
              'badge': BrandColorToken.badge,
              'success': BrandColorToken.success,
              'warning': BrandColorToken.warning,
              'danger': BrandColorToken.danger,
            },
          ),
        ),
        const BrandTokenHeading('Gradients'),
        const VeraCapsule(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              BrandGradientRampRow(
                label: 'darkGradient',
                token: BrandGradientToken.dark,
              ),
              BrandGradientRampRow(
                label: 'buttonGradient',
                token: BrandGradientToken.button,
              ),
              BrandGradientRampRow(
                label: 'progressGradient',
                token: BrandGradientToken.progress,
              ),
              BrandGradientRampRow(
                label: 'pointsGlow',
                token: BrandGradientToken.pointsGlow,
              ),
            ],
          ),
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
        for (final entry
            in buildDesignSystemCatalog().where(
              (e) => e.level == DesignSystemLevel.tokens && e.name != 'Type',
            ))
          _ComponentTile(entry: entry),
      ],
    );
  }
}

class _ComponentTile extends StatelessWidget {
  const _ComponentTile({required this.entry});

  final DesignSystemEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: VeraCapsule(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.name, style: context.type.h4),
            const SizedBox(height: 4),
            Text(
              entry.description,
              style: context.type.p2.copyWith(color: colors.textSecondary),
            ),
            if (entry.sourcePath != null) ...[
              const SizedBox(height: 4),
              Text(
                entry.sourcePath!,
                style: context.type.p2.copyWith(
                  color: colors.textTertiary,
                  fontFamily: 'Geist Mono',
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 12),
            entry.preview(context),
          ],
        ),
      ),
    );
  }
}

class _AuditPanel extends StatelessWidget {
  const _AuditPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Column(
      children: [
        for (final row in project360ColorAudit)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: VeraCapsule(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.widgetOrArea,
                          style: context.type.h4,
                        ),
                      ),
                      _PriorityChip(priority: row.priority, fixed: row.fixed),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    row.location,
                    style: context.type.p2.copyWith(
                      color: colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(row.issue, style: context.type.p2),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority, required this.fixed});

  final AuditFixPriority priority;
  final bool fixed;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final label = fixed
        ? 'Fixed'
        : switch (priority) {
            AuditFixPriority.high => 'High',
            AuditFixPriority.medium => 'Medium',
            AuditFixPriority.low => 'Low',
            AuditFixPriority.notApplicable => 'Info',
          };
    final bg = fixed
        ? colors.success.withValues(alpha: 0.12)
        : switch (priority) {
            AuditFixPriority.high => colors.danger.withValues(alpha: 0.12),
            AuditFixPriority.medium => colors.warning.withValues(alpha: 0.12),
            AuditFixPriority.low => colors.border,
            AuditFixPriority.notApplicable => colors.surfaceMuted,
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(VeraRadii.card),
      ),
      child: Text(label, style: context.type.p2.copyWith(fontSize: 11)),
    );
  }
}
