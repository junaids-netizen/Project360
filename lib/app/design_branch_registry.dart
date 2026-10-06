import 'package:flutter/material.dart';
import 'package:project360/features/brand/brand_gallery_screen.dart';
import 'package:project360/features/builder/build_app_screen.dart';
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
    branches: [
      DesignBranch(
        label: 'Build an app',
        description: 'Choose the bank and the modules they get, then preview',
        builder: _buildApp,
      ),
      DesignBranch(
        label: 'Brand studio',
        description: 'Tokens, card face, and primitives under the active brand',
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

Widget _buildApp(BuildContext context) => const BuildAppScreen();

Widget _brandGallery(BuildContext context) => const BrandGalleryScreen();

Widget _veraCards(BuildContext context) => const VeraCardPrototypeHost();
