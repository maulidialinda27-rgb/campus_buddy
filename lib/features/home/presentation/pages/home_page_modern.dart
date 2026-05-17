import 'package:flutter/material.dart';

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
import 'package:campus_buddy/services/user_service.dart';


class HomePageModern extends StatefulWidget {
  const HomePageModern({super.key});

  @override
  State<HomePageModern> createState() => _HomePageModernState();
}

class _HomePageModernState extends State<HomePageModern> {
  int _selectedIndex = 0;

  String userName = 'Pengguna';


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
        userName = name;
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

      final expenses =
          expensesData.map((e) => ExpenseItem.fromMap(e)).toList();

      setState(() {
        _tasks = tasks;
        _schedules = schedules;
        _expenses = expenses;
      });

      _generateNotifications();
    } catch (_) {}
  }

  void _generateNotifications() {
    final notifications =
        NotificationGeneratorService.generateNotifications(
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

    final todaySchedule =
        _schedules.isNotEmpty ? _schedules.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      /// HAPUS extendBody supaya tidak overflow
      extendBody: false,

      floatingActionButton: _buildModernFAB(),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildModernBottomBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              DashboardHeader(
                userName: userName,
                subtitle:
                    'Lihat rencana hari ini dan raih fokus maksimal ✨',
                notificationCount: _notifications.length,
                onNotificationTap: () {},
                onProfileTap: () => _navigateTo(4),
              ),

              const SizedBox(height: 24),

              /// SUMMARY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5B67F1),
                      Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Hari Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Pantau tugas, jadwal, dan pengeluaranmu dengan tampilan modern.',
                      style: TextStyle(
                        color:
                            Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.5,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Tugas',
                            '$taskCount',
                            Icons.assignment_rounded,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildStatCard(
                            'Jadwal',
                            '$scheduleCount',
                            Icons.calendar_month_rounded,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildStatCard(
                            'Uang',
                            'Rp ${totalExpense.toStringAsFixed(0)}',
                            Icons.wallet_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// NOTIFIKASI
              SectionTitle(
                title: 'Notifikasi Penting',
                onSeeAll: null,
              ),

              const SizedBox(height: 14),

              if (_notifications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'Tidak ada notifikasi saat ini ✨',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                )
              else
                Column(
                  children: _notifications
                      .take(3)
                      .map(
                        (notification) => Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child:
                              _buildNotificationCardModern(
                            notification,
                          ),
                        ),
                      )
                      .toList(),
                ),

              const SizedBox(height: 28),

              /// MENU
              SectionTitle(
                title: 'Menu Utama',
                onSeeAll: null,
              ),

              const SizedBox(height: 14),

              _buildModernMenuGrid(),

              const SizedBox(height: 28),

              /// JADWAL
              SectionTitle(
                title: 'Jadwal Terdekat',
                onSeeAll: null,
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      todaySchedule?.judul ??
                          'Belum ada jadwal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .access_time_filled_rounded,
                          size: 18,
                          color: Color(0xFF5B67F1),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          todaySchedule != null
                              ? '${todaySchedule.jamMulai} - ${todaySchedule.jamSelesai}'
                              : '08:00 - 10:00',
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: Color(0xFF8B5CF6),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            todaySchedule?.deskripsi ??
                                'Tambahkan jadwal baru',
                          ),
                        ),
                      ],
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

  /// CARD STATISTIK
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'PlusJakartaSans',
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      ),
    );
  }

  /// FLOATING BUTTON
  Widget _buildModernFAB() {
    return FloatingActionButton(
      elevation: 4,
      backgroundColor: const Color(0xFF5B67F1),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScanPage(),
          ),
        );
      },
      child: const Icon(
        Icons.qr_code_scanner_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// BOTTOM BAR
  Widget _buildModernBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 6,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
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

            const SizedBox(width: 55),

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

  Widget _buildBottomBarItemModern({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;

    final color = isActive
        ? const Color(0xFF5B67F1)
        : Colors.grey;

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
          Icon(
            icon,
            color: color,
            size: 24,
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

  /// NOTIFICATION CARD
  Widget _buildNotificationCardModern(
    DashboardNotification notification,
  ) {
    return DashboardNotificationItem(
      title: notification.title,
      description: notification.description,
      timeInfo: notification.getTimeRemaining(),
      icon: Icons.notifications_active_rounded,
      iconBackgroundColor:
          const Color(0xFF5B67F1).withValues(alpha: 0.1),
      iconColor: const Color(0xFF5B67F1),
      onDismiss: () =>
          _dismissNotification(notification.id),
      onTap: () =>
          _handleNotificationTap(notification),
    );
  }

  /// MENU GRID
  Widget _buildModernMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: [
        _buildMenuItem(
          label: 'Tugas',
          icon: Icons.assignment_turned_in_rounded,
          color: const Color(0xFF5B67F1),
          onTap: () => _navigateTo(1),
        ),

        _buildMenuItem(
          label: 'Jadwal',
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => _navigateTo(2),
        ),

        _buildMenuItem(
          label: 'Keuangan',
          icon: Icons.wallet_rounded,
          color: const Color(0xFF22C7F0),
          onTap: () => _navigateTo(3),
        ),

        _buildMenuItem(
          label: 'Scan',
          icon: Icons.qr_code_scanner_rounded,
          color: const Color(0xFFEC4899),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const ScanPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(
    DashboardNotification notification,
  ) {
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
      MaterialPageRoute(
        builder: (context) => nextPage,
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });

        _loadAllData();
      }
    });
  }
}
