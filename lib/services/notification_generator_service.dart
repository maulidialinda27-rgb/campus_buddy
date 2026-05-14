import 'package:campus_buddy/models/notification_model.dart';
import 'package:campus_buddy/models/expense_model.dart';
import 'package:campus_buddy/features/tugas/presentation/pages/tugas_page.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/core/utils/time_helper.dart';

/// Service untuk generate notifikasi dashboard secara dinamis
class NotificationGeneratorService {
  /// Generate semua notifikasi berdasarkan data terkini
  static List<DashboardNotification> generateNotifications({
    required List<StudyTask> tasks,
    required List<Jadwal> schedules,
    required List<ExpenseItem> expenses,
  }) {
    final notifications = <DashboardNotification>[];

    // Generate notifikasi dari tugas
    notifications.addAll(_generateTaskNotifications(tasks));

    // Generate notifikasi dari jadwal
    notifications.addAll(_generateScheduleNotifications(schedules));

    // Generate notifikasi dari keuangan
    notifications.addAll(_generateExpenseNotifications(expenses));

    // Sort berdasarkan priority dan actionDate
    notifications.sort((a, b) {
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      if (a.actionDate != null && b.actionDate != null) {
        return a.actionDate!.compareTo(b.actionDate!);
      }
      return 0;
    });

    // Limit notifikasi maksimal 10
    return notifications.take(10).toList();
  }

  /// Generate notifikasi dari tugas (deadline)
  static List<DashboardNotification> _generateTaskNotifications(
    List<StudyTask> tasks,
  ) {
    final notifications = <DashboardNotification>[];
    final now = DateTime.now();

    for (final task in tasks) {
      if (task.completed) continue;

      final daysUntilDeadline = task.deadline.difference(now).inDays;

      // Skip jika sudah lewat atau lebih dari 7 hari
      if (daysUntilDeadline < -1 || daysUntilDeadline > 7) {
        continue;
      }

      // Tentukan priority berdasarkan jarak deadline
      NotificationPriority priority;
      if (daysUntilDeadline < 0) {
        priority = NotificationPriority.critical; // Sudah lewat
      } else if (daysUntilDeadline == 0) {
        priority = NotificationPriority.critical; // Hari ini
      } else if (daysUntilDeadline <= 2) {
        priority = NotificationPriority.high; // 1-2 hari
      } else if (daysUntilDeadline <= 4) {
        priority = NotificationPriority.medium; // 3-4 hari
      } else {
        priority = NotificationPriority.low; // 5-7 hari
      }

      final timeRemaining = _formatDeadlineTime(task.deadline);

      notifications.add(
        DashboardNotification(
          id: 'task_${task.hashCode}',
          title: 'Tugas: ${task.title}',
          description: '${task.subject} • $timeRemaining',
          type: NotificationType.deadline,
          priority: priority,
          createdAt: now,
          actionDate: task.deadline,
          icon: '📝',
          color: 0xFF8B5CF6, // Purple
          actionLabel: 'Lihat Tugas',
        ),
      );
    }

    return notifications;
  }

  /// Generate notifikasi dari jadwal
  static List<DashboardNotification> _generateScheduleNotifications(
    List<Jadwal> schedules,
  ) {
    final notifications = <DashboardNotification>[];
    final now = DateTime.now();
    final hariIni = _getNamaHari(now.weekday);

    for (final schedule in schedules) {
      // Hanya tampilkan jadwal hari ini ke depan
      if (!_isScheduleRelevant(schedule.hari, hariIni)) {
        continue;
      }

      try {
        final jamMulai = parseJam(schedule.jamMulai);

        // Hitung menit sampai jadwal
        int minutesUntil;
        if (jamMulai.isAfter(now)) {
          minutesUntil = jamMulai.difference(now).inMinutes;
        } else {
          // Jika sudah lewat hari ini, skip
          continue;
        }

        // Skip jika lebih dari 24 jam
        if (minutesUntil > 1440) {
          continue;
        }

        // Tentukan priority
        NotificationPriority priority;
        if (minutesUntil <= 30) {
          priority = NotificationPriority.critical;
        } else if (minutesUntil <= 120) {
          priority = NotificationPriority.high;
        } else if (minutesUntil <= 360) {
          priority = NotificationPriority.medium;
        } else {
          priority = NotificationPriority.low;
        }

        final durationText = _formatScheduleDuration(
          schedule.jamMulai,
          schedule.jamSelesai,
        );
        final timeText = _formatTimeUntilSchedule(minutesUntil);

        notifications.add(
          DashboardNotification(
            id: 'schedule_${schedule.id}',
            title: schedule.judul,
            description: '${schedule.jamMulai} • $durationText • $timeText',
            type: NotificationType.schedule,
            priority: priority,
            createdAt: now,
            actionDate: jamMulai,
            icon: '📅',
            color: 0xFF00D4FF, // Neon blue
            actionLabel: 'Lihat Jadwal',
          ),
        );
      } catch (e) {
        // Skip jika ada error parsing jam
        continue;
      }
    }

    return notifications;
  }

  /// Generate notifikasi dari keuangan (pengeluaran hari ini)
  static List<DashboardNotification> _generateExpenseNotifications(
    List<ExpenseItem> expenses,
  ) {
    final notifications = <DashboardNotification>[];
    final now = DateTime.now();

    // Filter pengeluaran hari ini
    final todayExpenses = expenses.where((expense) {
      return expense.date.year == now.year &&
          expense.date.month == now.month &&
          expense.date.day == now.day;
    }).toList();

    if (todayExpenses.isEmpty) {
      return notifications;
    }

    // Hitung total pengeluaran hari ini
    final totalExpense = todayExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    // Notifikasi total pengeluaran hari ini
    notifications.add(
      DashboardNotification(
        id: 'expense_today',
        title: 'Pengeluaran Hari Ini',
        description:
            '${todayExpenses.length} transaksi • Rp${_formatCurrency(totalExpense.toInt())}',
        type: NotificationType.expense,
        priority: totalExpense > 100000
            ? NotificationPriority.high
            : NotificationPriority.medium,
        createdAt: now,
        actionDate: now,
        icon: '💰',
        color: 0xFFFF9500, // Orange
        actionLabel: 'Lihat Detail',
      ),
    );

    // Tambah notifikasi untuk kategori dengan pengeluaran terbesar
    final Map<String, double> categoryTotals = {};
    for (final expense in todayExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Sort dan ambil kategori dengan pengeluaran terbesar
    final topCategory = categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    if (topCategory.value > 50000) {
      // Hanya tampilkan jika pengeluaran kategori signifikan
      notifications.add(
        DashboardNotification(
          id: 'expense_category_${topCategory.key}',
          title: 'Pengeluaran Terbesar: ${topCategory.key}',
          description: 'Rp${_formatCurrency(topCategory.value.toInt())}',
          type: NotificationType.expense,
          priority: NotificationPriority.medium,
          createdAt: now,
          actionDate: now,
          icon: '💸',
          color: 0xFFFF5E78, // Neon pink
          actionLabel: 'Analisis',
        ),
      );
    }

    return notifications;
  }

  /// Helper: Format waktu deadline
  static String _formatDeadlineTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Sudah lewat ${difference.inDays.abs()} hari lalu';
    }

    if (difference.inMinutes < 1) {
      return 'Sekarang juga!';
    } else if (difference.inHours < 1) {
      return 'Dalam ${difference.inMinutes} menit';
    } else if (difference.inDays < 1) {
      return 'Dalam ${difference.inHours} jam';
    } else if (difference.inDays == 1) {
      return 'Besok pukul ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    } else {
      return 'Dalam ${difference.inDays} hari';
    }
  }

  /// Helper: Format durasi jadwal
  static String _formatScheduleDuration(String jamMulai, String jamSelesai) {
    try {
      final mulai = parseJam(jamMulai);
      final selesai = parseJam(jamSelesai);

      var adjustedSelesai = selesai;
      if (selesai.isBefore(mulai)) {
        adjustedSelesai = selesai.add(const Duration(days: 1));
      }

      final duration = adjustedSelesai.difference(mulai);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      if (hours > 0) {
        return '${hours}j ${minutes}m';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return '?';
    }
  }

  /// Helper: Format waktu sampai jadwal
  static String _formatTimeUntilSchedule(int minutes) {
    if (minutes < 1) {
      return 'Sekarang';
    } else if (minutes < 60) {
      return 'Dalam $minutes menit';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return 'Dalam ${hours}j ${mins}m';
    } else {
      final days = minutes ~/ 1440;
      return 'Dalam $days hari';
    }
  }

  /// Helper: Format currency
  static String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return amount.toString();
  }

  /// Helper: Get nama hari
  static String _getNamaHari(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }

  /// Helper: Check apakah jadwal relevan (hari ini ke depan)
  static bool _isScheduleRelevant(String hari, String hariIni) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final jadwalIndex = days.indexOf(hari);
    final hariIniIndex = days.indexOf(hariIni);

    if (jadwalIndex == hariIniIndex) return true; // Hari ini
    if (jadwalIndex > hariIniIndex) return true; // Hari depan minggu ini

    return false; // Sudah lewat minggu ini
  }
}
