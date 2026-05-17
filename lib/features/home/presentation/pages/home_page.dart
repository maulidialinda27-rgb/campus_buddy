import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
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
import 'package:campus_buddy/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = 'Pengguna';
  List<DashboardNotification> _notifications = [];
  List<StudyTask> _tasks = [];
  List<Jadwal> _schedules = [];
  List<ExpenseItem> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadAllData();
  }

  void _loadUserName() {
    final name = UserService().getUserName();
    if (name != null && name.trim().isNotEmpty) {
      setState(() {
        _userName = name;
      });
    }
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
      // Ignored; dashboard will still show placeholder values
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanPage()),
          );
        },
        elevation: 8,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildSummaryCard(taskCount, scheduleCount, totalExpense),
                    const SizedBox(height: 24),
                    _buildNotificationsSection(),
                    const SizedBox(height: 24),
                    _buildMainMenuSection(),
                    const SizedBox(height: 24),
                    _buildNextScheduleCard(todaySchedule),
                    SizedBox(height: constraints.maxHeight * 0.15),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName == 'Pengguna' ? 'Halo Pengguna 👋' : 'Halo $_userName 👋',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lihat rencana hari ini dan jaga fokus belajar dengan tampilan yang lembut.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSubText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: AppColors.lightText.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.lightGray,
          child: const Icon(Icons.person, color: AppColors.primary, size: 26),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    int taskCount,
    int scheduleCount,
    double totalExpense,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.dashboard_customize,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Pantau tugas, jadwal, dan pengeluaran dengan tampilan modern dan ringan.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSubText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryStat(
                'Tugas',
                '$taskCount',
                Icons.task_alt,
                AppColors.primary,
              ),
              const SizedBox(width: 10),
              _buildSummaryStat(
                'Jadwal',
                '$scheduleCount',
                Icons.schedule,
                AppColors.secondary,
              ),
              const SizedBox(width: 10),
              _buildSummaryStat(
                'Pengeluaran',
                'Rp ${totalExpense.toStringAsFixed(0)}',
                Icons.wallet_outlined,
                AppColors.categoryKeuangan,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSubText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifikasi Penting',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 14),
        if (_notifications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Text(
              'Tidak ada notifikasi penting saat ini.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.lightSubText,
              ),
            ),
          )
        else
          Column(
            children: _notifications
                .take(3)
                .map(_buildNotificationCard)
                .toList(),
          ),
      ],
    );
  }

  Widget _buildNotificationCard(DashboardNotification notification) {
    final cardColor = notification.type == NotificationType.deadline
        ? AppColors.primaryLight
        : notification.type == NotificationType.schedule
        ? AppColors.secondaryLight
        : AppColors.categoryKeuangan.withAlpha(30);

    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: AppColors.lightText.withAlpha(8),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                notification.type == NotificationType.deadline
                    ? Icons.event_note_outlined
                    : notification.type == NotificationType.schedule
                    ? Icons.access_time_outlined
                    : Icons.receipt_long_outlined,
                color: AppColors.lightText,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.description,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSubText,
                      height: 1.5,
                    ),
                  ),
                  if (notification.getTimeRemaining() != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      notification.getTimeRemaining()!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _dismissNotification(notification.id),
              child: Icon(Icons.close, color: AppColors.lightSubText, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Utama',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 14),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.12,
          ),
          children: [
            _buildMenuButton(
              label: 'Tugas',
              icon: Icons.assignment_turned_in_outlined,
              backgroundColor: AppColors.primaryLight,
              iconColor: AppColors.primary,
              onTap: () => _navigateTo(1),
            ),
            _buildMenuButton(
              label: 'Jadwal',
              icon: Icons.calendar_month_outlined,
              backgroundColor: AppColors.secondaryLight,
              iconColor: AppColors.secondaryDark,
              onTap: () => _navigateTo(2),
            ),
            _buildMenuButton(
              label: 'Keuangan',
              icon: Icons.wallet_outlined,
              backgroundColor: AppColors.categoryKeuangan.withAlpha(20),
              iconColor: AppColors.categoryKeuangan,
              onTap: () => _navigateTo(3),
            ),
            _buildMenuButton(
              label: 'Scan & Catatan',
              icon: Icons.qr_code_scanner_outlined,
              backgroundColor: AppColors.accent.withAlpha(20),
              iconColor: AppColors.accentDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
                );
              },
            ),
            _buildMenuButton(
              label: 'Laporan',
              icon: Icons.bar_chart_outlined,
              backgroundColor: AppColors.lightGray,
              iconColor: AppColors.lightText,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightText.withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextScheduleCard(Jadwal? schedule) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightText.withAlpha(8),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Jadwal Terdekat',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  schedule?.hari ?? 'Belum ada jadwal',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            schedule?.judul ?? 'Tambahkan jadwal kuliah atau seminar baru.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                schedule != null
                    ? '${schedule.jamMulai} - ${schedule.jamSelesai}'
                    : '08:00 - 10:00',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: AppColors.lightSubText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 18),
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  schedule?.deskripsi ?? 'Ruang Kuliah 204',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.lightSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 16,
      color: AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBottomBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
              index: 0,
            ),
            _buildBottomBarItem(
              icon: Icons.assignment_outlined,
              label: 'Tugas',
              index: 1,
            ),
            const SizedBox(width: 56),
            _buildBottomBarItem(
              icon: Icons.schedule_outlined,
              label: 'Jadwal',
              index: 2,
            ),
            _buildBottomBarItem(
              icon: Icons.person_outline,
              label: 'Profil',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;
    final color = isActive ? AppColors.primary : AppColors.lightSubText;

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
          Icon(icon, color: color, size: 24),
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
      setState(() {
        _selectedIndex = 0;
      });
    });
  }
}
