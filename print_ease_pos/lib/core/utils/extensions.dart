import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String get formatted => DateFormat('MMM dd, yyyy - HH:mm').format(this);
  String get dateOnly => DateFormat('MMM dd, yyyy').format(this);
}

extension PriceFormatting on double {
  String toCurrency({String symbol = '\$'}) => '$symbol${toStringAsFixed(2)}';
}

extension BuildContextExtensions on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 1024;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024;
}
