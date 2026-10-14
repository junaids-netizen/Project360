String groupedInt(int value) {
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return buf.toString();
}

String signedMoney(double amount, {required bool credit}) {
  final fixed = amount.abs().toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final whole = groupedInt(int.parse(fixed.substring(0, dot)));
  return '${credit ? '+' : '-'}\$$whole${fixed.substring(dot)}';
}
