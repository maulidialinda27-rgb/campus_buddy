import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/core/constants/app_constants.dart';
import 'package:campus_buddy/widgets/custom_cards.dart';
import 'package:campus_buddy/widgets/notification_card.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  /// Load semua data dari berbagai sumber
  Future<void> _loadAllData() async {
    try {
      // Load tasks
      final tasksData = await LocalStorageService.instance.loadJsonList(
        'study_tasks',
      );
      final tasks = tasksData.map((t) => StudyTask.fromMap(t)).toList();

      // Load schedules
      final jadwalService = JadwalService();
      final schedules = jadwalService.getAllJadwal();

      // Load expenses
      final expensesData = await LocalStorageService.instance.loadJsonList(
        'keuangan_expenses',
      );
      final expenses = expensesData.map((e) => ExpenseItem.fromMap(e)).toList();

      setState(() {
        _tasks = tasks;
        _schedules = schedules;
        _expenses = expenses;
      });

      // Generate notifikasi
      _generateNotifications();
    } catch (e) {
      // Silent catch, notification generation will continue
    }
  }

  /// Generate notifikasi berdasarkan data terkini
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

  /// Dismiss notifikasi
  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(child: Text(AppStrings.dashboard)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppColors.darkSurface.withValues(alpha: 0.1)),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBg,
              AppColors.darkBg.withValues(alpha: 0.9),
              AppColors.darkBg.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selamat datang
                FadeInLeft(
                  child: Text(
                    'Selamat datang kembali! 👋',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Dashboard Notifikasi
                if (_notifications.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NotificationHeader(
                        notificationCount: _notifications.length,
                      ),
                      const SizedBox(height: 8),
                      NotificationList(
                        notifications: _notifications,
                        onDismiss: _dismissNotification,
                        onNotificationTap: (notification) {
                          // Handle notifikasi tap based on type
                          _handleNotificationTap(notification);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Tugas Menunggu
                _buildSectionTitle(AppStrings.tugasMenunggu),
                _buildTugasSection(),

                const SizedBox(height: 24),

                // Jadwal Hari Ini
                _buildSectionTitle(AppStrings.jadwalHariIni),
                _buildJadwalSection(),

                const SizedBox(height: 24),

                // Pengeluaran Hari Ini
                _buildSectionTitle(AppStrings.pengeluaranHariIni),
                _buildPengeluaranSection(),

                const SizedBox(height: 24),

                // Catatan Terbaru
                _buildSectionTitle(AppStrings.catatanTerbaru),
                _buildCatatanSection(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _navigateTo(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppConstants.beranda,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: const Icon(Icons.assignment),
            label: AppConstants.tugas,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.image_search_outlined),
            activeIcon: const Icon(Icons.image_search),
            label: AppConstants.scan,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.wallet_outlined),
            activeIcon: const Icon(Icons.wallet),
            label: AppConstants.keuangan,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule_outlined),
            activeIcon: const Icon(Icons.schedule),
            label: AppConstants.jadwal,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: AppConstants.profil,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTugasSection() {
    return FadeInUp(
      child: GlassmorphismCard(
        glowColor: AppColors.categoryTugas,
        child: Column(
          children: [
            _buildDashboardItem(
              icon: Icons.check_circle_outline,
              title: 'Tugas 1: Buat Laporan',
              subtitle: 'Deadline: 15 Mei 2026',
              color: AppColors.categoryTugas,
            ),
            const Divider(height: 16),
            _buildDashboardItem(
              icon: Icons.check_circle_outline,
              title: 'Tugas 2: Review Project',
              subtitle: 'Deadline: 20 Mei 2026',
              color: AppColors.categoryTugas,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: GlassmorphismCard(
        glowColor: AppColors.categoryJadwal,
        child: _buildDashboardItem(
          icon: Icons.access_time_outlined,
          title: 'Kuliah Algoritma',
          subtitle: '08:00 - 10:00 di Ruang 101',
          color: AppColors.categoryJadwal,
        ),
      ),
    );
  }

  Widget _buildPengeluaranSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GlassmorphismCard(
        glowColor: AppColors.categoryKeuangan,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pengeluaran Hari Ini',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSubText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp 150.000',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.categoryKeuangan,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.categoryKeuangan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_down,
                    color: AppColors.categoryKeuangan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatatanSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: GlassmorphismCard(
        glowColor: AppColors.categoryScan,
        child: _buildDashboardItem(
          icon: Icons.image_outlined,
          title: 'Catatan Kuliah Basis Data',
          subtitle: 'Tanggal: 10 Mei 2026',
          color: AppColors.categoryScan,
        ),
      ),
    );
  }

  Widget _buildDashboardItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSubText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Handle notifikasi tap - navigate ke halaman yang sesuai
  void _handleNotificationTap(DashboardNotification notification) {
    switch (notification.type) {
      case NotificationType.deadline:
        // Navigate ke Tugas Page
        _navigateTo(1);
        break;
      case NotificationType.schedule:
        // Navigate ke Jadwal Page
        _navigateTo(4);
        break;
      case NotificationType.expense:
        // Navigate ke Keuangan Page
        _navigateTo(3);
        break;
    }
  }

  void _navigateTo(int index) {
    Widget nextPage;

    switch (index) {
      case 0:
        return; // Already on home page
      case 1:
        nextPage = const TugasPage();
        break;
      case 2:
        nextPage = const ScanPage();
        break;
      case 3:
        nextPage = const KeuanganPage();
        break;
      case 4:
        nextPage = const JadwalPage();
        break;
      case 5:
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
        _selectedIndex = 0; // Reset ke home setelah kembali
      });
    });
  }
}
