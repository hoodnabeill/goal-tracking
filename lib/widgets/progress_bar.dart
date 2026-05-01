import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.backgroundColor,
  });

  final double progress;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: normalizedProgress,
        minHeight: height,
        backgroundColor: backgroundColor ?? const Color(0xFF1A2535),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF28D7B9)),
      ),
    );
  }
}
