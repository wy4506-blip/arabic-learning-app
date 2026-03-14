import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppLatinTypography {
  AppLatinTypography._();

  static TextStyle title(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
          color: color ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15.5,
          height: 1.35,
          letterSpacing: 0.1,
        );
  }

  static TextStyle body(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: color ?? AppTheme.textPrimary,
          fontSize: 14,
          height: 1.55,
          letterSpacing: 0.08,
        );
  }

  static TextStyle caption(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: color ?? AppTheme.textSecondary,
          fontSize: 12.5,
          height: 1.45,
          letterSpacing: 0.1,
        );
  }
}
