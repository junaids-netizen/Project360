import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';

/// Card home: balances, the card, pay, and recent transactions.
///
/// The toolbar lives entirely in the safe area. The account name is not drawn
/// into the status bar, and Back is plain text — no underline.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  VeraSpacing.page,
                  VeraSpacing.s4,
                  VeraSpacing.page,
                  bottom + VeraSpacing.s24,
                ),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: const [
                  _HomeToolbar(),
                  SizedBox(height: VeraSpacing.s12),
                  _BalanceHeader(),
                  SizedBox(height: VeraSpacing.s20),
                  VeraCardFace(height: 160, showCvv: true),
                  SizedBox(height: VeraSpacing.s16),
                  _PayButton(),
                  SizedBox(height: VeraSpacing.s12),
                  _Transactions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeToolbar extends StatelessWidget {
  const _HomeToolbar();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final backStyle = context.type.h4.copyWith(
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.none,
    );

    return SizedBox(
      height: 44,
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          key: const Key('home-back'),
          behavior: HitTestBehavior.opaque,
          onTap: Haptics.wrap(() => Navigator.of(context).maybePop()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VeraSvg(VeraAssets.back, size: 24, color: colors.textPrimary),
              const SizedBox(width: VeraSpacing.s4),
              Text('Back', style: backStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final current = _splitMoney(MockData.currentBalance);
    final available = _splitMoney(MockData.availableCredit);
    final wholeStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w700,
      fontSize: 40,
      height: 1,
    );
    final dollarStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w700,
      fontSize: 30,
      height: 1,
    );
    final wholeWidth = _textWidth(current.whole, wholeStyle);
    final dollarWidth = _textWidth('\$', dollarStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: VeraSplitAmount(
                  whole: current.whole,
                  cents: current.cents,
                  large: true,
                ),
              ),
            ),
            const SizedBox(width: VeraSpacing.s8),
            FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: VeraSplitAmount(
                whole: available.whole,
                cents: available.cents,
                large: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: VeraSpacing.s8),
        Container(
          margin: EdgeInsets.only(left: dollarWidth + 2),
          width: wholeWidth,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(colors: colors.progressGradient),
          ),
        ),
        const SizedBox(height: VeraSpacing.s8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Current Balance',
                style: context.type.p1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Available Credit',
              style: context.type.p1,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton();

  @override
  Widget build(BuildContext context) {
    return VeraPrimaryButton(
      label: 'Pay now',
      width: double.infinity,
      height: 40,
      onTap: Haptics.wrap(() {}),
    );
  }
}

class _Transactions extends StatelessWidget {
  const _Transactions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: VeraSpacing.s12),
          child: Text('Transactions', style: context.type.h3),
        ),
        VeraCapsule(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final txn in MockData.homeTransactions) _TxnRow(txn: txn),
            ],
          ),
        ),
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
              _signedMoney(amount, credit: credit),
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

class _MoneyParts {
  const _MoneyParts(this.whole, this.cents);

  final String whole;
  final String cents;
}

_MoneyParts _splitMoney(double value) {
  final fixed = value.abs().toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final digits = fixed.substring(0, dot);
  final cents = fixed.substring(dot);
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return _MoneyParts(buf.toString(), cents);
}

String _signedMoney(double amount, {required bool credit}) {
  final parts = _splitMoney(amount);
  return '${credit ? '+' : '-'}\$${parts.whole}${parts.cents}';
}

double _textWidth(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width;
}
