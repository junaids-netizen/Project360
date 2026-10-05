import 'package:flutter/material.dart';
import 'package:project360/features/brand/brand_gallery_screen.dart';
import 'package:project360/features/design_system/design_system_screen.dart';
import 'package:project360/features/vera/vera_prototype_host.dart';

/// Registered demos for the index launcher (first screen on launch).
class DesignBranch {
  const DesignBranch({
    required this.label,
    required this.builder,
    this.description,
  });

  final String label;
  final String? description;
  final WidgetBuilder builder;
}

class DesignSection {
  const DesignSection({required this.branches, this.title});

  final String? title;
  final List<DesignBranch> branches;
}

const List<DesignSection> designSections = [
  DesignSection(
    title: 'Design system',
    branches: [
      DesignBranch(
        label: 'Component library',
        description:
            'Tokens, atoms, molecules, organisms — live previews under the active brand',
        builder: _designSystem,
      ),
      DesignBranch(
        label: 'Brand studio',
        description: 'Full token ramp + primitives (quick brand regression check)',
        builder: _brandGallery,
      ),
    ],
  ),
  DesignSection(
    title: 'Vera Cards',
    branches: [
      DesignBranch(
        label: 'Vera app',
        description: 'Full tabbed experience — home, rewards, card, and account',
        builder: _veraCards,
      ),
    ],
  ),
];

Widget _designSystem(BuildContext context) => const DesignSystemScreen();

Widget _brandGallery(BuildContext context) => const BrandGalleryScreen();

Widget _veraCards(BuildContext context) => const VeraCardPrototypeHost();
