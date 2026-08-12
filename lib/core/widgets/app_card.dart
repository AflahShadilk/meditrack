import 'package:flutter/material.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.medium),
        child: child,
      ),
    );
  }
}
