/// Represents an active ISO 4217 currency definition.
class IsoCurrency {
  /// The 3-letter uppercase ISO 4217 code (e.g., 'USD', 'EUR', 'JPY', 'BHD').
  final String code;

  /// The official English display name (e.g., 'US Dollar', 'Euro', 'Yen').
  final String name;

  /// The currency symbol or prefix (e.g., '$', '€', '¥', 'BD').
  final String symbol;

  /// The number of minor-unit decimal places (0, 2, or 3).
  final int decimals;

  /// Associated countries and territories using or accepting this currency.
  final List<String> countries;

  const IsoCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.countries,
  });

  /// The minor unit multiplier factor (10^decimals).
  int get minorUnitFactor {
    switch (decimals) {
      case 0:
        return 1;
      case 2:
        return 100;
      case 3:
        return 1000;
      default:
        int factor = 1;
        for (int i = 0; i < decimals; i++) {
          factor *= 10;
        }
        return factor;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IsoCurrency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code ($symbol, $name, $decimals decimals)';
}
