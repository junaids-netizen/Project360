import 'package:flutter/material.dart';
import 'package:project360/core/haptics.dart';

/// Pops the root navigator back to [IndexScreen] (the Project360 launcher).
void popToProjectIndex(BuildContext context) {
  Haptics.selection();
  final nav = Navigator.of(context);
  if (!nav.canPop()) return;
  nav.popUntil((route) => route.isFirst);
}
