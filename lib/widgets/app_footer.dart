import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({
    super.key,
    this.light = false,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  final bool light;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final creditColor = light ? Colors.white : Colors.grey.shade500;
    final devColor = light ? Colors.white.withValues(alpha: 0.88) : Colors.grey.shade400;
    final dotColor      = light ? AppTheme.gold.withValues(alpha: 0.7) : AppTheme.gold.withValues(alpha: 0.5);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative gold line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 16, height: 1, color: dotColor),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 4,
                height: 4,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              Container(width: 16, height: 1, color: dotColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Credit: Advocate Islamuddin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: creditColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Developed at Techease Solutions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: devColor,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}
