import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/models/notification_model.dart';

/// Modern Notification Card Widget
class NotificationCard extends StatelessWidget {
  final DashboardNotification notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = Color(notification.getPriorityColor());
    final bgColor = Color(notification.color);

    return FadeInUp(
      child: GestureDetector(
        onTap: onTap ?? notification.onAction,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF0F172A).withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(color: bgColor.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient overlay berdasarkan priority
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bgColor.withValues(alpha: 0.1),
                      bgColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
              // Priority indicator (garis kiri)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notification.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Priority badge
                              _buildPriorityBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8).withValues(alpha: 0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (notification.getTimeRemaining() != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                notification.getTimeRemaining()!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getTimeRemainingColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action button / Dismiss
                    if (notification.actionLabel != null)
                      GestureDetector(
                        onTap: onDismiss,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: bgColor.withValues(alpha: 0.4),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: bgColor,
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onDismiss,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: const Color(0xFF64748B).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final priorityColor = Color(notification.getPriorityColor());
    final priorityLabel = _getPriorityLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        priorityLabel,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: priorityColor,
        ),
      ),
    );
  }

  String _getPriorityLabel() {
    switch (notification.priority) {
      case NotificationPriority.critical:
        return '🔴 URGENT';
      case NotificationPriority.high:
        return '🟠 HIGH';
      case NotificationPriority.medium:
        return '🟡 MED';
      case NotificationPriority.low:
        return '🟢 LOW';
    }
  }

  Color _getTimeRemainingColor() {
    if (notification.priority == NotificationPriority.critical) {
      return const Color(0xFFFF5E78);
    } else if (notification.priority == NotificationPriority.high) {
      return const Color(0xFFFF9500);
    }
    return const Color(0xFF94A3B8);
  }
}

/// Notification List Widget
class NotificationList extends StatefulWidget {
  final List<DashboardNotification> notifications;
  final void Function(String id)? onDismiss;
  final void Function(DashboardNotification)? onNotificationTap;
  final bool showEmpty;

  const NotificationList({
    super.key,
    required this.notifications,
    this.onDismiss,
    this.onNotificationTap,
    this.showEmpty = true,
  });

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  late List<DashboardNotification> _visibleNotifications;

  @override
  void initState() {
    super.initState();
    _visibleNotifications = List.from(widget.notifications);
  }

  @override
  void didUpdateWidget(NotificationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update jika ada notifikasi baru
    _visibleNotifications = List.from(widget.notifications);
  }

  void _dismissNotification(String id) {
    setState(() {
      _visibleNotifications.removeWhere((n) => n.id == id);
    });
    widget.onDismiss?.call(id);
  }

  @override
  Widget build(BuildContext context) {
    if (_visibleNotifications.isEmpty) {
      return widget.showEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada notifikasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _visibleNotifications.length,
      itemBuilder: (context, index) {
        final notification = _visibleNotifications[index];
        return NotificationCard(
          key: ValueKey(notification.id),
          notification: notification,
          onDismiss: () => _dismissNotification(notification.id),
          onTap: () => widget.onNotificationTap?.call(notification),
        );
      },
    );
  }
}

/// Compact Notification Header dengan count
class NotificationHeader extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onViewAll;

  const NotificationHeader({
    super.key,
    required this.notificationCount,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                '🔔 Notifikasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              if (notificationCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5E78).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFFFF5E78).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF5E78),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (onViewAll != null && notificationCount > 0)
            GestureDetector(
              onTap: onViewAll,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
