import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme get textTheme {
    return const TextTheme(
        // Material 3 provides sensible defaults, but this gives us a centralized
        // place to override typography later if needed.
        );
  }
}
