import 'package:flutter/cupertino.dart';
import 'package:project360/features/glass_tab/glass_tab_item.dart';
import 'package:project360/features/pitch/pitch_modules.dart';

IconData pitchModuleTabIcon(PitchModule module) => switch (module) {
  PitchModule.home => CupertinoIcons.house_fill,
  PitchModule.rewards => CupertinoIcons.sparkles,
  PitchModule.card => CupertinoIcons.creditcard_fill,
  PitchModule.notifications => CupertinoIcons.bell_fill,
  PitchModule.settings => CupertinoIcons.person_crop_circle,
};

List<GlassTabItem> glassTabsForPitchModules(List<PitchModule> modules) {
  return [
    for (final module in modules)
      GlassTabItem(label: module.tabLabel, icon: pitchModuleTabIcon(module)),
  ];
}
