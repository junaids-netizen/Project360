/// Groups a positive whole-dollar amount with thousands separators.
String formatMoney(double value) {
  final negative = value < 0;
  final abs = value.abs();
  final whole = abs.truncate();
  final cents = ((abs - whole) * 100).round().toString().padLeft(2, '0');
  return '${negative ? '-' : ''}\$${_group(whole)}.$cents';
}

String _group(int whole) {
  final digits = whole.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Space under tab content so the floating tab bar does not cover the last row.
double bankTabBottomInset(double safeBottom) => safeBottom + 108;
