import 'package:flutter_test/flutter_test.dart';
import 'package:project360/features/pitch/bank_url.dart';

void main() {
  test('accepts https and upgrades a bare host or http', () {
    expect(
      parseBankUrl('https://www.Chase.com/cards')?.toString(),
      'https://www.chase.com/cards',
    );
    expect(parseBankUrl('bank.example')?.toString(), 'https://bank.example');
    expect(
      parseBankUrl('http://bank.example/a?b=1')?.toString(),
      'https://bank.example/a?b=1',
    );
    expect(
      parseBankUrl('  //bank.example/path  ')?.toString(),
      'https://bank.example/path',
    );
  });

  test('rejects values that are not a website url', () {
    expect(parseBankUrl(''), isNull);
    expect(parseBankUrl('   '), isNull);
    expect(parseBankUrl('not a url'), isNull);
    expect(parseBankUrl('chase'), isNull);
    expect(parseBankUrl('https://'), isNull);
    expect(parseBankUrl('https://chase'), isNull);
    expect(parseBankUrl('ftp://bank.example'), isNull);
    expect(parseBankUrl('javascript:alert(1)'), isNull);
    expect(parseBankUrl('file:///etc/passwd'), isNull);
  });

  test('display host drops a leading www', () {
    expect(
      displayHost(Uri.parse('https://www.Bank.Example/x')),
      'bank.example',
    );
    expect(displayHost(Uri.parse('https://bank.example')), 'bank.example');
  });
}
