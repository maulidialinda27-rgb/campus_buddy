import 'package:flutter/material.dart';

/// Modern Card Widget - Reusable component dengan shadow halus
/// Digunakan untuk konsistensi UI di seluruh aplikasi
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Border? border;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final defaultShadow = [
      BoxShadow(color: Colors.black.withValues(alpha: 0.08)),
    ];

    final widget = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: shadows ?? defaultShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: widget);
    }

    return widget;
  }
}
