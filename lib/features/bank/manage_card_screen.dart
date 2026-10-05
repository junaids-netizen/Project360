import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/bank/bank_format.dart';

class ManageCardScreen extends StatefulWidget {
  const ManageCardScreen({super.key});

  @override
  State<ManageCardScreen> createState() => _ManageCardScreenState();
}

class _ManageCardScreenState extends State<ManageCardScreen> {
  var _frozen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = bankTabBottomInset(MediaQuery.paddingOf(context).bottom);

    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
        children: [
          Text('Card', style: context.type.h2),
          const SizedBox(height: 12),
          VeraCardFace(height: 200, showCvv: true, frozen: _frozen),
          const SizedBox(height: 16),
          VeraCapsule(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    VeraSvg(
                      VeraAssets.freeze,
                      size: 24,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Freeze card', style: context.type.h4),
                    ),
                    VeraToggle(
                      on: _frozen,
                      onChanged: (value) {
                        Haptics.selection();
                        setState(() => _frozen = value);
                      },
                    ),
                  ],
                ),
                VeraListRow(
                  icon: VeraAssets.replace,
                  label: 'Replace card',
                  onTap: () => context.push('/card/replace'),
                ),
                VeraListRow(
                  icon: VeraAssets.key,
                  label: 'Activate card',
                  onTap: () => context.push('/card/received'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
