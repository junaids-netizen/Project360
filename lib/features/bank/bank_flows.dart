import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/bank/bank_format.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  var _paid = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return _FlowPage(
      title: 'Pay',
      children: [
        Text(
          'Statement balance',
          style: context.type.p1.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        VeraDentonAmount(
          dollars: _whole(MockData.statementBalance),
          cents: _cents(MockData.statementBalance),
        ),
        const SizedBox(height: 8),
        Text(
          'Minimum due ${formatMoney(MockData.minDue)} · due ${MockData.paymentDueDate}',
          style: context.type.p2.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 24),
        if (_paid)
          VeraCapsule(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                VeraSvg(
                  VeraAssets.checkCircle,
                  size: 24,
                  color: colors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment of ${formatMoney(MockData.statementBalance)} is scheduled.',
                    style: context.type.h4,
                  ),
                ),
              ],
            ),
          )
        else
          VeraPrimaryButton(
            label: 'Pay ${formatMoney(MockData.statementBalance)}',
            width: double.infinity,
            height: 48,
            onTap: Haptics.wrap(() => setState(() => _paid = true)),
          ),
      ],
    );
  }
}

class AddAuthorizedUserScreen extends StatefulWidget {
  const AddAuthorizedUserScreen({super.key});

  @override
  State<AddAuthorizedUserScreen> createState() =>
      _AddAuthorizedUserScreenState();
}

class _AddAuthorizedUserScreenState extends State<AddAuthorizedUserScreen> {
  final _name = TextEditingController();
  var _added = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return _FlowPage(
      title: 'Authorized user',
      children: [
        Text(
          'They get a card on this account. You stay the primary.',
          style: context.type.p1.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (_added)
          VeraCapsule(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_name.text.trim()} is added. Their card ships to the address on file.',
              style: context.type.h4,
            ),
          )
        else ...[
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            style: context.type.h4,
            decoration: InputDecoration(
              labelText: 'Full name',
              filled: true,
              fillColor: colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
          const SizedBox(height: 16),
          VeraPrimaryButton(
            label: 'Add user',
            width: double.infinity,
            height: 48,
            onTap: Haptics.wrap(() {
              if (_name.text.trim().isEmpty) return;
              setState(() => _added = true);
            }),
          ),
        ],
      ],
    );
  }
}

class ReplaceCardScreen extends StatelessWidget {
  const ReplaceCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return _FlowPage(
      title: 'Replace card',
      children: [
        Text(
          'We will cancel ${MockData.cardLast4} and mail a new card to the address on file.',
          style: context.type.p1.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 24),
        VeraPrimaryButton(
          label: 'Send replacement',
          width: double.infinity,
          height: 48,
          onTap: Haptics.wrap(() => context.push('/card/received')),
        ),
      ],
    );
  }
}

class CardReceivedPromptScreen extends StatelessWidget {
  const CardReceivedPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return _FlowPage(
      title: 'New card',
      children: [
        Text('Has the new card arrived?', style: context.type.h3),
        const SizedBox(height: 8),
        Text(
          'Activation needs the three-digit code on the back.',
          style: context.type.p1.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 24),
        VeraPrimaryButton(
          label: 'Yes, activate',
          width: double.infinity,
          height: 48,
          onTap: Haptics.wrap(() => context.push('/card/cvc')),
        ),
      ],
    );
  }
}

class CardActivateCvcScreen extends StatefulWidget {
  const CardActivateCvcScreen({super.key});

  @override
  State<CardActivateCvcScreen> createState() => _CardActivateCvcScreenState();
}

class _CardActivateCvcScreenState extends State<CardActivateCvcScreen> {
  final _cvc = TextEditingController();

  @override
  void dispose() {
    _cvc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return _FlowPage(
      title: 'Activate',
      children: [
        Text(
          'Enter the code on the back of the card ending ${MockData.cardLast4}.',
          style: context.type.p1.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _cvc,
          keyboardType: TextInputType.number,
          maxLength: 3,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: context.type.h3,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            counterText: '',
            labelText: 'CVC',
            filled: true,
            fillColor: colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),
        VeraPrimaryButton(
          label: 'Activate',
          width: double.infinity,
          height: 48,
          onTap: _cvc.text.length == 3
              ? Haptics.wrap(() => context.push('/card/ready'))
              : null,
        ),
      ],
    );
  }
}

class CardReadyScreen extends StatelessWidget {
  const CardReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return _FlowPage(
      title: 'Card ready',
      children: [
        VeraSvg(VeraAssets.checkCircle, size: 36, color: colors.success),
        const SizedBox(height: 12),
        Text('Your card is ready to use.', style: context.type.h3),
        const SizedBox(height: 8),
        Text(
          'Wallets and in-store purchases work as soon as the merchant asks.',
          style: context.type.p1.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 24),
        VeraPrimaryButton(
          label: 'Done',
          width: double.infinity,
          height: 48,
          onTap: Haptics.wrap(() => context.go('/card')),
        ),
      ],
    );
  }
}

class _FlowPage extends StatelessWidget {
  const _FlowPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        child: Column(
          children: [
            VeraToolbar(
              title: title,
              showTrailing: false,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _whole(double value) {
  final text = formatMoney(value);
  final body = text.startsWith('\$') ? text.substring(1) : text;
  return body.split('.').first;
}

String _cents(double value) {
  final text = formatMoney(value);
  return text.substring(text.lastIndexOf('.'));
}
