import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';

/// Modern page header dengan gradient background
class ModernPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Color>? gradientColors;

  const ModernPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.showBackButton = true,
    this.onBackPressed,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppColors.gradientPrimary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: colors.first.withValues(alpha: 0.25),
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                )
              else
                const SizedBox(width: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 204),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) ...[const SizedBox(width: 12), action!],
            ],
          ),
        ],
      ),
    );
  }
}

/// Modern card untuk list item dengan icon, title, subtitle, dan action
class ModernListCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const ModernListCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100, width: 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: AppColors.lightText.withValues(alpha: 13),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ] else ...[
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gray300,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern card untuk settings toggle
class ModernSettingToggle extends StatefulWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const ModernSettingToggle({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<ModernSettingToggle> createState() => _ModernSettingToggleState();
}

class _ModernSettingToggleState extends State<ModernSettingToggle> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: AppColors.lightText.withValues(alpha: 13),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.iconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightText,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: _isEnabled,
              onChanged: (newValue) {
                setState(() {
                  _isEnabled = newValue;
                });
                widget.onChanged(newValue);
              },
              activeThumbColor: AppColors.primary,
              inactiveThumbColor: AppColors.gray300,
              inactiveTrackColor: AppColors.gray100,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Profile Card dengan Avatar
class ModernProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onEditPressed;

  const ModernProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.gradientSecondary,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: AppColors.secondary.withValues(alpha: 64),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 77),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 128),
                  width: 2,
                ),
              ),
              child: avatarUrl == null
                  ? Icon(Icons.person_rounded, size: 40, color: Colors.white)
                  : Image.network(avatarUrl!, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 204),
                    ),
                  ),
                ],
              ),
            ),
            if (onEditPressed != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onEditPressed,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern Section Header
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const ModernSectionHeader({super.key, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.gray600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Modern Divider
class ModernDivider extends StatelessWidget {
  final double height;
  final Color color;

  const ModernDivider({
    super.key,
    this.height = 1,
    this.color = AppColors.gray100,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(height: height, color: color),
    );
  }
}
