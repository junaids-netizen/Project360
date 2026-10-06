import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/brand/brand_picker_sheet.dart';
import 'package:project360/features/builder/app_module.dart';
import 'package:project360/features/builder/app_preview_screen.dart';
import 'package:project360/features/builder/module_icon.dart';

/// Wide enough for the phone layout in the reference, narrow enough that a
/// laptop pitch does not stretch the modules into a banner.
const double _kPhoneWidth = 420;

/// Pitch step after the index: pick the bank, tick the modules they get, then
/// preview that app.
class BuildAppScreen extends StatefulWidget {
  const BuildAppScreen({super.key});

  @override
  State<BuildAppScreen> createState() => _BuildAppScreenState();
}

class _BuildAppScreenState extends State<BuildAppScreen> {
  Set<AppModule> _enabled = {...AppModule.initial};

  void _toggle(AppModule module) {
    if (module.locked) return;
    Haptics.selection();
    setState(() {
      _enabled = {
        for (final candidate in AppModule.values)
          if (candidate.locked ||
              candidate != module && _enabled.contains(candidate) ||
              candidate == module && !_enabled.contains(module))
            candidate,
      };
    });
  }

  void _preview() {
    Haptics.light();
    final enabled = Set<AppModule>.unmodifiable(_enabled);
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AppPreviewScreen(enabled: enabled),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Scaffold(
      backgroundColor: colors.background,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kPhoneWidth),
          child: SafeArea(
            child: Column(
              children: [
                VeraToolbar(
                  title: 'Build an app',
                  onInfo: () => showBrandPicker(context),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      Text(
                        'Choose what this bank gets. Home stays on;\n'
                        'everything else is a module.',
                        style: context.type.p1.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: VeraSpacing.s16),
                      const _BrandCard(),
                      const SizedBox(height: 28),
                      Text(
                        'Modules',
                        style: context.type.h2.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: VeraSpacing.s12),
                      _ModuleCard(
                        enabled: _enabled,
                        onToggle: _toggle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: _PreviewButton(onTap: _preview),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final brand = BrandScope.of(context).brand;

    return GestureDetector(
      key: const ValueKey('build-app-brand'),
      behavior: HitTestBehavior.opaque,
      onTap: Haptics.wrap(() => showBrandPicker(context)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Text('Brand', style: context.type.h4)),
            Text(
              brand.name,
              style: context.type.p1.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: VeraSpacing.s8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: brand.seed,
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.enabled, required this.onToggle});

  final Set<AppModule> enabled;
  final ValueChanged<AppModule> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final module in AppModule.values)
            _ModuleRow(
              module: module,
              on: module.locked || enabled.contains(module),
              onToggle: () => onToggle(module),
            ),
        ],
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.module,
    required this.on,
    required this.onToggle,
  });

  final AppModule module;
  final bool on;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ModuleIcon(module: module, color: colors.navActive, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.label,
                  style: context.type.h4.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(module.detail, style: context.type.p2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          VeraToggle(
            key: ValueKey('module-${module.name}'),
            on: on,
            onChanged: module.locked ? null : (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      key: const ValueKey('preview-app'),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors.buttonGradient,
            stops: const [0.0136, 0.7134, 0.985],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.buttonShadow,
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          'Preview app',
          style: context.type.button.copyWith(
            fontFamily: VeraTypography.geist,
            fontSize: 16,
            color: colors.onColor(colors.buttonGradient[1]),
          ),
        ),
      ),
    );
  }
}
