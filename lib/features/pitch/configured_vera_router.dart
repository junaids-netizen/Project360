import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/bank/bank_flows.dart';
import 'package:project360/features/bank/inbox_screen.dart';
import 'package:project360/features/bank/manage_card_screen.dart';
import 'package:project360/features/bank/rewards_screen.dart';
import 'package:project360/features/bank/settings_screen.dart';
import 'package:project360/features/pitch/home_module_gate.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/preview_back.dart';

/// Tabbed bank shell whose branches are only [modules], in pitch order.
///
/// Subflows that belong to an included module (card activation, pay, inbox)
/// stay reachable. Paths for a module that was switched off redirect home.
GoRouter createPitchRouter(List<PitchModule> modules) {
  final enabled = modules.toSet();
  final rootKey = GlobalKey<NavigatorState>();

  Widget screenFor(PitchModule module) => switch (module) {
    PitchModule.home => GatedHome(modules: enabled),
    PitchModule.rewards => const RewardsScreen(),
    PitchModule.card => const ManageCardScreen(),
    PitchModule.notifications => const InboxScreen(),
    PitchModule.settings => const SettingsScreen(),
  };

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final path = state.uri.path;
      if (pitchAllowsPath(enabled, path)) return null;
      return '/home';
    },
    errorBuilder: (context, state) => _MissingStep(path: state.uri.path),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PitchTabShell(
            navigationShell: navigationShell,
            modules: modules,
          );
        },
        branches: [
          for (final module in modules)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/${module.path}',
                  pageBuilder: (context, state) =>
                      NoTransitionPage(child: screenFor(module)),
                ),
              ],
            ),
        ],
      ),
      GoRoute(
        path: '/pay',
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: PayScreen()),
      ),
      GoRoute(
        path: '/authorized-users/add',
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: AddAuthorizedUserScreen()),
      ),
      if (enabled.contains(PitchModule.notifications))
        GoRoute(
          path: '/inbox',
          parentNavigatorKey: rootKey,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: InboxScreen()),
        ),
      if (enabled.contains(PitchModule.card)) ...[
        GoRoute(
          path: '/card/replace',
          parentNavigatorKey: rootKey,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: ReplaceCardScreen()),
        ),
        GoRoute(
          path: '/card/received',
          parentNavigatorKey: rootKey,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: CardReceivedPromptScreen()),
        ),
        GoRoute(
          path: '/card/cvc',
          parentNavigatorKey: rootKey,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: CardActivateCvcScreen()),
        ),
        GoRoute(
          path: '/card/ready',
          parentNavigatorKey: rootKey,
          pageBuilder: (context, state) =>
              const CupertinoPage(child: CardReadyScreen()),
        ),
      ],
    ],
  );
}

class PitchTabShell extends StatelessWidget {
  const PitchTabShell({
    super.key,
    required this.navigationShell,
    required this.modules,
  });

  final StatefulNavigationShell navigationShell;
  final List<PitchModule> modules;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom;

    final back = PreviewBack.maybeOf(context);

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (back != null)
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  key: const Key('preview-back'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Haptics.light();
                    back.onBack();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VeraSvg(VeraAssets.back, size: 24),
                        const SizedBox(width: 8),
                        Text('Back', style: context.type.h4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                navigationShell,
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: bottom + 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: colors.navShadow,
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          for (var i = 0; i < modules.length; i++)
                            Expanded(
                              child: _TabButton(
                                label: modules[i].tabLabel,
                                icon: _tabIcon(modules[i]),
                                selected: navigationShell.currentIndex == i,
                                onTap: () {
                                  Haptics.selection();
                                  navigationShell.goBranch(
                                    i,
                                    initialLocation:
                                        i == navigationShell.currentIndex,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _tabIcon(PitchModule module) => switch (module) {
  PitchModule.home => CupertinoIcons.house_fill,
  PitchModule.rewards => CupertinoIcons.sparkles,
  PitchModule.card => CupertinoIcons.creditcard_fill,
  PitchModule.notifications => CupertinoIcons.bell_fill,
  PitchModule.settings => CupertinoIcons.person_crop_circle,
};

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final color = selected ? colors.navActive : colors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: VeraTypography.geist,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingStep extends StatelessWidget {
  const _MissingStep({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                icon: Icon(Icons.arrow_back, color: colors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text('Not in this build', style: context.type.h3),
              const SizedBox(height: 8),
              Text(
                'This step is outside the modules selected for the pitch.',
                style: context.type.p1.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
