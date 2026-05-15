import 'package:flutter/material.dart';

/// Modern Button Widget - Solid color button dengan styling konsisten
class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool isLoading;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.isFullWidth = true,
    this.padding,
    this.borderRadius = 12,
    this.isLoading = false,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onPressed,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              if (_isPressed)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.foregroundColor ?? Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.foregroundColor ?? Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.foregroundColor ?? Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return button;
  }
}

/// Modern Outline Button - Button dengan border outline
class ModernOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final IconData? icon;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const ModernOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
    this.icon,
    this.isFullWidth = true,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  State<ModernOutlineButton> createState() => _ModernOutlineButtonState();
}

class _ModernOutlineButtonState extends State<ModernOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.borderColor.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(color: widget.borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.textColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
