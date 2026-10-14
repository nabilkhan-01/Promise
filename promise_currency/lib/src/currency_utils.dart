import 'iso_currency.dart';
import 'iso_currency_catalogue.dart';

/// Exact monetary amount utilities using integer minor units.
///
/// Strictly avoids floating-point (`double`) types for parsing, storage,
/// comparison, arithmetic, or formatting to prevent precision loss.
class CurrencyUtils {
  /// Maximum permitted minor units per record (1,000,000,000,000 = 10^12).
  static const int maxPerRecordMinorUnits = 1000000000000;

  /// Validates a currency code against the active ISO 4217 catalogue.
  /// Throws [ArgumentError] if the code is invalid or unsupported.
  static IsoCurrency validateCurrencyCode(String? currencyCode) {
    if (currencyCode == null || currencyCode.trim().isEmpty) {
      throw ArgumentError('Currency code cannot be empty.');
    }

    final cleanCode = currencyCode.trim().toUpperCase();
    final currency = IsoCurrencyCatalogue.findByCode(cleanCode);

    if (currency == null) {
      throw ArgumentError(
        'Unsupported or invalid currency code: "$currencyCode". Must be an active ISO 4217 code.',
      );
    }

    return currency;
  }

  /// Converts an unambiguous decimal text amount (e.g., "100.50", "1000", "10.500")
  /// into integer minor units according to [currency]'s decimal precision.
  ///
  /// Strictly avoids double conversion. Throws [ArgumentError] on invalid formats,
  /// negative values (if [allowZero] is false or negative), excess decimal places,
  /// ambiguous separators, or overflow.
  static int parseToMinorUnits(
    String amountText,
    IsoCurrency currency, {
    bool allowZero = false,
    int? customMaxMinorUnits,
  }) {
    final cleanInput = amountText.trim();
    if (cleanInput.isEmpty) {
      throw ArgumentError('Amount text cannot be empty.');
    }

    // Check for negative sign
    if (cleanInput.startsWith('-')) {
      throw ArgumentError('Amount cannot be negative: "$amountText".');
    }

    // Remove internal spaces
    String text = cleanInput.replaceAll(' ', '');

    final commaCount = ','.allMatches(text).length;
    final dotCount = '.'.allMatches(text).length;

    // Reject multiple dots
    if (dotCount > 1) {
      throw ArgumentError(
        'Ambiguous or malformed number format: "$amountText".',
      );
    }

    // Handle 0-decimal currencies (e.g., JPY, KRW, VND, XAF, ISK)
    if (currency.decimals == 0) {
      if (dotCount == 0 && commaCount == 0) {
        // Pure integer string e.g. "1000"
      } else if (commaCount > 0 && dotCount == 0) {
        // e.g. "1,000" or "1,000,000" -> remove thousand commas
        text = text.replaceAll(',', '');
      } else if (dotCount == 1 && commaCount == 0) {
        // Check if dot is thousand separator e.g. "1.000" vs decimal "10.5"
        final parts = text.split('.');
        if (parts[1].length == 3 && parts[1] == '000') {
          text = parts[0] + parts[1];
        } else {
          throw ArgumentError(
            'Amount "$amountText" exceeds decimal precision (0) for ${currency.code}.',
          );
        }
      } else {
        throw ArgumentError(
          'Amount "$amountText" exceeds decimal precision (0) for ${currency.code}.',
        );
      }

      final digitRegExp = RegExp(r'^\d+$');
      if (!digitRegExp.hasMatch(text)) {
        throw ArgumentError('Invalid number format: "$amountText".');
      }

      final minorUnits = int.tryParse(text);
      if (minorUnits == null) {
        throw ArgumentError('Amount "$amountText" causes integer overflow.');
      }

      if (minorUnits < 0) {
        throw ArgumentError('Amount cannot be negative.');
      }
      if (minorUnits == 0 && !allowZero) {
        throw ArgumentError('Amount must be greater than zero.');
      }

      final effectiveMax = customMaxMinorUnits ?? maxPerRecordMinorUnits;
      if (minorUnits > effectiveMax) {
        throw ArgumentError(
          'Amount exceeds maximum permitted per-record limit ($effectiveMax minor units).',
        );
      }

      return minorUnits;
    }

    // Handle currencies with decimals > 0 (e.g. 2 or 3 decimals)
    if (commaCount > 0 && dotCount == 1) {
      // Standard format: 1,234.56 -> remove commas
      text = text.replaceAll(',', '');
    } else if (commaCount == 1 && dotCount == 0) {
      final parts = text.split(',');
      if (parts[1].length == currency.decimals) {
        // European style decimal separator: e.g. 1234,50 -> 1234.50
        text = '${parts[0]}.${parts[1]}';
      } else if (parts[1].length == 3 && currency.decimals == 2) {
        // e.g. 1,000 USD -> treat comma as thousand separator
        text = parts[0] + parts[1];
      } else {
        text = '${parts[0]}.${parts[1]}';
      }
    } else if (commaCount > 1 && dotCount == 0) {
      // e.g. 1,234,567 -> remove thousand commas
      text = text.replaceAll(',', '');
    }

    final parts = text.split('.');
    if (parts.length > 2) {
      throw ArgumentError(
        'Ambiguous or malformed number format: "$amountText".',
      );
    }

    final integerPart = parts[0];
    final fractionPart = parts.length == 2 ? parts[1] : '';

    // Validate integer digits
    final digitRegExp = RegExp(r'^\d+$');
    if (integerPart.isEmpty || !digitRegExp.hasMatch(integerPart)) {
      throw ArgumentError('Invalid number format: "$amountText".');
    }

    if (fractionPart.isNotEmpty && !digitRegExp.hasMatch(fractionPart)) {
      throw ArgumentError('Invalid fraction format: "$amountText".');
    }

    // Validate decimal precision
    if (fractionPart.length > currency.decimals) {
      throw ArgumentError(
        'Amount "$amountText" exceeds decimal precision (${currency.decimals}) for ${currency.code}.',
      );
    }

    // Pad fraction part to exact minor-unit decimal places
    final paddedFraction = fractionPart.padRight(currency.decimals, '0');

    // Combine integer and fraction parts
    final combinedText = '$integerPart$paddedFraction';

    final minorUnits = int.tryParse(combinedText);
    if (minorUnits == null) {
      throw ArgumentError('Amount "$amountText" causes integer overflow.');
    }

    if (minorUnits < 0) {
      throw ArgumentError('Amount cannot be negative.');
    }

    if (minorUnits == 0 && !allowZero) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    final effectiveMax = customMaxMinorUnits ?? maxPerRecordMinorUnits;
    if (minorUnits > effectiveMax) {
      throw ArgumentError(
        'Amount exceeds maximum permitted per-record limit ($effectiveMax minor units).',
      );
    }

    return minorUnits;
  }

  /// Convenience overload accepting currency code as String.
  static int parseToMinorUnitsByCode(
    String amountText,
    String currencyCode, {
    bool allowZero = false,
    int? customMaxMinorUnits,
  }) {
    final currency = validateCurrencyCode(currencyCode);
    return parseToMinorUnits(
      amountText,
      currency,
      allowZero: allowZero,
      customMaxMinorUnits: customMaxMinorUnits,
    );
  }

  /// Formats integer minor units according to [currency]'s decimal precision.
  /// Does NOT use double conversions.
  static String formatMinorUnits(
    int minorUnits,
    IsoCurrency currency, {
    bool includeSymbol = true,
    bool includeCode = false,
  }) {
    final isNegative = minorUnits < 0;
    final absUnits = minorUnits.abs();
    final rawText = absUnits.toString();

    String formattedNumber;

    if (currency.decimals == 0) {
      formattedNumber = _addThousandSeparators(rawText);
    } else {
      final padded = rawText.padLeft(currency.decimals + 1, '0');
      final intPartLength = padded.length - currency.decimals;
      final intPart = padded.substring(0, intPartLength);
      final fracPart = padded.substring(intPartLength);

      final formattedInt = _addThousandSeparators(intPart);
      formattedNumber = '$formattedInt.$fracPart';
    }

    final sign = isNegative ? '-' : '';

    if (includeSymbol && includeCode) {
      return '$sign${currency.symbol}$formattedNumber ${currency.code}';
    } else if (includeSymbol) {
      return '$sign${currency.symbol}$formattedNumber';
    } else if (includeCode) {
      return '$sign$formattedNumber ${currency.code}';
    } else {
      return '$sign$formattedNumber';
    }
  }

  /// Formats integer minor units into standard decimal string without symbol or code.
  static String formatMajorUnits(int minorUnits, IsoCurrency currency) {
    return formatMinorUnits(
      minorUnits,
      currency,
      includeSymbol: false,
      includeCode: false,
    );
  }

  static String _addThousandSeparators(String digits) {
    if (digits.length <= 3) return digits;
    final buffer = StringBuffer();
    final len = digits.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
