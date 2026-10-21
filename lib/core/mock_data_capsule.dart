import 'dart:math' as math;

import 'package:project360/core/widgets/three_sixty_assets.dart';

enum CapsuleTxnStatus { pending, declined }

/// One monthly credit-score reading (always the first day of the month).
class CreditScorePoint {
  const CreditScorePoint({required this.month, required this.score});

  final DateTime month;
  final int score;
}

/// Downsampled series for the credit-health history chart (12 columns).
class CreditScoreChartSeries {
  const CreditScoreChartSeries({
    required this.scores,
    required this.axisLabels,
    required this.latestScore,
    required this.periodStartScore,
  });

  final List<int> scores;
  final List<String> axisLabels;
  final int latestScore;
  final int periodStartScore;

  int get delta => latestScore - periodStartScore;
}

class CapsuleTransaction {
  const CapsuleTransaction({
    required this.merchant,
    required this.date,
    required this.time,
    required this.amount,
    required this.cashback,
    this.status,
  });

  final String merchant;
  final String date;
  final String time;
  final double amount;
  final double cashback;
  final CapsuleTxnStatus? status;
}

class CapsuleFamilyMember {
  const CapsuleFamilyMember({required this.name, required this.avatarAsset});

  final String name;
  final String avatarAsset;
}

class CreditInsight {
  const CreditInsight({required this.title, required this.body});

  final String title;
  final String body;
}

abstract final class MockDataCapsule {
  static const String cardholderName = 'Zack';
  static const String cardLast4 = '4192';
  static const double amountUsed = 100;
  static const double amountAvailable = 4900;
  static const double dueAmount = 100;
  static const double minimumDue = 35;
  static const String payBadgeLabel = '3D LEFT';

  static const int creditScore = 784;
  static const int creditScoreMin = 300;
  static const int creditScoreMax = 850;
  static const String creditHeadline = 'Perfect run';
  static const String creditSubline =
      'Your credit score has increased by 25 points';

  /// Credit Health dial center tap (Figma node 46:6401).
  static const int creditClaimDialScore = 769;
  static const String creditClaimHeadline = 'Claim them back';
  static const String creditClaimSubline =
      'Your credit score has decreased by 25 points. See the report to claim them back.';

  /// Credit Health insights list (Figma node 46:6252).
  static const List<CreditInsight> creditInsights = [
    CreditInsight(
      title: 'Don’t miss payments',
      body:
          'Paying on-time is generally the most important factor in achieving a high score.',
    ),
    CreditInsight(
      title: 'Keep accounts open',
      body:
          'Even if you don’t use them, building a longer credit history is a good thing.',
    ),
    CreditInsight(
      title: 'Optimize your balance',
      body:
          'A high balance is good for us, but bad for you. Try your best to not use your entire credit line.',
    ),
    CreditInsight(
      title: 'Regularly monitor your score',
      body:
          'You will see what is working and be able to detect suspicious changes.',
    ),
    CreditInsight(
      title: 'Build your credit file',
      body:
          'Show lenders that you responsibly make payments on multiple types of loans.',
    ),
  ];

  static const String creditVantageDisclaimer =
      'We provide your VantageScore for educational purposes only. PNC is not '
      'responsible for calculating this score. If you believe there is an error '
      'with your score or any of your credit report information, you should '
      'contact TransUnion.\n\n'
      'Please refer to your Credit Report Authorization for complete terms and '
      'conditions.';

  static const double familyUsed = 3100;
  static const double familyAvailable = 4000;
  static const double familyPaymentAmount = 100;

  static const List<CapsuleFamilyMember> familyMembers = [
    CapsuleFamilyMember(name: 'Zack', avatarAsset: ThreeSixtyAssets.avatarZack),
    CapsuleFamilyMember(
      name: 'Rachel',
      avatarAsset: ThreeSixtyAssets.avatarRachel,
    ),
    CapsuleFamilyMember(name: 'Mike', avatarAsset: ThreeSixtyAssets.avatarMike),
    CapsuleFamilyMember(
      name: 'Olivia',
      avatarAsset: ThreeSixtyAssets.avatarOlivia,
    ),
  ];

  static const List<CapsuleTransaction> familyTransactions = [
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 0,
      status: CapsuleTxnStatus.pending,
    ),
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 0,
      status: CapsuleTxnStatus.declined,
    ),
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 0,
    ),
  ];

  static const List<CapsuleTransaction> recentTransactions = [
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 7.69,
    ),
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 7.69,
    ),
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 7.69,
    ),
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 7.69,
    ),
    CapsuleTransaction(
      merchant: 'Uber',
      date: 'Jul 5, 2024',
      time: '12:56 PM',
      amount: 350,
      cashback: 7.69,
    ),
  ];

  static const List<String> scoreTimeframes = [
    '3M',
    '6M',
    '1Y',
    '3Y',
    '5Y',
    'ALL',
  ];

  /// Anchor month for mock history (matches app "today" in demos).
  static final DateTime creditScoreAnchorMonth = DateTime(2026, 10, 1);

  /// Ten years of monthly scores ending at [creditScoreAnchorMonth].
  static final List<CreditScorePoint> creditScoreHistory =
      _generateCreditScoreHistory();

  static CreditScoreChartSeries chartSeriesForTimeframeIndex(int index) {
    final label = scoreTimeframes[index.clamp(0, scoreTimeframes.length - 1)];
    return chartSeriesForTimeframe(label);
  }

  static int monthsForTimeframeIndex(int index) {
    final label = scoreTimeframes[index.clamp(0, scoreTimeframes.length - 1)];
    return _monthsForTimeframe(label);
  }

  static String timeframeLabelForIndex(int index) {
    return scoreTimeframes[index.clamp(0, scoreTimeframes.length - 1)];
  }

  static CreditScoreChartSeries chartSeriesForTimeframe(String timeframe) {
    final months = _monthsForTimeframe(timeframe);
    final slice = _sliceLastMonths(months);
    return _downsampleToChart(slice, timeframe);
  }

  static int _monthsForTimeframe(String timeframe) {
    return switch (timeframe) {
      '3M' => 3,
      '6M' => 6,
      '1Y' => 12,
      '3Y' => 36,
      '5Y' => 60,
      'ALL' => creditScoreHistory.length,
      _ => 12,
    };
  }

  static List<CreditScorePoint> _sliceLastMonths(int monthCount) {
    final n = monthCount.clamp(1, creditScoreHistory.length);
    return creditScoreHistory.sublist(creditScoreHistory.length - n);
  }

  static CreditScoreChartSeries _downsampleToChart(
    List<CreditScorePoint> points,
    String timeframe,
  ) {
    const columns = 12;
    if (points.isEmpty) {
      return CreditScoreChartSeries(
        scores: List.filled(columns, creditScore),
        axisLabels: List.filled(columns, ''),
        latestScore: creditScore,
        periodStartScore: creditScore,
      );
    }

    if (points.length <= columns) {
      return CreditScoreChartSeries(
        scores: [for (final p in points) p.score],
        axisLabels: [
          for (var i = 0; i < points.length; i++)
            _axisLabel(points[i].month, timeframe, i, points.length),
        ],
        latestScore: points.last.score,
        periodStartScore: points.first.score,
      );
    }

    final scores = <int>[];
    final labels = <String>[];
    final lastIndex = points.length - 1;

    for (var col = 0; col < columns; col++) {
      final t = col / (columns - 1);
      final sourceIndex = (t * lastIndex).round().clamp(0, lastIndex);
      final point = points[sourceIndex];
      scores.add(point.score);
      labels.add(_axisLabel(point.month, timeframe, col, columns));
    }

    return CreditScoreChartSeries(
      scores: scores,
      axisLabels: labels,
      latestScore: points.last.score,
      periodStartScore: points.first.score,
    );
  }

  static String _axisLabel(
    DateTime month,
    String timeframe,
    int columnIndex,
    int columnCount,
  ) {
    if (timeframe == 'ALL' || timeframe == '5Y' || timeframe == '3Y') {
      // Avoid clutter: show ~6 year labels on long ranges.
      final showEvery = timeframe == 'ALL'
          ? 2
          : timeframe == '5Y'
              ? 1
              : 2;
      if (columnIndex % showEvery != 0 && columnIndex != columnCount - 1) {
        return '';
      }
      final year = month.year % 100;
      return "'${year.toString().padLeft(2, '0')}";
    }

    const monthLetters = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return monthLetters[month.month - 1];
  }

  static List<CreditScorePoint> _generateCreditScoreHistory() {
    const years = 10;
    const totalMonths = years * 12;
    final anchor = creditScoreAnchorMonth;
    final rng = math.Random(3604192);

    // Last 12 months tuned to match the Credit Health frame polyline (~650–845).
    const lastYearScores = [
      758,
      804,
      764,
      804,
      665,
      779,
      764,
      845,
      702,
      791,
      674,
      784,
    ];

    final scores = List<int>.filled(totalMonths, 720);

    for (var i = 0; i < totalMonths - 12; i++) {
      final prev = i == 0 ? 718 : scores[i - 1];
      final drift = (rng.nextDouble() - 0.48) * 14;
      final meanRevert = (752 - prev) * 0.06;
      scores[i] = (prev + drift + meanRevert).round().clamp(620, 820);
    }

    for (var i = 0; i < 12; i++) {
      scores[totalMonths - 12 + i] = lastYearScores[i];
    }

    scores[totalMonths - 1] = creditScore;

    return [
      for (var i = 0; i < totalMonths; i++)
        CreditScorePoint(
          month: DateTime(anchor.year, anchor.month - (totalMonths - 1 - i), 1),
          score: scores[i],
        ),
    ];
  }
}
