import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/home/bank_shell.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  var _frozen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
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
              VeraSpacing.s8,
              VeraSpacing.page,
              bottom,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              Text(
                'Manage card',
                textAlign: TextAlign.center,
                style: context.type.h3,
              ),
              const SizedBox(height: VeraSpacing.s16),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 220),
                    child: VeraCardFace(
                      height: 188,
                      revealed: false,
                      showBrand: false,
                      showCvv: true,
                      banner: 'Activate Physical Card',
                      frozen: _frozen,
                      onBanner: Haptics.wrap(() {}),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: VeraCapsule(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                                child: Text(
                                  'Freeze card',
                                  style: context.type.h4,
                                ),
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
                            icon: VeraAssets.wallet,
                            label: 'Manage digital wallets',
                            onTap: Haptics.wrap(() {}),
                          ),
                          VeraListRow(
                            icon: VeraAssets.replace,
                            label: 'Replace card',
                            onTap: Haptics.wrap(() {}),
                          ),
                          VeraListRow(
                            icon: VeraAssets.key,
                            label: 'Set Cash advance PIN',
                            onTap: Haptics.wrap(() {}),
                          ),
                          VeraListRow(
                            icon: VeraAssets.squareInfo,
                            label: 'Account details',
                            onTap: Haptics.wrap(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
