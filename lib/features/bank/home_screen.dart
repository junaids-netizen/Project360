import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/bank/bank_format.dart';

/// Balances, the card, and the shortcuts a pitch can turn off.
///
/// Shortcut labels are the exact strings [hiddenHomeShortcutLabels] covers:
/// Rewards, Card, Account, Inbox, Notifications.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = bankTabBottomInset(MediaQuery.paddingOf(context).bottom);

    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom),
        children: [
          const Row(
            children: [
              VeraProfileAvatar(),
              SizedBox(width: 12),
              Expanded(child: _Greeting()),
            ],
          ),
          const SizedBox(height: 16),
          const VeraBalanceBar(),
          const SizedBox(height: 16),
          const VeraCardFace(height: 168, showCvv: true),
          const SizedBox(height: 16),
          VeraPrimaryButton(
            label: 'Pay now',
            width: double.infinity,
            height: 48,
            onTap: Haptics.wrap(() => context.push('/pay')),
          ),
          const SizedBox(height: 20),
          const VeraSectionTitle(title: 'Transactions'),
          VeraCapsule(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (final txn in MockData.homeTransactions) _TxnRow(txn: txn),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const VeraSectionTitle(title: 'Shortcuts'),
          VeraCapsule(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                VeraListRow(
                  icon: VeraAssets.rewardsSparkle,
                  label: 'Rewards',
                  onTap: () => context.go('/rewards'),
                ),
                VeraListRow(
                  icon: VeraAssets.wallet,
                  label: 'Card',
                  onTap: () => context.go('/card'),
                ),
                VeraListRow(
                  icon: VeraAssets.person,
                  label: 'Account',
                  onTap: () => context.go('/account'),
                ),
                VeraListRow(
                  icon: VeraAssets.inbox,
                  label: 'Inbox',
                  onTap: () => context.push('/inbox'),
                ),
                VeraListRow(
                  icon: VeraAssets.bell,
                  label: 'Notifications',
                  onTap: () => context.go('/notifications'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning',
          style: context.type.p2.copyWith(color: colors.textSecondary),
        ),
        Text(MockData.userName, style: context.type.h3),
      ],
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});

  final VeraTransaction txn;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final credit = txn.kind == TxnKind.repayment || txn.kind == TxnKind.refund;
    final amount = txn.amount;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          VeraSvg(_icon(txn.kind), size: 24, color: colors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.title, style: context.type.h4),
                Text(txn.date, style: context.type.p2),
              ],
            ),
          ),
          if (amount != null)
            Text(
              '${credit ? '+' : '-'}${formatMoney(amount)}',
              style: context.type.h4.copyWith(
                color: credit ? colors.success : colors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

String _icon(TxnKind kind) => switch (kind) {
  TxnKind.purchase => VeraAssets.purchase,
  TxnKind.repayment => VeraAssets.repayment,
  TxnKind.refund => VeraAssets.refund,
  TxnKind.earn => VeraAssets.rewardsEarned,
  TxnKind.redeem => VeraAssets.rewardsRedeemed,
};
