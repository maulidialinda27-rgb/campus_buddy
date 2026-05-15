import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';

/// HEADER
class DashboardHeader extends StatelessWidget {
  final String userName;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.subtitle = 'Mari tingkatkan produktivitas hari ini! ✨',
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${userName.isEmpty ? "Pengguna" : userName} 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primary,
                ),

                if (notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.gradientPrimary,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// NOTIFICATION CARD
class DashboardNotificationItem extends StatelessWidget {
  final String title;
  final String description;
  final String? timeInfo;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const DashboardNotificationItem({
    super.key,
    required this.title,
    required this.description,
    this.timeInfo,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          /// SHADOW DIPERHALUS
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),

                  if (timeInfo != null) ...[
                    const SizedBox(height: 10),

                    /// BAGIAN YANG SUDAH DIPERBAIKI
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeInfo!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MENU GRID BUTTON
class MenuGridButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const MenuGridButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          /// SHADOW DIBUAT SOFT
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),

            const Spacer(),

            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// SECTION TITLE
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'PlusJakartaSans',
          ),
        ),

        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}