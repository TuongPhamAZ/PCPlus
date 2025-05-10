class TaxRate {
  static const double vat = 0.01;
  static const double pit = 0.005;
  static const double commissionFee = 0.035;

  static String get totalFeePercent {
    return "${(vat + pit + commissionFee) * 100}%";
}
}