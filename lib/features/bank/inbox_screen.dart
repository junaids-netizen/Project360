import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/bank/bank_format.dart';

class _Note {
  const _Note(this.title, this.body, this.when);

  final String title;
  final String body;
  final String when;
}

const _notes = [
  _Note(
    'Payment posted',
    'Your payment of \$125.00 was applied to this statement.',
    'Today',
  ),
  _Note(
    'Card on the way',
    'A replacement card shipped to the address on file.',
    'Yesterday',
  ),
  _Note('Points earned', 'Delta Airlines added 43 points to Omni.', 'Jul 5'),
];

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = bankTabBottomInset(MediaQuery.paddingOf(context).bottom);

    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
        children: [
          Text('Notifications', style: context.type.h2),
          const SizedBox(height: 8),
          Text(
            'Account messages for this bank.',
            style: context.type.p1.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final note in _notes) ...[
            VeraCapsule(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VeraSvg(VeraAssets.bell, size: 24, color: colors.textPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(note.title, style: context.type.h4),
                            ),
                            Text(note.when, style: context.type.p2),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(note.body, style: context.type.p1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
