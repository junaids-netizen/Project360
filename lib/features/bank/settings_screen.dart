import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/bank/bank_format.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = bankTabBottomInset(MediaQuery.paddingOf(context).bottom);

    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
        children: [
          Text('Account', style: context.type.h2),
          const SizedBox(height: 16),
          VeraCapsule(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const VeraProfileAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(MockData.userName, style: context.type.h4),
                      Text(
                        MockData.joined,
                        style: context.type.p2.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          VeraCapsule(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const VeraListRow(
                  icon: VeraAssets.person,
                  label: 'Profile',
                  trailing: SizedBox.shrink(),
                ),
                const VeraListRow(
                  icon: VeraAssets.lock,
                  label: 'Security',
                  trailing: SizedBox.shrink(),
                ),
                VeraListRow(
                  icon: VeraAssets.person,
                  label: 'Authorized users',
                  onTap: () => context.push('/authorized-users/add'),
                ),
                const VeraListRow(
                  icon: VeraAssets.phone,
                  label: 'Support',
                  trailing: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
