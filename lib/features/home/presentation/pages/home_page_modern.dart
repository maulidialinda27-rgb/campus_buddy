import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/widgets/dashboard_widgets.dart';
import 'package:campus_buddy/features/tugas/presentation/pages/tugas_page.dart';
import 'package:campus_buddy/features/scan/presentation/pages/scan_page.dart';
import 'package:campus_buddy/features/keuangan/presentation/pages/keuangan_page.dart';
import 'package:campus_buddy/features/jadwal/presentation/pages/jadwal_page.dart';
import 'package:campus_buddy/features/profil/presentation/pages/profil_page.dart';
import 'package:campus_buddy/models/notification_model.dart';
import 'package:campus_buddy/models/expense_model.dart';
import 'package:campus_buddy/services/notification_generator_service.dart';
import 'package:campus_buddy/services/local_storage_service.dart';
import 'package:campus_buddy/services/jadwal_service.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';

class HomePageModern extends StatefulWidget {
  const HomePageModern({super.key});

  @override
  State<HomePageModern> createState() => _HomePageModernState();
}

class _HomePageModernState extends State<HomePageModern> {
  int _selectedIndex = 0;
  List<DashboardNotification> _notifications = [];
  List<StudyTask> _tasks = [];
  List<Jadwal> _schedules = [];
  List<ExpenseItem> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final tasksData = await LocalStorageService.instance.loadJsonList(
        'study_tasks',
      );
      final tasks = tasksData.map((t) => StudyTask.fromMap(t)).toList();

      final jadwalService = JadwalService();
      final schedules = jadwalService.getAllJadwal();

      final expensesData = await LocalStorageService.instance.loadJsonList(
        'keuangan_expenses',
      );
      final expenses = expensesData.map((e) => ExpenseItem.fromMap(e)).toList();

      setState(() {
        _tasks = tasks;
        _schedules = schedules;
        _expenses = expenses;
      });

      _generateNotifications();
    } catch (_) {
      // Dashboard will still show with placeholder values
    }
  }

  void _generateNotifications() {
    final notifications = NotificationGeneratorService.generateNotifications(
      tasks: _tasks,
      schedules: _schedules,
      expenses: _expenses,
    );

    if (mounted) {
      setState(() {
        _notifications = notifications;
      });
    }
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskCount = _tasks.length;
    final scheduleCount = _schedules.length;
    final totalExpense = _expenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final todaySchedule = _schedules.isNotEmpty ? _schedules.first : null;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      extendBody: true,
      floatingActionButton: _buildModernFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernBottomBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.04,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan greeting
                    DashboardHeader(
                      userName: 'Mila',
                      subtitle:
                          'Lihat rencana hari ini dan raih fokus maksimal! 🎯',
                      notificationCount: _notifications.length,
                      onNotificationTap: () {},
                      onProfileTap: () => _navigateTo(4),
                    ),
                    const SizedBox(height: 28),

                    // Summary Card dengan Gradient
                    DashboardSummaryCard(
                      taskCount: taskCount,
                      scheduleCount: scheduleCount,
                      expenseAmount: totalExpense,
                    ),
                    const SizedBox(height: 28),

                    // Notifikasi Penting Section
                    SectionTitle(title: 'Notifikasi Penting', onSeeAll: null),
                    const SizedBox(height: 14),
                    if (_notifications.isEmpty)
                      EmptyStateWidget(
                        message:
                            'Tidak ada notifikasi penting. Nikmati hari yang tenang! ✨',
                        icon: Icons.inbox_rounded,
                        iconColor: AppColors.gray400,
                      )
                    else
                      Column(
                        children: _notifications
                            .take(3)
                            .map(
                              (notification) => Column(
                                children: [
                                  _buildNotificationCardModern(notification),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 28),

                    // Menu Utama Section
                    SectionTitle(title: 'Menu Utama', onSeeAll: null),
                    const SizedBox(height: 14),
                    _buildModernMenuGrid(),
                    const SizedBox(height: 28),

                    // Jadwal Terdekat Section
                    if (todaySchedule != null)
                      Column(
                        children: [
                          ScheduleCard(
                            scheduleTitle: todaySchedule.judul,
                            scheduleDay: todaySchedule.hari,
                            startTime: todaySchedule.jamMulai,
                            endTime: todaySchedule.jamSelesai,
                            location: todaySchedule.deskripsi ?? 'Lokasi',
                            tagColor: AppColors.primary,
                          ),
                          const SizedBox(height: 28),
                        ],
                      )
                    else
                      Column(
                        children: [
                          ScheduleCard(
                            scheduleTitle: 'Tambahkan jadwal baru',
                            scheduleDay: 'Senin',
                            startTime: '08:00',
                            endTime: '10:00',
                            location: 'Ruang Kuliah',
                            tagColor: AppColors.primary,
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),

                    // Bottom spacing untuk FAB
                    SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build Modern FAB
  Widget _buildModernFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanPage()),
        );
      },
      elevation: 8,
      backgroundColor: AppColors.primary,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: AppColors.gradientPrimary,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: AppColors.primary.withOpacity(0.4),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_2_rounded,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build Modern Bottom Navigation Bar
  Widget _buildModernBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 16,
      color: AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBottomBarItemModern(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),
            _buildBottomBarItemModern(
              icon: Icons.assignment_rounded,
              label: 'Tugas',
              index: 1,
            ),
            const SizedBox(width: 70),
            _buildBottomBarItemModern(
              icon: Icons.schedule_rounded,
              label: 'Jadwal',
              index: 2,
            ),
            _buildBottomBarItemModern(
              icon: Icons.person_rounded,
              label: 'Profil',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  /// Build Bottom Bar Item Modern
  Widget _buildBottomBarItemModern({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;
    final color = isActive ? AppColors.primary : AppColors.gray400;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _navigateTo(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Notification Card Modern
  Widget _buildNotificationCardModern(DashboardNotification notification) {
    final (iconBgColor, iconColor) = _getNotificationColors(notification.type);

    return DashboardNotificationItem(
      title: notification.title,
      description: notification.description,
      timeInfo: notification.getTimeRemaining(),
      icon: _getNotificationIcon(notification.type),
      iconBackgroundColor: iconBgColor,
      iconColor: iconColor,
      onDismiss: () => _dismissNotification(notification.id),
      onTap: () => _handleNotificationTap(notification),
    );
  }

  /// Build Modern Menu Grid
  Widget _buildModernMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.08,
      children: [
        MenuGridButton(
          label: 'Tugas',
          icon: Icons.assignment_turned_in_rounded,
          backgroundColor: AppColors.primaryLight,
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(1),
        ),
        MenuGridButton(
          label: 'Jadwal',
          icon: Icons.calendar_month_rounded,
          backgroundColor: AppColors.secondaryLight,
          iconColor: AppColors.secondary,
          onTap: () => _navigateTo(2),
        ),
        MenuGridButton(
          label: 'Keuangan',
          icon: Icons.wallet_rounded,
          backgroundColor: AppColors.categoryKeuangan.withOpacity(0.15),
          iconColor: AppColors.categoryKeuangan,
          onTap: () => _navigateTo(3),
        ),
        MenuGridButton(
          label: 'Scan & Catatan',
          icon: Icons.qr_code_scanner_rounded,
          backgroundColor: AppColors.accentLight,
          iconColor: AppColors.accent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanPage()),
            );
          },
        ),
      ],
    );
  }

  /// Helper functions
  (Color, Color) _getNotificationColors(NotificationType type) {
    switch (type) {
      case NotificationType.deadline:
        return (AppColors.primaryLight, AppColors.primary);
      case NotificationType.schedule:
        return (AppColors.secondaryLight, AppColors.secondary);
      case NotificationType.expense:
        return (
          AppColors.categoryKeuangan.withOpacity(0.15),
          AppColors.categoryKeuangan,
        );
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.deadline:
        return Icons.event_note_rounded;
      case NotificationType.schedule:
        return Icons.access_time_rounded;
      case NotificationType.expense:
        return Icons.receipt_long_rounded;
    }
  }

  void _handleNotificationTap(DashboardNotification notification) {
    switch (notification.type) {
      case NotificationType.deadline:
        _navigateTo(1);
        break;
      case NotificationType.schedule:
        _navigateTo(2);
        break;
      case NotificationType.expense:
        _navigateTo(3);
        break;
    }
  }

  void _navigateTo(int index) {
    Widget nextPage;

    switch (index) {
      case 0:
        return;
      case 1:
        nextPage = const TugasPage();
        break;
      case 2:
        nextPage = const JadwalPage();
        break;
      case 3:
        nextPage = const KeuanganPage();
        break;
      case 4:
        nextPage = const ProfilPage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    ).then((_) {
      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }
}
