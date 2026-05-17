import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final BoxShadow? shadow;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = 18,
    this.onTap,
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: shadow != null 
              ? [shadow!] 
              : [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final double blurSigma; // Kept for compatibility, but unused
  final Color? glowColor; // Kept for compatibility, used for soft shadow

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = 20,
    this.blurSigma = 10,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    // Redesigned to Soft Minimalist Card, removing glass and neon glow
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? AppColors.shadowColor).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const CategoryBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
