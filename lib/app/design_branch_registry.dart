import 'package:flutter/material.dart';
import 'package:project360/features/brand/brand_gallery_screen.dart';
import 'package:project360/features/home/bank_shell.dart';
import 'package:project360/features/three_sixty/capsule_app.dart';

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
        description: 'Home, rewards, card, and account',
        builder: _home,
      ),
    ],
  ),
  DesignSection(
    title: '360',
    branches: [
      DesignBranch(
        label: 'Capsule app',
        description: 'My Cards, Family Hub, Credit Health, and Merlin',
        builder: _capsuleApp,
      ),
      DesignBranch(
        label: 'Credit Health',
        description: 'Score gauge and history (Capsule tab 3)',
        builder: _capsuleCreditHealth,
      ),
    ],
  ),
];

Widget _brandGallery(BuildContext context) => const BrandGalleryScreen();

Widget _home(BuildContext context) => const BankApp();

Widget _capsuleApp(BuildContext context) => const CapsuleApp();

Widget _capsuleCreditHealth(BuildContext context) =>
    const CapsuleApp(initialTab: 2);
