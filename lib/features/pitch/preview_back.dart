import 'package:flutter/widgets.dart';

/// Lets the embedded preview pop back to the screen that opened it.
///
/// The preview owns its own router, so the tab shell cannot see the outer
/// navigator. This scope sits above that router and carries the pop.
class PreviewBack extends InheritedWidget {
  const PreviewBack({super.key, required this.onBack, required super.child});

  final VoidCallback onBack;

  static PreviewBack? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PreviewBack>();
  }

  @override
  bool updateShouldNotify(PreviewBack oldWidget) => oldWidget.onBack != onBack;
}
