import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
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

  final Map<String, Color> kategoriWarna = {
    'Kuliah': const Color(0xFF00D4FF), // Neon blue
    'Tugas': const Color(0xFF8B5CF6), // Purple
    'Meeting': const Color(0xFFFF5E78), // Neon pink
    'Olahraga': const Color(0xFF10B981), // Green
    'Istirahat': const Color(0xFF6366F1), // Indigo
    'Lainnya': const Color(0xFF64748B), // Gray
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
      // Urutkan berdasarkan hari dan jam mulai
      _daftarJadwal.sort((a, b) {
        int hariA = daftarHari.indexOf(a.hari);
        int hariB = daftarHari.indexOf(b.hari);
        if (hariA != hariB) return hariA.compareTo(hariB);
        return a.jamMulai.compareTo(b.jamMulai);
      });
    });
  }

  /// Dapatkan jadwal berikutnya yang akan datang
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

  /// Build next event card dengan desain modern
  Widget _buildNextEventCard(Jadwal? nextSchedule) {
    if (nextSchedule == null) {
      return const SizedBox.shrink();
    }

    final minutes = minutesUntilSchedule(nextSchedule.jamMulai);
    final kategoriColor =
        kategoriWarna[nextSchedule.deskripsi] ??
        kategoriWarna['Lainnya'] ??
        Colors.grey;

    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E293B), // Navy surface
              const Color(0xFF0F172A), // Darker navy
            ],
          ),
          border: Border.all(
            color: kategoriColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: kategoriColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kategoriColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kategoriColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(Icons.schedule, color: kategoriColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kegiatan Berikutnya',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nextSchedule.judul,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${nextSchedule.jamMulai} • Dalam $minutes menit',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: kategoriColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: kategoriColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build timeline style jadwal card
  Widget _buildJadwalCard(Jadwal jadwal, Color kategoriColor, int index) {
    final isOngoing = isTimeInRange(jadwal.jamMulai, jadwal.jamSelesai);
    final statusText = getScheduleStatus(jadwal.jamMulai, jadwal.jamSelesai);

    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      child: Dismissible(
        key: Key(jadwal.id),
        onDismissed: (direction) {
          _deleteJadwal(jadwal.id);
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 60),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 60),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1E293B), // Navy surface
            border: Border.all(
              color: isOngoing
                  ? kategoriColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isOngoing
                    ? kategoriColor.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: isOngoing ? Colors.green : kategoriColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: isOngoing
                      ? [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: kategoriColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time range
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${jadwal.jamMulai} – ${jadwal.jamSelesai}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      jadwal.judul,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Status and Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOngoing
                                ? Colors.green.withValues(alpha: 0.2)
                                : kategoriColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isOngoing
                                  ? Colors.green.withValues(alpha: 0.5)
                                  : kategoriColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOngoing ? Colors.green : kategoriColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kategoriColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kategoriColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            jadwal.deskripsi ?? 'Lainnya',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kategoriColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    onPressed: () => _toggleNotifikasi(jadwal),
                    icon: Icon(
                      jadwal.notifikasi == 1
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: jadwal.notifikasi == 1
                          ? kategoriColor
                          : Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 8),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTambahJadwalDialog({Jadwal? jadwalEdit}) async {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) => TambahJadwalDialog(
        onSave: (jadwal) async {
          final currentContext = context;
          final messenger = ScaffoldMessenger.of(currentContext);
          final navigator = Navigator.of(currentContext);
          try {
            if (jadwalEdit != null) {
              await _jadwalService.updateJadwal(jadwal);
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil diupdate')),
              );
            } else {
              await _jadwalService.addJadwal(jadwal);
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
              );
            }
            if (!mounted) return;
            navigator.pop();
            _loadJadwal();
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        jadwalEdit: jadwalEdit,
      ),
    );
  }

  Future<void> _deleteJadwal(String jadwalId) async {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final currentContext = context;
              final messenger = ScaffoldMessenger.of(currentContext);
              final navigator = Navigator.of(currentContext);
              try {
                await _jadwalService.deleteJadwal(jadwalId);
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Jadwal berhasil dihapus')),
                );
                _loadJadwal();
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleNotifikasi(Jadwal jadwal) async {
    try {
      await _jadwalService.toggleNotifikasi(jadwal.id);
      if (!mounted) return;
      _loadJadwal();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextSchedule = _getNextSchedule();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Navy background
      appBar: AppBar(
        title: const Text(
          AppStrings.jadwal,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B), // Navy surface
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_daftarJadwal.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Total: ${_daftarJadwal.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _daftarJadwal.isEmpty
          ? Center(
              child: FadeInUp(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.event_note,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Belum ada jadwal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan jadwal untuk memulai',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Next event card
                  if (nextSchedule != null) _buildNextEventCard(nextSchedule),

                  // Timeline header
                  if (nextSchedule != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Text(
                        'Jadwal Hari Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                  // Timeline container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      children: [
                        // Timeline line
                        Positioned(
                          left:
                              38, // Center of the 16px indicator + 22px margin
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),

                        // Schedule cards
                        Column(
                          children: _daftarJadwal.asMap().entries.map((entry) {
                            final index = entry.key;
                            final jadwal = entry.value;
                            final kategoriColor =
                                kategoriWarna[jadwal.deskripsi] ??
                                kategoriWarna['Lainnya'] ??
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

                  const SizedBox(height: 32),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahJadwalDialog(),
        backgroundColor: const Color(0xFF00D4FF), // Neon blue
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
