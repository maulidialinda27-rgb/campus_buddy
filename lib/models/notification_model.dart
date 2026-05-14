import 'package:flutter/material.dart';

enum NotificationType {
  deadline, // Tugas deadline
  schedule, // Jadwal akan dimulai
  expense, // Pengeluaran hari ini
}

enum NotificationPriority { low, medium, high, critical }

class DashboardNotification {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? actionDate;
  final String icon;
  final int color; // Color value as int
  final String? actionLabel;
  final VoidCallback? onAction;

  DashboardNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.actionDate,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.onAction,
  });

  /// Get priority badge color
  int getPriorityColor() {
    switch (priority) {
      case NotificationPriority.critical:
        return 0xFFFF5E78; // Neon pink
      case NotificationPriority.high:
        return 0xFFFF9500; // Orange
      case NotificationPriority.medium:
        return 0xFFFFC107; // Amber
      case NotificationPriority.low:
        return 0xFF4CAF50; // Green
    }
  }

  /// Get time remaining text
  String? getTimeRemaining() {
    if (actionDate == null) return null;

    final difference = actionDate!.difference(DateTime.now());

    if (difference.isNegative) {
      return 'Sudah lewat';
    }

    if (difference.inMinutes < 1) {
      return 'Sekarang';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lagi';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lagi';
    } else if (difference.inDays == 1) {
      return 'Besok';
    } else {
      return '${difference.inDays} hari lagi';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'actionDate': actionDate?.toIso8601String(),
      'icon': icon,
      'color': color,
      'actionLabel': actionLabel,
    };
  }

  factory DashboardNotification.fromMap(Map<String, dynamic> map) {
    return DashboardNotification(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: NotificationType.values[map['type']],
      priority: NotificationPriority.values[map['priority']],
      createdAt: DateTime.parse(map['createdAt']),
      actionDate: map['actionDate'] != null
          ? DateTime.parse(map['actionDate'])
          : null,
      icon: map['icon'],
      color: map['color'],
      actionLabel: map['actionLabel'],
    );
  }
}
