enum TxnKind { purchase, repayment, refund, earn, redeem }

class VeraTransaction {
  const VeraTransaction({
    required this.title,
    required this.date,
    required this.kind,
    this.amount,
    this.points,
  });

  final String title;
  final String date;
  final TxnKind kind;
  final double? amount;
  final int? points;
}

abstract final class MockData {
  static const String userName = 'Sandeep Sachdeva';
  static const String initials = 'SS';
  static const String joined = 'Joined Jan 2024';
  static const int inboxCount = 2;
  static const String cardPan = '4522 • • • • • • • • 9031';
  static const String cardFirst4 = '4522';
  static const String cardLast4 = '9031';
  static const String cardCvv = '341';
  static const String cardExpiry = '09/28';
  static const double currentBalance = 4500.88;
  static const double availableCredit = 15550.88;
  static const double creditLimit = 20051.76;
  static const double statementBalance = 2450.50;
  static const double minDue = 931;
  static const double paidThisPeriod = 125;
  static const String paymentDueDate = 'Jul 15';
  static const String paymentDueDateFull = 'Jul 15 2025';
  static const int rewardsPoints = 9102;
  static const String programName = 'Omni';
  static const String programSubtitle = 'Universal Rewards';

  static const List<VeraTransaction> homeTransactions = [
    VeraTransaction(
      title: 'Amazon',
      date: 'Jul 5, 2025',
      kind: TxnKind.purchase,
      amount: 542.89,
    ),
    VeraTransaction(
      title: 'Starbucks',
      date: 'Jul 5, 2025',
      kind: TxnKind.purchase,
      amount: 542.89,
    ),
    VeraTransaction(
      title: 'Delta Airlines',
      date: 'Jul 5, 2025',
      kind: TxnKind.purchase,
      amount: 542.89,
    ),
    VeraTransaction(
      title: 'Repayment',
      date: 'Jul 5, 2025',
      kind: TxnKind.repayment,
      amount: 542.89,
    ),
    VeraTransaction(
      title: 'Refund Amazon',
      date: 'Jul 5, 2025',
      kind: TxnKind.refund,
      amount: 542.89,
    ),
  ];

  static const List<VeraTransaction> rewardsStatement = [
    VeraTransaction(
      title: 'Amazon',
      date: 'Jul 5',
      kind: TxnKind.earn,
      points: 2,
    ),
    VeraTransaction(
      title: 'Starbucks',
      date: 'Jul 2',
      kind: TxnKind.earn,
      points: 7,
    ),
    VeraTransaction(
      title: 'Delta Airlines',
      date: 'Jun 29',
      kind: TxnKind.earn,
      points: 43,
    ),
  ];
}
