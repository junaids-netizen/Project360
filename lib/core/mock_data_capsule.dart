enum CapsuleTxnStatus { pending, declined }

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

  static const double familyUsed = 3100;
  static const double familyAvailable = 4000;
  static const double familyPaymentAmount = 100;

  static const List<CapsuleFamilyMember> familyMembers = [
    CapsuleFamilyMember(
      name: 'Zack',
      avatarAsset: 'assets/images/360/avatar_zack.png',
    ),
    CapsuleFamilyMember(
      name: 'Rachel',
      avatarAsset: 'assets/images/360/avatar_rachel.png',
    ),
    CapsuleFamilyMember(
      name: 'Mike',
      avatarAsset: 'assets/images/360/avatar_mike.png',
    ),
    CapsuleFamilyMember(
      name: 'Olivia',
      avatarAsset: 'assets/images/360/avatar_olivia.png',
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

  static const List<String> scoreChartMonths = [
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
    'J',
    'F',
    'M',
    'A',
  ];

  static const List<String> scoreTimeframes = [
    '3M',
    '6M',
    '1Y',
    '3Y',
    '5Y',
    'ALL',
  ];
}
