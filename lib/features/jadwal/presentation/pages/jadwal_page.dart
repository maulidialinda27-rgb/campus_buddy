import 'package:flutter/material.dart';

import 'package:campus_buddy/core/utils/time_helper.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/features/jadwal/presentation/pages/tambah_jadwal_dialog.dart';
import 'package:campus_buddy/services/jadwal_service.dart';
import 'package:campus_buddy/services/notification_service.dart';

class JadwalTheme {
  static const Color primary = Color(0xFFF59E0B);
  static const Map<String, Color> kategoriWarna = {
    'Kuliah': Color(0xFF4285F4),
    'Tugas': Color(0xFFEA4335),
    'Meeting': Color(0xFF64B5F6),
    'Olahraga': Color(0xFF34A853),
    'Istirahat': Color(0xFFFBBC05),
    'Lainnya': Color(0xFF64748B),
  };
}

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  late JadwalService _jadwalService;

  List<Jadwal> _daftarJadwal = [];

  final Color primaryColor = JadwalTheme.primary;
  final Map<String, Color> kategoriWarna = JadwalTheme.kategoriWarna;

  final List<String> daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    _jadwalService = JadwalService();
    _loadJadwal();
  }

  void _loadJadwal() {
    setState(() {
      _daftarJadwal = _jadwalService.getAllJadwal();

      _daftarJadwal.sort((a, b) {
        int hariA = daftarHari.indexOf(a.hari);
        int hariB = daftarHari.indexOf(b.hari);

        if (hariA != hariB) {
          return hariA.compareTo(hariB);
        }

        return a.jamMulai.compareTo(b.jamMulai);
      });
    });
  }

  Jadwal? _getNextSchedule() {
    final now = DateTime.now();

    for (var jadwal in _daftarJadwal) {
      final mulai = parseJam(jadwal.jamMulai);
      if (mulai.isAfter(now)) {
        return jadwal;
      }
    }

    return null;
  }

  /// CARD JADWAL BERIKUTNYA
  Widget _buildNextEventCard(Jadwal? nextSchedule) {
    if (nextSchedule == null) return const SizedBox.shrink();

    final minutes = minutesUntilSchedule(nextSchedule.jamMulai);
    final kategoriColor = kategoriWarna[nextSchedule.deskripsi] ?? kategoriWarna['Lainnya']!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: primaryColor.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal Berikutnya',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nextSchedule.judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${nextSchedule.jamMulai} • $minutes menit lagi',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 6,
            height: 55,
            decoration: BoxDecoration(
              color: kategoriColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  /// CARD JADWAL
  Widget _buildJadwalCard(Jadwal jadwal, Color kategoriColor, int index) {
    final isOngoing = isTimeInRange(jadwal.jamMulai, jadwal.jamSelesai);
    final statusText = getScheduleStatus(jadwal.jamMulai, jadwal.jamSelesai);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(jadwal.id),
      onDismissed: (direction) {
        _deleteJadwal(jadwal.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 60),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 60),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showTambahJadwalDialog(jadwalEdit: jadwal);
            },
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOngoing ? kategoriColor.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.04),
                  width: isOngoing ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITIK TIMELINE
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: isOngoing ? primaryColor : kategoriColor,
                      shape: BoxShape.circle,
                      boxShadow: isOngoing ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ] : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// ISI
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 16, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          jadwal.judul,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isOngoing
                                      ? primaryColor.withValues(alpha: 0.1)
                                      : kategoriColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isOngoing ? primaryColor : kategoriColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: kategoriColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.label_rounded, size: 12, color: kategoriColor),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        jadwal.deskripsi ?? 'Lainnya',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: kategoriColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// AKSI
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _toggleNotifikasi(jadwal),
                        icon: Icon(
                          jadwal.notifikasi == 1 ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                          color: jadwal.notifikasi == 1 ? primaryColor : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showTambahJadwalDialog(jadwalEdit: jadwal);
                          } else if (value == 'delete') {
                            _deleteJadwal(jadwal.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTambahJadwalDialog({Jadwal? jadwalEdit}) async {
    showDialog(
      context: context,
      builder: (context) => TambahJadwalDialog(
        onSave: (jadwal) async {
          try {
            if (jadwalEdit != null) {
              await _jadwalService.updateJadwal(jadwal);
            } else {
              await _jadwalService.addJadwal(jadwal);
            }
            if (!context.mounted) return;
            Navigator.pop(context);
            _loadJadwal();
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        jadwalEdit: jadwalEdit,
      ),
    );
  }

  Future<void> _deleteJadwal(String jadwalId) async {
    await _jadwalService.deleteJadwal(jadwalId);
    if (!mounted) return;
    _loadJadwal();
  }

  Future<void> _toggleNotifikasi(Jadwal jadwal) async {
    await _jadwalService.toggleNotifikasi(jadwal.id);
    if (!mounted) return;
    _loadJadwal();

    // Cek status baru setelah toggle
    final updatedList = _jadwalService.getAllJadwal();
    final updated = updatedList.firstWhere(
      (j) => j.id == jadwal.id,
      orElse: () => jadwal,
    );

    if (updated.notifikasi == 1) {
      // Tampilkan notifikasi langsung di layar HP sebagai konfirmasi
      await NotificationService().showImmediateNotification(
        id: jadwal.id.hashCode,
        title: '🔔 Notifikasi Aktif',
        body: 'Pengingat untuk "${jadwal.judul}" (${jadwal.jamMulai}) telah diaktifkan. Anda akan diingatkan 10 menit sebelumnya.',
        channelId: 'jadwal_channel',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Notifikasi diaktifkan! Cek status bar HP Anda.')),
              ],
            ),
            backgroundColor: JadwalTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.notifications_off, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Notifikasi dinonaktifkan'),
              ],
            ),
            backgroundColor: Colors.grey.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextSchedule = _getNextSchedule();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        title: Text(
          'Jadwal',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          if (_daftarJadwal.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_daftarJadwal.length} Jadwal',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _daftarJadwal.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.event_note_rounded, size: 70, color: primaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada jadwal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan jadwal kegiatan Anda',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  if (nextSchedule != null) _buildNextEventCard(nextSchedule),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 38,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Column(
                          children: _daftarJadwal.asMap().entries.map((entry) {
                            final index = entry.key;
                            final jadwal = entry.value;
                            final kategoriColor = kategoriWarna[jadwal.deskripsi] ?? kategoriWarna['Lainnya']!;
                            return _buildJadwalCard(jadwal, kategoriColor, index);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahJadwalDialog(),
        backgroundColor: primaryColor,
        elevation: 0,
        hoverElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}