import 'package:flutter/material.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';
import 'package:campus_buddy/services/tugas_service.dart';
import 'package:campus_buddy/services/jadwal_service.dart';

import 'package:campus_buddy/services/local_storage_service.dart';
import 'package:campus_buddy/services/catatan_service.dart';

class GlobalSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Cari Tugas, Jadwal, Keuangan...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) ?? Colors.grey),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'Ketik untuk mulai mencari...',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText,
              ),
            ),
          ],
        ),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<List<SearchResult>>(
      future: _performSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada hasil untuk "$query"',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).colorScheme.surface,
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: result.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(result.icon, color: result.color),
                ),
                title: Text(
                  result.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PlusJakartaSans',
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  result.subtitle,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                trailing: Text(
                  result.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: result.color,
                  ),
                ),
                onTap: () {
                  // Kita bisa navigasi ke route spesifik berdasarkan kategori
                  close(context, '');
                  if (result.category == 'Tugas') {
                    Navigator.pushNamed(context, '/tugas');
                  } else if (result.category == 'Jadwal') {
                    Navigator.pushNamed(context, '/jadwal');
                  } else if (result.category == 'Keuangan') {
                    Navigator.pushNamed(context, '/keuangan');
                  } else if (result.category == 'Scan OCR') {
                    Navigator.pushNamed(context, '/scan');
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<List<SearchResult>> _performSearch(String query) async {
    final lowerQuery = query.toLowerCase();
    List<SearchResult> results = [];

    // 1. Search Tugas
    final tugasList = await TugasService().getAllTugas();
    for (var tugas in tugasList) {
      if (tugas.judul.toLowerCase().contains(lowerQuery) || (tugas.deskripsi?.toLowerCase().contains(lowerQuery) ?? false)) {
        results.add(SearchResult(
          title: tugas.judul,
          subtitle: tugas.deskripsi ?? '',
          category: 'Tugas',
          icon: Icons.assignment_rounded,
          color: AppColors.primary,
        ));
      }
    }

    // 2. Search Jadwal
    final jadwalList = JadwalService().getAllJadwal();
    for (var jadwal in jadwalList) {
      if (jadwal.judul.toLowerCase().contains(lowerQuery) || (jadwal.deskripsi?.toLowerCase().contains(lowerQuery) ?? false)) {
        results.add(SearchResult(
          title: jadwal.judul,
          subtitle: '${jadwal.hari} - ${jadwal.jamMulai} s.d ${jadwal.jamSelesai}',
          category: 'Jadwal',
          icon: Icons.calendar_month_rounded,
          color: AppColors.warning,
        ));
      }
    }

    // 3. Search Keuangan (via LocalStorage for now)
    final expensesData = await LocalStorageService.instance.loadJsonList('keuangan_expenses');
    for (var expense in expensesData) {
      final title = (expense['title'] ?? '').toString();
      final category = (expense['category'] ?? '').toString();
      if (title.toLowerCase().contains(lowerQuery) || category.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          title: title,
          subtitle: 'Rp ${expense['amount']}',
          category: 'Keuangan',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.success,
        ));
      }
    }

    // 4. Search Scan OCR (via LocalStorage)
    final scans = await LocalStorageService.instance.loadJsonList('scan_list');
    for (var scan in scans) {
      final judul = (scan['judul'] ?? '').toString();
      final deskripsi = (scan['deskripsi'] ?? '').toString();
      if (judul.toLowerCase().contains(lowerQuery) || deskripsi.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          title: judul.isEmpty ? 'Catatan Scan' : judul,
          subtitle: deskripsi.length > 30 ? '${deskripsi.substring(0, 30)}...' : deskripsi,
          category: 'Scan OCR',
          icon: Icons.document_scanner_rounded,
          color: AppColors.secondary,
        ));
      }
    }

    // 5. Search Catatan Manual
    final catatanList = await CatatanService().getAllCatatan();
    for (var catatan in catatanList) {
      if (catatan.judul.toLowerCase().contains(lowerQuery) || catatan.isi.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          title: catatan.judul,
          subtitle: catatan.isi.length > 40 ? '${catatan.isi.substring(0, 40)}...' : catatan.isi,
          category: 'Catatan',
          icon: Icons.sticky_note_2_rounded,
          color: AppColors.vibrantPurple,
        ));
      }
    }

    return results;
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
  });
}
