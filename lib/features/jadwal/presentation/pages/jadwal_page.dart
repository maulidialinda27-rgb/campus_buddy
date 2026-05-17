import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';

import 'package:campus_buddy/core/utils/time_helper.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/features/jadwal/presentation/pages/tambah_jadwal_dialog.dart';
import 'package:campus_buddy/services/jadwal_service.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  late JadwalService _jadwalService;

  List<Jadwal> _daftarJadwal = [];

  /// WARNA MODERN BARU
  final Color primaryColor = AppColors.primary;
  final Color secondaryColor = AppColors.secondary;

  final Map<String, Color> kategoriWarna = {
    'Kuliah': AppColors.primary,
    'Tugas': AppColors.secondary,
    'Meeting': AppColors.accent,
    'Olahraga': AppColors.success,
    'Istirahat': AppColors.warning,
    'Lainnya': AppColors.gray500,
  };

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
    if (nextSchedule == null) {
      return const SizedBox.shrink();
    }

    final minutes = minutesUntilSchedule(nextSchedule.jamMulai);

    final kategoriColor =
        kategoriWarna[nextSchedule.deskripsi] ??
        kategoriWarna['Lainnya']!;

    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),

          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: AppColors.primary.withValues(alpha: 0.15),
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(
                Icons.schedule_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal Berikutnya',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    nextSchedule.judul,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: Colors.white,
                        size: 16,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        '${nextSchedule.jamMulai} • $minutes menit lagi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
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
      ),
    );
  }

  /// CARD JADWAL
  Widget _buildJadwalCard(
    Jadwal jadwal,
    Color kategoriColor,
    int index,
  ) {
    final isOngoing = isTimeInRange(
      jadwal.jamMulai,
      jadwal.jamSelesai,
    );

    final statusText = getScheduleStatus(
      jadwal.jamMulai,
      jadwal.jamSelesai,
    );

    return FadeInUp(
      delay: Duration(milliseconds: index * 100),

      child: Dismissible(
        key: Key(jadwal.id),

        onDismissed: (direction) {
          _deleteJadwal(jadwal.id);
        },

        background: Container(
          margin: const EdgeInsets.only(
            bottom: 16,
            left: 60,
          ),

          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(22),
          ),

          alignment: Alignment.centerRight,

          padding: const EdgeInsets.only(right: 20),

          child: Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),

        child: Container(
          margin: const EdgeInsets.only(
            bottom: 16,
            left: 60,
          ),

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,

            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: isOngoing
                  ? kategoriColor.withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.12),
              width: 1.5,
            ),

            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 6),
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
                  color: isOngoing
                      ? Colors.green
                      : kategoriColor,

                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 16),

              /// ISI
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                          style: TextStyle(
                            color: Colors.grey.shade800,
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
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                          decoration: BoxDecoration(
                            color: isOngoing
                                ? Colors.green.withValues(alpha: 
                                    0.12,
                                  )
                                : kategoriColor.withValues(alpha: 
                                    0.12,
                                  ),

                            borderRadius:
                                BorderRadius.circular(18),
                          ),

                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: isOngoing
                                  ? Colors.green
                                  : kategoriColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                          decoration: BoxDecoration(
                            color:
                                kategoriColor.withValues(alpha: 0.1),

                            borderRadius:
                                BorderRadius.circular(18),
                          ),

                          child: Text(
                            jadwal.deskripsi ?? 'Lainnya',
                            style: TextStyle(
                              color: kategoriColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
                    onPressed: () =>
                        _toggleNotifikasi(jadwal),

                    icon: Icon(
                      jadwal.notifikasi == 1
                          ? Icons.notifications_active
                          : Icons.notifications_off,

                      color: jadwal.notifikasi == 1
                          ? kategoriColor
                          : Colors.grey,

                      size: 22,
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showTambahJadwalDialog(
                          jadwalEdit: jadwal,
                        );
                      } else if (value == 'delete') {
                        _deleteJadwal(jadwal.id);
                      }
                    },

                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),

                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus'),
                      ),
                    ],

                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTambahJadwalDialog({
    Jadwal? jadwalEdit,
  }) async {
    showDialog(
      context: context,

      builder: (context) => TambahJadwalDialog(
        onSave: (jadwal) async {
          try {
            if (jadwalEdit != null) {
              await _jadwalService.updateJadwal(
                jadwal,
              );
            } else {
              await _jadwalService.addJadwal(
                jadwal,
              );
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
    await _jadwalService.toggleNotifikasi(
      jadwal.id,
    );

    if (!mounted) return;

    _loadJadwal();
  }

  @override
  Widget build(BuildContext context) {
    final nextSchedule = _getNextSchedule();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        iconTheme: IconThemeData(
          color: Colors.black,
        ),

        title: Text(
          'Jadwal',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        actions: [
          if (_daftarJadwal.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                right: 18,
              ),

              child: Center(
                child: Text(
                  '${_daftarJadwal.length} Jadwal',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),

      body: _daftarJadwal.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Container(
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,

                      borderRadius:
                          BorderRadius.circular(24),
                    ),

                    child: Icon(
                      Icons.event_note_rounded,
                      size: 70,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Belum ada jadwal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Tambahkan jadwal baru',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (nextSchedule != null)
                    _buildNextEventCard(nextSchedule),

                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: Stack(
                      children: [
                        Positioned(
                          left: 38,
                          top: 0,
                          bottom: 0,

                          child: Container(
                            width: 2,

                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 
                                0.25,
                              ),
                            ),
                          ),
                        ),

                        Column(
                          children: _daftarJadwal
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;

                            final jadwal = entry.value;

                            final kategoriColor =
                                kategoriWarna[
                                        jadwal.deskripsi] ??
                                    Colors.grey;

                            return _buildJadwalCard(
                              jadwal,
                              kategoriColor,
                              index,
                            );
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
        onPressed: () =>
            _showTambahJadwalDialog(),

        backgroundColor: primaryColor,

        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}