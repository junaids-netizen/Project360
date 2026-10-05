import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/bank/bank_flows.dart';
import 'package:project360/features/bank/inbox_screen.dart';
import 'package:project360/features/bank/manage_card_screen.dart';
import 'package:project360/features/bank/rewards_screen.dart';
import 'package:project360/features/bank/settings_screen.dart';
import 'package:project360/features/glass_tab/glass_tab_shell.dart';
import 'package:project360/features/glass_tab/pitch_glass_tabs.dart';
import 'package:project360/features/pitch/home_module_gate.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/pitch_preview_chrome.dart';

/// Tabbed bank shell whose branches are only [modules], in pitch order.
///
/// Subflows that belong to an included module (card activation, pay, inbox)
/// stay reachable. Paths for a module that was switched off redirect home.
GoRouter createPitchRouterBank(List<PitchModule> modules) {
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
          return PitchPreviewChrome(
            child: GlassTabShell(
              navigationShell: navigationShell,
              tabs: glassTabsForPitchModules(modules),
            ),
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
