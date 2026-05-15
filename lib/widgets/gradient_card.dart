import 'package:flutter/material.dart';

/// Modern Gradient Card Widget - Untuk card dengan gradient background
/// Digunakan untuk summary card, promo, atau highlight section
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.begin,
    this.end,
    this.padding,
    this.margin,
    this.borderRadius,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];

    final widget = Container(
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        boxShadow: shadows ?? defaultShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: widget);
    }

    return widget;
  }
}
