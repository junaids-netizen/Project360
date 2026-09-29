import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';

class VeraCapsule extends StatelessWidget {
  const VeraCapsule({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Container(
      width: width ?? double.infinity,
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(VeraRadii.card),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}

class VeraSectionTitle extends StatelessWidget {
  const VeraSectionTitle({
    super.key,
    required this.title,
    this.titleSuffix,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  final String title;

  /// Inline secondary text after [title] (e.g. "by Jul 15"), not a right-aligned trailing.
  final String? titleSuffix;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        title,
                        style: context.type.h3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (titleSuffix != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        titleSuffix!,
                        style: context.type.h3.copyWith(
                          color: colors.textPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null || showChevron) const SizedBox(width: 8),
              ?trailing,
              if (showChevron) const VeraSvg(VeraAssets.chevron, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class VeraDentonAmount extends StatelessWidget {
  const VeraDentonAmount({
    super.key,
    required this.dollars,
    this.cents,
    this.dollarSize = 30,
    this.wholeSize = 40,
    this.centSize = 21,
    this.gradient = true,
    this.alignEnd = false,
  });

  final String dollars;
  final String? cents;
  final double dollarSize;
  final double wholeSize;
  final double centSize;
  final bool gradient;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final wholeStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w700,
      fontSize: wholeSize,
      height: 1,
      letterSpacing: -0.8,
      color: gradient ? null : colors.textPrimary,
    );
    final dollarStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w700,
      fontSize: dollarSize,
      height: 1,
      color: colors.textPrimary.withValues(alpha: 0.5),
    );
    final centStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w200,
      fontSize: centSize,
      height: 1,
      color: colors.textSecondary,
    );

    Widget whole = Text(dollars, style: wholeStyle);
    if (gradient) {
      whole = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.darkGradient,
          stops: const [0.1875, 0.856, 0.968],
        ).createShader(bounds),
        child: whole,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 36,
          child: Center(child: Text('\$', style: dollarStyle)),
        ),
        const SizedBox(width: 2),
        whole,
        if (cents != null) Text(cents!, style: centStyle),
      ],
    );
  }
}

class VeraToolbar extends StatelessWidget {
  const VeraToolbar({
    super.key,
    required this.title,
    this.onBack,
    this.onInfo,
    this.showBack = true,
    this.showTrailing = true,
    this.backButtonKey,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final bool showBack;
  final bool showTrailing;
  final Key? backButtonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            if (showBack)
              GestureDetector(
                key: backButtonKey,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                child: const VeraSvg(VeraAssets.back, size: 24),
              )
            else
              const SizedBox(width: 24, height: 24),
            Expanded(
              child: title.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.type.h3.copyWith(
                        color: context.brand.headerPrimary,
                      ),
                    ),
            ),
            if (showTrailing)
              GestureDetector(
                onTap: onInfo,
                child: const VeraSvg(VeraAssets.info, size: 24),
              )
            else
              const SizedBox(width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

class VeraPrimaryButton extends StatelessWidget {
  const VeraPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 40,
    this.width,
  });

  final String label;
  final VoidCallback? onTap;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
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
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.type.button.copyWith(
            color: colors.onColor(colors.buttonGradient[1]),
          ),
        ),
      ),
    );
  }
}

class VeraListRow extends StatelessWidget {
  const VeraListRow({
    super.key,
    required this.icon,
    required this.label,
    this.iconSize = 24,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final String label;
  final double iconSize;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            VeraSvg(icon, size: iconSize),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: context.type.h4)),
            trailing ?? const VeraSvg(VeraAssets.chevronSmall, size: 24),
          ],
        ),
      ),
    );
  }
}

class VeraToggle extends StatelessWidget {
  const VeraToggle({super.key, required this.on, this.onChanged});

  final bool on;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: on ? colors.navActive : colors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.knobShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma "Profile Picture" — 40×40 header avatar with initials.
class VeraProfileAvatar extends StatelessWidget {
  const VeraProfileAvatar({super.key, this.initials = MockData.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final initialsStyle = TextStyle(
      fontFamily: VeraTypography.geist,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 22 / 16,
      letterSpacing: -0.32,
      color: colors.textPrimary,
    );

    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.white,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: colors.border, width: 1.25),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              offset: const Offset(0, 4),
              blurRadius: 3,
            ),
          ],
        ),
        child: Center(child: Text(initials, style: initialsStyle)),
      ),
    );
  }
}
