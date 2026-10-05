import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/home/bank_shell.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + bankTabClearance;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              VeraSpacing.page,
              VeraSpacing.s24,
              VeraSpacing.page,
              bottom,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              const Center(child: _Avatar()),
              const SizedBox(height: VeraSpacing.s16),
              Text(
                MockData.userName,
                textAlign: TextAlign.center,
                style: context.type.h2.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                MockData.joined,
                textAlign: TextAlign.center,
                style: context.type.p1,
              ),
              const SizedBox(height: VeraSpacing.s24),
              const BankSectionHeader(title: 'Account'),
              VeraCapsule(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    VeraListRow(
                      icon: VeraAssets.person,
                      label: 'Profile',
                      onTap: Haptics.wrap(() {}),
                    ),
                    VeraListRow(
                      icon: VeraAssets.lock,
                      label: 'Security & Login',
                      onTap: Haptics.wrap(() {}),
                    ),
                    VeraListRow(
                      icon: VeraAssets.bell,
                      label: 'Communication preferences',
                      onTap: Haptics.wrap(() {}),
                    ),
                    VeraListRow(
                      icon: VeraAssets.wallet,
                      label: 'Payment methods',
                      onTap: Haptics.wrap(() {}),
                    ),
                    VeraListRow(
                      icon: VeraAssets.statements,
                      label: 'Account Statements',
                      onTap: Haptics.wrap(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: VeraSpacing.s8),
              const BankSectionHeader(title: 'Legal and Support'),
              VeraCapsule(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    VeraListRow(
                      icon: VeraAssets.folder,
                      label: 'Legal documents',
                      onTap: Haptics.wrap(() {}),
                    ),
                    VeraListRow(
                      icon: VeraAssets.phone,
                      label: 'Contact us',
                      onTap: Haptics.wrap(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.darkGradient,
        ),
      ),
      child: Text(
        MockData.initials,
        style: TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w600,
          fontSize: 22,
          height: 1,
          color: colors.onColor(colors.darkGradient[0]),
        ),
      ),
    );
  }
}
