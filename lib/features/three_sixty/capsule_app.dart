import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/three_sixty/capsule_shell.dart';
import 'package:project360/features/three_sixty/credit_health_screen.dart';
import 'package:project360/features/three_sixty/family_hub_screen.dart';
import 'package:project360/features/three_sixty/my_cards_screen.dart';

/// Capsule / 360 shell with fixed bottom tabs (My Cards, Family Hub, Credit Health, Merlin).
class CapsuleApp extends StatefulWidget {
  const CapsuleApp({super.key, this.initialTab = 0});

  /// Opens directly on a tab — used when launching Credit Health from the index.
  final int initialTab;

  @override
  State<CapsuleApp> createState() => _CapsuleAppState();
}

class _CapsuleAppState extends State<CapsuleApp> {
  late int _index = widget.initialTab.clamp(0, 3);

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: IndexedStack(
          index: _index,
          children: const [
            MyCardsScreen(),
            FamilyHubScreen(),
            CreditHealthScreen(),
            CapsulePlaceholderScreen(title: 'Merlin'),
          ],
        ),
        bottomNavigationBar: CapsuleTabBar(index: _index, onSelected: _go),
      ),
    );
  }
}
