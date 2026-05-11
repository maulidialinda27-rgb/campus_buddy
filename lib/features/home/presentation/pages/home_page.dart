import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/core/constants/app_constants.dart';
import 'package:campus_buddy/widgets/custom_cards.dart';
import 'package:campus_buddy/features/tugas/presentation/pages/tugas_page.dart';
import 'package:campus_buddy/features/scan/presentation/pages/scan_page.dart';
import 'package:campus_buddy/features/keuangan/presentation/pages/keuangan_page.dart';
import 'package:campus_buddy/features/jadwal/presentation/pages/jadwal_page.dart';
import 'package:campus_buddy/features/profil/presentation/pages/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
            child: Container(color: AppColors.darkSurface.withOpacity(0.1)),
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
              AppColors.darkBg.withOpacity(0.9),
              AppColors.darkBg.withOpacity(0.8),
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
        style: GoogleFonts.plusJakartaSans(
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSubText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp 150.000',
                      style: GoogleFonts.plusJakartaSans(
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
                    color: AppColors.categoryKeuangan.withOpacity(0.1),
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
            color: color.withOpacity(0.1),
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
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

  String _getMenuName(int index) {
    switch (index) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Tugas';
      case 2:
        return 'Scan';
      case 3:
        return 'Keuangan';
      case 4:
        return 'Jadwal';
      case 5:
        return 'Profil';
      default:
        return '';
    }
  }
}
