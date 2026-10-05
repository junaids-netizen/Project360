import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project360/app/design_branch_registry.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/features/brand/brand_picker_sheet.dart';

const double _kIndexCardRadius = 26;

/// First screen on cold start. Lists registered demos; tap pushes the prototype.
class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: colors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const _IndexHeader(title: 'Project360'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.white,
                    borderRadius: BorderRadius.circular(_kIndexCardRadius),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const _BrandRow(),
                ),
              ),
            ),
            for (final section in designSections) ...[
              if (section.title != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      section.title!,
                      style: TextStyle(
                        fontFamily: VeraTypography.geist,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        height: 1.2,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  section.title != null ? 12 : 16,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _IndexCard(branches: section.branches),
                ),
              ),
            ],
            const _IndexBottomGap(),
          ],
        ),
      ),
    );
  }
}

/// Opens the brand switcher from the launcher. Brand studio reads the active
/// brand from [BrandScope].
class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final brand = BrandScope.of(context).brand;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: Haptics.wrap(() => showBrandPicker(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VeraSpacing.page,
          vertical: VeraSpacing.s12,
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
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: brand.seed,
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
    );
  }
}

class _IndexBottomGap extends StatelessWidget {
  const _IndexBottomGap();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 40,
      ),
    );
  }
}

class _IndexCard extends StatelessWidget {
  const _IndexCard({required this.branches});

  final List<DesignBranch> branches;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(_kIndexCardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < branches.length; i++) ...[
              _IndexRow(branch: branches[i]),
              if (i < branches.length - 1)
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 16,
                  color: colors.border,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IndexRow extends StatelessWidget {
  const _IndexRow({required this.branch});

  final DesignBranch branch;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.light();
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: branch.builder,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    branch.label,
                    style: TextStyle(
                      fontFamily: VeraTypography.geist,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      height: 1.35,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (branch.description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      branch.description!,
                      style: TextStyle(
                        fontFamily: VeraTypography.geist,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.06,
                        height: 1.3,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.textSecondary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexHeader extends StatelessWidget {
  const _IndexHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _IndexHeaderDelegate(
        title: title,
        topPadding: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class _IndexHeaderDelegate extends SliverPersistentHeaderDelegate {
  _IndexHeaderDelegate({required this.title, required this.topPadding});

  final String title;
  final double topPadding;

  @override
  double get maxExtent => topPadding + 96;

  @override
  double get minExtent => topPadding + 52;

  @override
  bool shouldRebuild(covariant _IndexHeaderDelegate oldDelegate) =>
      title != oldDelegate.title || topPadding != oldDelegate.topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.brand;
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final fontSize = lerpDouble(28, 17, progress) ?? 17;

    return LayoutBuilder(
      builder: (context, constraints) {
        final header = SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: lerpDouble(12, 14, progress) ?? 14,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: VeraTypography.geist,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: fontSize > 20 ? -0.56 : -0.22,
                  height: 1.1,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        );

        final overlay = BoxDecoration(
          color: colors.white.withValues(alpha: 0.62),
          border: Border(
            bottom: BorderSide(color: colors.textPrimary.withValues(alpha: 0.06)),
          ),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: DecoratedBox(decoration: overlay, child: header),
          ),
        );
      },
    );
  }
}
