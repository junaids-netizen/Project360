import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/features/glass_tab/glass_tab_item.dart';
import 'package:project360/features/glass_tab/native_glass_availability.dart';

/// Tab shell with native Liquid Glass on iOS 26+ (when vendored) and a gray
/// capsule fallback elsewhere. Matches Vera's glass-tab handoff contract.
class GlassTabShell extends StatefulWidget {
  const GlassTabShell({
    super.key,
    required this.navigationShell,
    required this.tabs,
    this.fadeDuration = const Duration(milliseconds: 220),
  });

  final StatefulNavigationShell navigationShell;
  final List<GlassTabItem> tabs;
  final Duration fadeDuration;

  @override
  State<GlassTabShell> createState() => _GlassTabShellState();
}

class _GlassTabShellState extends State<GlassTabShell> {
  double _contentOpacity = 1;

  void _selectTab(int index) {
    final shell = widget.navigationShell;
    final reselect = index == shell.currentIndex;

    Haptics.selection();
    setState(() => _contentOpacity = 0.72);
    Future<void>.delayed(widget.fadeDuration ~/ 2, () {
      if (!mounted) return;
      shell.goBranch(index, initialLocation: reselect);
      setState(() => _contentOpacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final useNative =
        CupertinoNative.useNativeViews && NativeGlassAvailability.isAvailable;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _contentOpacity,
            duration: widget.fadeDuration,
            curve: Curves.easeOut,
            child: widget.navigationShell,
          ),
          if (useNative)
            _NativeTabOverlay(
              tabs: widget.tabs,
              selectedIndex: widget.navigationShell.currentIndex,
              onSelect: _selectTab,
            )
          else
            Positioned(
              left: 16,
              right: 16,
              bottom: bottom + 8,
              child: _FallbackCapsuleBar(
                tabs: widget.tabs,
                selectedIndex: widget.navigationShell.currentIndex,
                onSelect: _selectTab,
              ),
            ),
        ],
      ),
    );
  }
}

/// Placeholder until Vera's native overlay is vendored.
class _NativeTabOverlay extends StatelessWidget {
  const _NativeTabOverlay({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<GlassTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return _FallbackCapsuleBar(
      tabs: tabs,
      selectedIndex: selectedIndex,
      onSelect: onSelect,
    );
  }
}

class _FallbackCapsuleBar extends StatelessWidget {
  const _FallbackCapsuleBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<GlassTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.navSurface,
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
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _TabButton(
                  label: tabs[i].label,
                  icon: tabs[i].icon,
                  selected: selectedIndex == i,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
