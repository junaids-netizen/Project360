import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/home/bank_format.dart';
import 'package:project360/features/home/bank_shell.dart';

/// Home as it ships: card on top, balance sitting on the card, payment due,
/// rewards, and transactions. Nothing is drawn into the status bar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenRewards});

  final VoidCallback? onOpenRewards;

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
              VeraSpacing.s8,
              VeraSpacing.page,
              bottom,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: _InboxButton(),
              ),
              const SizedBox(height: VeraSpacing.s12),
              const _CardAndBalance(),
              const SizedBox(height: VeraSpacing.s8),
              BankSectionHeader(
                title: 'Payment due',
                suffix: 'by ${MockData.paymentDueDate}',
              ),
              const _MinDueCard(),
              const SizedBox(height: VeraSpacing.s8),
              BankSectionHeader(
                title: 'Rewards',
                showChevron: true,
                onTap: onOpenRewards,
              ),
              const _RewardsSummary(),
              const SizedBox(height: VeraSpacing.s8),
              const BankSectionHeader(
                title: 'Transactions',
                showChevron: true,
              ),
              const _TransactionList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxButton extends StatelessWidget {
  const _InboxButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: VeraSvg(
                VeraAssets.inbox,
                size: 22,
                color: colors.textPrimary,
              ),
            ),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.badge,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${MockData.inboxCount}',
                style: TextStyle(
                  fontFamily: VeraTypography.geist,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1,
                  color: colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardAndBalance extends StatelessWidget {
  const _CardAndBalance();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 92),
          child: VeraCardFace(
            height: 156,
            revealed: false,
            showCvv: true,
            showSettings: false,
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 0,
          child: _BalanceCard(),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final current = groupedInt(MockData.currentBalance.round());
    final available = groupedInt(MockData.availableCredit.round());
    final wholeStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w700,
      fontSize: 40,
      height: 1,
    );
    final barWidth = _textWidth(current, wholeStyle);

    return VeraCapsule(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VeraSplitAmount(
                        whole: current,
                        cents: '',
                        large: true,
                        showCents: false,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: barWidth,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: colors.progressGradient,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: VeraSpacing.s8),
              VeraSplitAmount(
                whole: available,
                cents: '',
                large: false,
                showCents: false,
              ),
            ],
          ),
          const SizedBox(height: VeraSpacing.s8),
          Row(
            children: [
              Expanded(
                child: Text('Current Balance', style: context.type.p1),
              ),
              Text('Available Credit', style: context.type.p1),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinDueCard extends StatelessWidget {
  const _MinDueCard();

  @override
  Widget build(BuildContext context) {
    final due = groupedInt(MockData.minDue.round());
    return VeraCapsule(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  VeraSplitAmount(
                    whole: due,
                    cents: '',
                    large: true,
                    showCents: false,
                  ),
                  const SizedBox(width: VeraSpacing.s8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Min Due', style: context.type.p1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: VeraSpacing.s12),
          VeraPrimaryButton(
            label: 'Pay now',
            width: 112,
            height: 40,
            onTap: Haptics.wrap(() {}),
          ),
        ],
      ),
    );
  }
}

class _RewardsSummary extends StatelessWidget {
  const _RewardsSummary();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final points = groupedInt(MockData.rewardsPoints);
    final number = TextStyle(
      fontFamily: VeraTypography.geist,
      fontWeight: FontWeight.w600,
      fontSize: 28,
      height: 1.1,
      letterSpacing: -0.56,
      color: colors.darkGradient[1],
    );

    return VeraCapsule(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const VeraSvg(VeraAssets.rewardsSparkle, size: 40),
          const SizedBox(width: VeraSpacing.s12),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: points, style: number),
                    TextSpan(
                      text: ' points',
                      style: number.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.darkGradient.last,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    return VeraCapsule(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final txn in MockData.homeTransactions) _TxnRow(txn: txn),
        ],
      ),
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
      height: 64,
      child: Row(
        children: [
          VeraSvg(_txnIcon(txn.kind), size: 24, color: colors.textPrimary),
          const SizedBox(width: VeraSpacing.s12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: context.type.h4,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(txn.date, style: context.type.p2),
              ],
            ),
          ),
          if (amount != null)
            Text(
              signedMoney(amount, credit: credit),
              style: context.type.h4.copyWith(
                color: credit ? colors.success : colors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

String _txnIcon(TxnKind kind) => switch (kind) {
  TxnKind.purchase => VeraAssets.purchase,
  TxnKind.repayment => VeraAssets.repayment,
  TxnKind.refund => VeraAssets.refund,
  TxnKind.earn => VeraAssets.rewardsEarned,
  TxnKind.redeem => VeraAssets.rewardsRedeemed,
};

double _textWidth(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width;
}
