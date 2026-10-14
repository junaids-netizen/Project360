import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data_capsule.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';

/// Figma **Manage card** (`9:6978`) — card preview and management actions.
class ManageCardScreen extends StatefulWidget {
  const ManageCardScreen({super.key});

  @override
  State<ManageCardScreen> createState() => _ManageCardScreenState();
}

class _ManageCardScreenState extends State<ManageCardScreen> {
  var _frozen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Scaffold(
      backgroundColor: colors.white,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                const _ManageTitleBar(),
                const SizedBox(height: VeraSpacing.s8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: VeraSpacing.page),
                  child: _ManageCardPreview(),
                ),
                const SizedBox(height: VeraSpacing.s8),
                _ManageActionRow(
                  icon: VeraAssets.freeze,
                  title: 'Freeze card',
                  subtitle: 'Temporarily pause transactions',
                  showDivider: true,
                  trailing: VeraToggle(
                    on: _frozen,
                    onChanged: (value) {
                      Haptics.selection();
                      setState(() => _frozen = value);
                    },
                  ),
                ),
                _ManageActionRow(
                  icon: VeraAssets.replace,
                  title: 'Replace card',
                  subtitle: 'Card is lost, stolen, or damaged',
                  onTap: Haptics.wrap(() {}),
                  showDivider: true,
                ),
                _ManageActionRow(
                  icon: VeraAssets.key,
                  title: 'Change PIN',
                  subtitle: 'Set and manage PIN for cash advances',
                  onTap: Haptics.wrap(() {}),
                  showDivider: true,
                ),
                _ManageActionRow(
                  icon: VeraAssets.wallet,
                  title: 'Manage digital wallets',
                  subtitle: 'View and control stored cards',
                  onTap: Haptics.wrap(() {}),
                  showDivider: true,
                ),
                _ManageActionRow(
                  icon: VeraAssets.squareInfo,
                  title: 'View account details',
                  subtitle: 'Credit Limit, APR, Fees, Benefits, and more',
                  onTap: Haptics.wrap(() {}),
                  showDivider: false,
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageTitleBar extends StatelessWidget {
  const _ManageTitleBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(VeraSpacing.s8),
      child: Row(
        children: [
          GestureDetector(
            onTap: Haptics.wrap(() => Navigator.of(context).maybePop()),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(VeraSpacing.s8),
              child: VeraSvg(VeraAssets.back, size: 24),
            ),
          ),
          Expanded(
            child: Text(
              'Manage card',
              style: context.type.h4.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageCardPreview extends StatelessWidget {
  const _ManageCardPreview();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(VeraSpacing.s24),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VeraRadii.card),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MockDataCapsule.cardholderName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: VeraTypography.geist,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 1.92,
                    color: colors.white,
                  ),
                ),
                const SizedBox(height: VeraSpacing.s8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '•••• ${MockDataCapsule.cardLast4}',
                      style: TextStyle(
                        fontFamily: VeraTypography.geistMono,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.6,
                        color: colors.white,
                      ),
                    ),
                    const SizedBox(width: VeraSpacing.s8),
                    VeraSvg(VeraAssets.eye, size: 18, color: colors.white),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              'VISA',
              style: TextStyle(
                fontFamily: VeraTypography.geist,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 2,
                color: colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageActionRow extends StatelessWidget {
  const _ManageActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VeraSpacing.s8,
                vertical: VeraSpacing.s12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(VeraSpacing.s8),
                    child: VeraSvg(icon, size: 24, color: colors.textPrimary),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.type.h4),
                        const SizedBox(height: VeraSpacing.s2),
                        Text(subtitle, style: context.type.p2),
                      ],
                    ),
                  ),
                  trailing ??
                      Padding(
                        padding: const EdgeInsets.all(VeraSpacing.s8),
                        child: VeraSvg(
                          VeraAssets.chevron,
                          size: 24,
                          color: colors.textPrimary,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 56, right: VeraSpacing.s16),
            child: Divider(height: 1, thickness: 1, color: colors.borderMuted),
          ),
      ],
    );
  }
}
