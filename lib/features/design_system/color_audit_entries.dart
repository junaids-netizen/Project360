/// Structured colour-token audit for Project360 surfaces.
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
        'Launcher chrome used fixed greys and black '
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
    location: 'lib/features/bank/',
    widgetOrArea: 'Home, rewards, card, inbox, account',
    issue:
        'Pitch and Vera app screens read BrandColors in this repo. '
        'They no longer embed a sibling package with hardcoded purples.',
    priority: AuditFixPriority.notApplicable,
    fixed: true,
  ),
];
