import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/builder/app_module.dart';
import 'package:project360/features/builder/module_icon.dart';

const double _kPhoneWidth = 420;

/// The app a bank would get: home, plus only the modules switched on.
class AppPreviewScreen extends StatefulWidget {
  const AppPreviewScreen({super.key, required this.enabled});

  final Set<AppModule> enabled;

  @override
  State<AppPreviewScreen> createState() => _AppPreviewScreenState();
}

class _AppPreviewScreenState extends State<AppPreviewScreen> {
  late AppModule _tab = AppModule.home;

  List<AppModule> get _tabs => [
    for (final module in AppModule.values)
      if (widget.enabled.contains(module)) module,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final brand = BrandScope.of(context).brand;
    final tabs = _tabs;
    final tab = tabs.contains(_tab) ? _tab : AppModule.home;

    return Scaffold(
      backgroundColor: colors.background,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kPhoneWidth),
          child: SafeArea(
            bottom: tabs.length < 2,
            child: Column(
              children: [
                VeraToolbar(
                  title: brand.name,
                  showTrailing: false,
                ),
                Expanded(child: _PreviewBody(module: tab)),
                if (tabs.length > 1)
                  _PreviewNav(
                    tabs: tabs,
                    selected: tab,
                    onSelect: (module) => setState(() => _tab = module),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({required this.module});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        switch (module) {
          AppModule.home => const _HomePreview(),
          AppModule.rewards => const _RewardsPreview(),
          AppModule.card => const _CardPreview(),
          AppModule.notifications => const _InboxPreview(),
          AppModule.settings => const _SettingsPreview(),
        },
      ],
    );
  }
}

class _HomePreview extends StatelessWidget {
  const _HomePreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VeraCardFace(height: 180, showCvv: true),
        SizedBox(height: 12),
        VeraBalanceBar(),
      ],
    );
  }
}

class _RewardsPreview extends StatelessWidget {
  const _RewardsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MockData.programName, style: context.type.h3),
        Text(MockData.programSubtitle, style: context.type.p2),
        const SizedBox(height: VeraSpacing.s16),
        Text(
          '${MockData.rewardsPoints}',
          style: TextStyle(
            fontFamily: VeraTypography.denton,
            fontWeight: FontWeight.w700,
            fontSize: 40,
            height: 1,
            letterSpacing: -0.8,
            color: context.brand.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text('points', style: context.type.p2),
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const VeraCardFace(height: 180, showCvv: true),
        const SizedBox(height: 12),
        VeraListRow(icon: VeraAssets.freeze, label: 'Freeze card'),
        VeraListRow(icon: VeraAssets.wallet, label: 'Wallets'),
        VeraListRow(icon: VeraAssets.replace, label: 'Replace card'),
      ],
    );
  }
}

class _InboxPreview extends StatelessWidget {
  const _InboxPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final txn in MockData.homeTransactions.take(4))
          VeraListRow(icon: VeraAssets.inbox, label: txn.title),
      ],
    );
  }
}

class _SettingsPreview extends StatelessWidget {
  const _SettingsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const VeraProfileAvatar(),
        const SizedBox(height: 8),
        Text(MockData.userName, style: context.type.h4),
        Text(MockData.joined, style: context.type.p2),
        const SizedBox(height: VeraSpacing.s16),
        VeraListRow(icon: VeraAssets.person, label: 'Profile'),
        VeraListRow(icon: VeraAssets.lock, label: 'Security'),
        VeraListRow(icon: VeraAssets.bell, label: 'Notifications'),
      ],
    );
  }
}

class _PreviewNav extends StatelessWidget {
  const _PreviewNav({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<AppModule> tabs;
  final AppModule selected;
  final ValueChanged<AppModule> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.navSurface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (final module in tabs)
                Expanded(
                  child: GestureDetector(
                    key: ValueKey('preview-tab-${module.name}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(module),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ModuleIcon(
                          module: module,
                          size: 20,
                          color: module == selected
                              ? colors.navActive
                              : colors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module.tabLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.tab.copyWith(
                            color: module == selected
                                ? colors.navActive
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
