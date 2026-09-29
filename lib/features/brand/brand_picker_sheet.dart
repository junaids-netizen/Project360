import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_assets.dart';

/// Opens the brand switcher.
///
/// Deliberately short, so the top of the screen behind it stays visible and a
/// brand change can be seen landing without dismissing the sheet first.
Future<void> showBrandPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: context.brand.scrim,
    isScrollControlled: true,
    builder: (_) => const BrandPickerSheet(),
  );
}

class BrandPickerSheet extends StatelessWidget {
  const BrandPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final active = BrandScope.of(context).brand;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.navShadow,
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Expanded(child: Text('Brand', style: context.type.h3)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Done',
                      style: context.type.h4.copyWith(color: colors.accent),
                    ),
                  ),
                ],
              ),
            ),
            for (final preset in brandPresets)
              _BrandRow(
                brand: preset,
                selected: preset.id == active.id,
              ),
            Divider(height: 17, thickness: 1, color: colors.border),
            _CustomBrand(active: active),
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.brand, required this.selected});

  final Brand brand;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: Haptics.wrap(() => BrandScope.read(context).select(brand)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VeraSpacing.s20,
          vertical: 10,
        ),
        child: Row(
          children: [
            _Swatch(seed: brand.seed),
            const SizedBox(width: 12),
            Expanded(child: Text(brand.name, style: context.type.h4)),
            if (selected)
              VeraSvg(VeraAssets.checkCircle, size: 20, color: colors.accent),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.seed});

  final Color seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: seed,
        shape: BoxShape.circle,
        border: Border.all(color: context.brand.border, width: 1.25),
      ),
    );
  }
}

/// Dials in a colour that is not saved as a preset — the answer to "our brand
/// blue is actually a bit deeper than that" halfway through a meeting.
///
/// Hue picks the colour; intensity drives [Brand.saturationScale], which is
/// what makes a muted navy or slate identity look right rather than neon.
class _CustomBrand extends StatefulWidget {
  const _CustomBrand({required this.active});

  final Brand active;

  @override
  State<_CustomBrand> createState() => _CustomBrandState();
}

class _CustomBrandState extends State<_CustomBrand> {
  /// Vera's own saturation and lightness, so sliding hue alone walks the brand
  /// around the wheel without changing how vivid the design feels.
  static const double _seedSaturation = 0.9281;
  static const double _seedLightness = 0.6725;

  late double _hue = HSLColor.fromColor(widget.active.seed).hue;
  late double _intensity = widget.active.saturationScale;

  @override
  void didUpdateWidget(covariant _CustomBrand oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow the presets, so the strips show where a tapped bank sits rather
    // than whatever was last dialled in by hand.
    if (widget.active.id == Brand.customId) return;
    _hue = HSLColor.fromColor(widget.active.seed).hue;
    _intensity = widget.active.saturationScale;
  }

  Color get _seed =>
      HSLColor.fromAHSL(1, _hue, _seedSaturation, _seedLightness).toColor();

  void _apply() {
    BrandScope.read(context).select(
      Brand(
        id: Brand.customId,
        name: 'Custom',
        seed: _seed,
        saturationScale: _intensity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VeraSpacing.s20,
        4,
        VeraSpacing.s20,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Swatch(seed: _seed),
              const SizedBox(width: 12),
              Expanded(child: Text('Custom', style: context.type.h4)),
              if (widget.active.id == Brand.customId)
                VeraSvg(
                  VeraAssets.checkCircle,
                  size: 20,
                  color: colors.accent,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Strip(
            gradient: hueSpectrum,
            position: _hue / 360,
            onChanged: (t) {
              setState(() => _hue = (t * 360).clamp(0, 359.9));
              _apply();
            },
          ),
          const SizedBox(height: 10),
          _Strip(
            gradient: [
              HSLColor.fromAHSL(1, _hue, 0.0, _seedLightness).toColor(),
              _seed,
            ],
            position: _intensity,
            onChanged: (t) {
              setState(() => _intensity = t.clamp(0.05, 1.0));
              _apply();
            },
          ),
        ],
      ),
    );
  }
}

/// A gradient bar with a draggable knob. Reports 0..1 across its width.
class _Strip extends StatelessWidget {
  const _Strip({
    required this.gradient,
    required this.position,
    required this.onChanged,
  });

  final List<Color> gradient;
  final double position;
  final ValueChanged<double> onChanged;

  static const double _height = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        void report(double dx) => onChanged((dx / width).clamp(0.0, 1.0));

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => report(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => report(d.localPosition.dx),
          child: SizedBox(
            height: _height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(VeraRadii.pill),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: (position.clamp(0.0, 1.0) * width) - _height / 2,
                  top: 0,
                  width: _height,
                  height: _height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: colors.chromeShadow,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
