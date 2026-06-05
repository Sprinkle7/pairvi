import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 40,
    this.borderRadius = 10,
    this.showShadow = false,
  });

  final double size;
  final double borderRadius;
  final bool showShadow;

  static const assetPath = 'assets/images/app_icon.png';

  @override
  Widget build(BuildContext context) {
    // 11% internal padding so content never touches edges
    final padding = (size * 0.11).clamp(4.0, 14.0);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppTheme.primaryDark.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 2),
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}
