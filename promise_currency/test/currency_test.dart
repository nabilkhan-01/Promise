import 'package:promise_currency/promise_currency.dart';
import 'package:test/test.dart';

void main() {
  group('IsoCurrencyCatalogue Tests', () {
    test('catalogue is non-empty and all codes are uppercase and unique', () {
      expect(IsoCurrencyCatalogue.currencies, isNotEmpty);
      final codes = <String>{};

      for (var currency in IsoCurrencyCatalogue.currencies) {
        expect(currency.code.length, equals(3));
        expect(currency.code, equals(currency.code.toUpperCase()));
        expect(
          codes.contains(currency.code),
          isFalse,
          reason: 'Duplicate currency code: ${currency.code}',
        );
        codes.add(currency.code);

        expect(currency.name, isNotEmpty);
        expect(currency.symbol, isNotEmpty);
        expect(currency.decimals, isIn([0, 2, 3]));
        expect(currency.countries, isNotEmpty);
      }
    });

    test('retrieves currency by code case-insensitively', () {
      final usd = IsoCurrencyCatalogue.findByCode('usd');
      expect(usd, isNotNull);
      expect(usd!.code, equals('USD'));
      expect(usd.decimals, equals(2));
      expect(usd.symbol, equals('\$'));

      final bhd = IsoCurrencyCatalogue.findByCode('BHD');
      expect(bhd, isNotNull);
      expect(bhd!.decimals, equals(3));

      final jpy = IsoCurrencyCatalogue.findByCode('jPy');
      expect(jpy, isNotNull);
      expect(jpy!.decimals, equals(0));
    });

    test(
      'validates active currency codes and rejects invalid or null codes',
      () {
        expect(IsoCurrencyCatalogue.isValidCode('USD'), isTrue);
        expect(IsoCurrencyCatalogue.isValidCode('EUR'), isTrue);
        expect(IsoCurrencyCatalogue.isValidCode('JPY'), isTrue);
        expect(IsoCurrencyCatalogue.isValidCode('BHD'), isTrue);

        expect(IsoCurrencyCatalogue.isValidCode(null), isFalse);
        expect(IsoCurrencyCatalogue.isValidCode(''), isFalse);
        expect(IsoCurrencyCatalogue.isValidCode('XYZ123'), isFalse);
      },
    );

    test('rejects historical, fund, commodity, crypto, and SDR codes', () {
      for (var excluded in IsoCurrencyCatalogue.excludedCodes) {
        expect(
          IsoCurrencyCatalogue.isValidCode(excluded),
          isFalse,
          reason: 'Excluded code should not be active: $excluded',
        );
      }
    });

    test('searches currencies by code, name, and country', () {
      final dollarResults = IsoCurrencyCatalogue.search('dollar');
      expect(dollarResults, isNotEmpty);
      expect(dollarResults.any((c) => c.code == 'USD'), isTrue);
      expect(dollarResults.any((c) => c.code == 'AUD'), isTrue);

      final ecuadorResults = IsoCurrencyCatalogue.search('Ecuador');
      expect(ecuadorResults, isNotEmpty);
      expect(ecuadorResults.first.code, equals('USD'));

      final euroResults = IsoCurrencyCatalogue.search('Euro');
      expect(euroResults, isNotEmpty);
      expect(euroResults.any((c) => c.code == 'EUR'), isTrue);
    });
  });

  group('CurrencyUtils Exact Parsing Tests', () {
    test('parses USD amounts correctly without floating point arithmetic', () {
      final usd = IsoCurrencyCatalogue.findByCode('USD')!;

      expect(CurrencyUtils.parseToMinorUnits('100.50', usd), equals(10050));
      expect(CurrencyUtils.parseToMinorUnits('100.5', usd), equals(10050));
      expect(CurrencyUtils.parseToMinorUnits('100', usd), equals(10000));
      expect(CurrencyUtils.parseToMinorUnits('0.01', usd), equals(1));
      expect(CurrencyUtils.parseToMinorUnits('1,234.56', usd), equals(123456));
      expect(CurrencyUtils.parseToMinorUnits('1000', usd), equals(100000));
    });

    test('parses 0-decimal JPY amounts correctly', () {
      final jpy = IsoCurrencyCatalogue.findByCode('JPY')!;

      expect(CurrencyUtils.parseToMinorUnits('1000', jpy), equals(1000));
      expect(CurrencyUtils.parseToMinorUnits('1,000', jpy), equals(1000));
      expect(CurrencyUtils.parseToMinorUnits('50000', jpy), equals(50000));
    });

    test('parses 3-decimal KWD and BHD amounts correctly', () {
      final kwd = IsoCurrencyCatalogue.findByCode('KWD')!;
      final bhd = IsoCurrencyCatalogue.findByCode('BHD')!;

      expect(CurrencyUtils.parseToMinorUnits('10.500', kwd), equals(10500));
      expect(CurrencyUtils.parseToMinorUnits('10.5', kwd), equals(10500));
      expect(CurrencyUtils.parseToMinorUnits('0.001', kwd), equals(1));
      expect(CurrencyUtils.parseToMinorUnits('12.345', bhd), equals(12345));
    });

    test('rejects excess decimal precision for currency', () {
      final usd = IsoCurrencyCatalogue.findByCode('USD')!;
      final jpy = IsoCurrencyCatalogue.findByCode('JPY')!;

      expect(
        () => CurrencyUtils.parseToMinorUnits('100.500', usd),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('exceeds decimal precision'),
          ),
        ),
      );

      expect(
        () => CurrencyUtils.parseToMinorUnits('10.5', jpy),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('exceeds decimal precision'),
          ),
        ),
      );
    });

    test(
      'rejects malformed, negative, zero (when prohibited), and overflow inputs',
      () {
        final usd = IsoCurrencyCatalogue.findByCode('USD')!;

        expect(
          () => CurrencyUtils.parseToMinorUnits('-50.00', usd),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot be negative'),
            ),
          ),
        );

        expect(
          () => CurrencyUtils.parseToMinorUnits('0.00', usd, allowZero: false),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be greater than zero'),
            ),
          ),
        );

        expect(
          CurrencyUtils.parseToMinorUnits('0.00', usd, allowZero: true),
          equals(0),
        );

        expect(
          () => CurrencyUtils.parseToMinorUnits('abc', usd),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => CurrencyUtils.parseToMinorUnits('1.2.3', usd),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => CurrencyUtils.parseToMinorUnits('99999999999999', usd),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('exceeds maximum permitted per-record limit'),
            ),
          ),
        );
      },
    );
  });

  group('CurrencyUtils Exact Formatting Tests', () {
    test(
      'formats 2-decimal currencies deterministically without float math',
      () {
        final usd = IsoCurrencyCatalogue.findByCode('USD')!;

        expect(CurrencyUtils.formatMinorUnits(10050, usd), equals('\$100.50'));
        expect(
          CurrencyUtils.formatMinorUnits(10050, usd, includeCode: true),
          equals('\$100.50 USD'),
        );
        expect(
          CurrencyUtils.formatMinorUnits(10050, usd, includeSymbol: false),
          equals('100.50'),
        );
        expect(CurrencyUtils.formatMajorUnits(10050, usd), equals('100.50'));
        expect(CurrencyUtils.formatMinorUnits(1, usd), equals('\$0.01'));
        expect(
          CurrencyUtils.formatMinorUnits(123456789, usd),
          equals('\$1,234,567.89'),
        );
      },
    );

    test('formats 0-decimal JPY currency deterministically', () {
      final jpy = IsoCurrencyCatalogue.findByCode('JPY')!;

      expect(CurrencyUtils.formatMinorUnits(1000, jpy), equals('¥1,000'));
      expect(CurrencyUtils.formatMajorUnits(1000, jpy), equals('1,000'));
    });

    test('formats 3-decimal BHD and KWD currencies deterministically', () {
      final bhd = IsoCurrencyCatalogue.findByCode('BHD')!;

      expect(CurrencyUtils.formatMinorUnits(10500, bhd), equals('BD10.500'));
      expect(CurrencyUtils.formatMajorUnits(10500, bhd), equals('10.500'));
      expect(CurrencyUtils.formatMinorUnits(1, bhd), equals('BD0.001'));
    });
  });

  group('Backend & Shared Validation Integration Tests', () {
    test(
      'validateCurrencyCode approves active codes and rejects invalid codes',
      () {
        final usd = CurrencyUtils.validateCurrencyCode('USD');
        expect(usd.code, equals('USD'));

        final eur = CurrencyUtils.validateCurrencyCode('eur');
        expect(eur.code, equals('EUR'));

        expect(
          () => CurrencyUtils.validateCurrencyCode('INVALID'),
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
      },
    );
  });
}
