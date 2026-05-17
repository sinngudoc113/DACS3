String formatCurrency(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String formatSignedCurrency(double value) {
  final sign = value < 0 ? '-' : '+';
  return '$sign\$${value.abs().toStringAsFixed(2)}';
}
