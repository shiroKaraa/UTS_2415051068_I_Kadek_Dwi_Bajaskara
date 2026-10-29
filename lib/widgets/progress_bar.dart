import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  final Color? color;

  const ProgressBar({
    super.key,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primaryGreen,
        ),
      ),
    );
  }
}