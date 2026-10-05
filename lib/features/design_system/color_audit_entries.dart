/// Structured colour-token audit for Project360 + embedded Vera surfaces.
enum AuditFixPriority { high, medium, low, notApplicable }

class ColorAuditEntry {
  const ColorAuditEntry({
    required this.location,
    required this.widgetOrArea,
    required this.issue,
    required this.priority,
    this.fixed = false,
  });

  final String location;
  final String widgetOrArea;
  final String issue;
  final AuditFixPriority priority;
  final bool fixed;
}

/// Snapshot used by the in-app Design system → Audit section.
const List<ColorAuditEntry> project360ColorAudit = [
  ColorAuditEntry(
    location: 'lib/features/index/index_screen.dart',
    widgetOrArea: 'IndexScreen, _IndexCard, _IndexHeader',
    issue:
        'Launcher chrome used fixed greys/blacks (0xFFF2F2F2, Colors.black) '
        'instead of BrandColors.',
    priority: AuditFixPriority.high,
    fixed: true,
  ),
  ColorAuditEntry(
    location: 'lib/app/theme/brand_colors.dart',
    widgetOrArea: 'BrandColors',
    issue:
        'Neutral/status ramps are intentionally fixed (not seed-derived); '
        'expected for shared chrome.',
    priority: AuditFixPriority.notApplicable,
  ),
  ColorAuditEntry(
    location: 'lib/core/widgets/*',
    widgetOrArea: 'Vera primitives + card',
    issue: 'Uses context.brand — brand-aware.',
    priority: AuditFixPriority.notApplicable,
    fixed: true,
  ),
  ColorAuditEntry(
    location: 'lib/features/vera/brand_vera_colors.dart',
    widgetOrArea: 'veraColorsFromBrand',
    issue:
        'Maps seed-derived tokens into VeraColorsScope; neutrals/programGlow/'
        'wordmark stay Vera defaults on VeraColors class.',
    priority: AuditFixPriority.medium,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/features/rewards/widgets/redeem_balance_hero_card.dart',
    widgetOrArea: 'RedeemBalanceHeroCard',
    issue: 'Hardcoded purple gradient stops (0xFF291063, …) bypass scope.',
    priority: AuditFixPriority.high,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/features/rewards/widgets/redeem_points_dial.dart',
    widgetOrArea: 'RedeemPointsDial',
    issue: 'Ring fill _redeemRingFill = 0xFF4C2D93 not tied to brand.',
    priority: AuditFixPriority.high,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/features/rewards/widgets/rewards_program_name_text.dart',
    widgetOrArea: 'RewardsProgramNameText',
    issue: 'Fixed wordmark gradient [0xFF5F5F5F, 0xFF000000].',
    priority: AuditFixPriority.medium,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/features/transactions/transaction_detail_screen.dart',
    widgetOrArea: 'Merchant hero',
    issue: 'Hardcoded 0xFF987CD7, 0xFF160064 gradient accents.',
    priority: AuditFixPriority.medium,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/features/statements/statement_document_screen.dart',
    widgetOrArea: 'Statement PDF mock',
    issue: 'Document palette uses fixed ink/accent hex (print layout).',
    priority: AuditFixPriority.low,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/features/settings/profile_screen.dart',
    widgetOrArea: 'Profile avatar ring',
    issue: 'Decorative ring Color(0xFF2DE2E2) not brand-derived.',
    priority: AuditFixPriority.low,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/features/pay/payment_summary_screen.dart',
    widgetOrArea: 'Success ring',
    issue: 'Success glow uses fixed greens (_outerRing, _innerGlow).',
    priority: AuditFixPriority.medium,
  ),
  ColorAuditEntry(
    location: 'vera_design/lib/app/theme/vera_colors_scope.dart',
    widgetOrArea: 'VeraColorsScope.of fallback',
    issue:
        'Missing scope falls back to VeraColors.current (purple defaults). '
        'Project360 host always wraps Vera app.',
    priority: AuditFixPriority.notApplicable,
  ),
];
