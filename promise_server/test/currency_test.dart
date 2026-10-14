import 'package:promise_currency/promise_currency.dart';
import 'package:test/test.dart';

void main() {
  group('Server-Side Currency Integration Tests', () {
    test('server can access shared ISO currency catalogue', () {
      expect(IsoCurrencyCatalogue.currencies, isNotEmpty);
      final usd = IsoCurrencyCatalogue.findByCode('USD');
      expect(usd, isNotNull);
      expect(usd!.code, equals('USD'));
      expect(usd.decimals, equals(2));
    });

    test('server-side CurrencyUtils validates active currency codes', () {
      final eur = CurrencyUtils.validateCurrencyCode('EUR');
      expect(eur.code, equals('EUR'));
      expect(eur.decimals, equals(2));

      final jpy = CurrencyUtils.validateCurrencyCode('jpy');
      expect(jpy.code, equals('JPY'));
      expect(jpy.decimals, equals(0));

      final bhd = CurrencyUtils.validateCurrencyCode('BHD');
      expect(bhd.code, equals('BHD'));
      expect(bhd.decimals, equals(3));

      expect(
        () => CurrencyUtils.validateCurrencyCode('INVALID_CODE'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Unsupported or invalid currency code'),
          ),
        ),
      );

      expect(
        () => CurrencyUtils.validateCurrencyCode('BTC'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'server-side CurrencyUtils parses amounts into integer minor units',
      () {
        expect(
          CurrencyUtils.parseToMinorUnitsByCode('100.50', 'USD'),
          equals(10050),
        );

        expect(
          CurrencyUtils.parseToMinorUnitsByCode('1000', 'JPY'),
          equals(1000),
        );

        expect(
          CurrencyUtils.parseToMinorUnitsByCode('10.500', 'BHD'),
          equals(10500),
        );

        expect(
          () => CurrencyUtils.parseToMinorUnitsByCode('100.500', 'USD'),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'server-side CurrencyUtils formats integer minor units without float math',
      () {
        final usd = IsoCurrencyCatalogue.findByCode('USD')!;
        expect(CurrencyUtils.formatMinorUnits(10050, usd), equals('\$100.50'));

        final jpy = IsoCurrencyCatalogue.findByCode('JPY')!;
        expect(CurrencyUtils.formatMinorUnits(1000, jpy), equals('¥1,000'));

        final bhd = IsoCurrencyCatalogue.findByCode('BHD')!;
        expect(CurrencyUtils.formatMinorUnits(10500, bhd), equals('BD10.500'));
      },
    );
  });
}
