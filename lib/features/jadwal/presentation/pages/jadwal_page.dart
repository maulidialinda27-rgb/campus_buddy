import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:campus_buddy/core/constants/app_strings.dart';
import 'package:campus_buddy/core/utils/time_helper.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/features/jadwal/presentation/pages/tambah_jadwal_dialog.dart';
import 'package:campus_buddy/services/jadwal_service.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({Key? key}) : super(key: key);

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  late JadwalService _jadwalService;
  List<Jadwal> _daftarJadwal = [];

  final Map<String, Color> kategoriWarna = {
    'Kuliah': const Color(0xFF6366F1),
    'Tugas': const Color(0xFFF97316),
    'Meeting': const Color(0xFF8B5CF6),
    'Olahraga': const Color(0xFF10B981),
    'Istirahat': const Color(0xFF00D4FF),
    'Lainnya': const Color(0xFF64748B),
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

  /// Build next event card
  Widget _buildNextEventCard(Jadwal? nextSchedule) {
    if (nextSchedule == null) {
      return const SizedBox.shrink();
    }

    final minutes = minutesUntilSchedule(nextSchedule.jamMulai);
    final kategoriColor =
        kategoriWarna[nextSchedule.deskripsi] ??
        kategoriWarna['Lainnya'] ??
        Colors.grey;

    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kategoriColor.withOpacity(0.8),
              kategoriColor.withOpacity(0.4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: kategoriColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.schedule, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kegiatan Berikutnya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextSchedule.judul,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dalam $minutes menit • ${nextSchedule.jamMulai}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build jadwal card dengan status
  Widget _buildJadwalCard(Jadwal jadwal, Color kategoriColor) {
    final isOngoing = isTimeInRange(jadwal.jamMulai, jadwal.jamSelesai);
    final statusText = getScheduleStatus(jadwal.jamMulai, jadwal.jamSelesai);
    final durationText = formatDuration(jadwal.jamMulai, jadwal.jamSelesai);

    return FadeInUp(
      child: Dismissible(
        key: Key(jadwal.id),
        onDismissed: (direction) {
          _deleteJadwal(jadwal.id);
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kategoriColor.withOpacity(0.3), width: 2),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: kategoriColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Time + Status + Notifikasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Time range
                    Expanded(
                      child: Row(
                        children: [
                          // Indicator dot
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isOngoing ? Colors.green : kategoriColor,
                              shape: BoxShape.circle,
                              boxShadow: isOngoing
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.5),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${jadwal.jamMulai} – ${jadwal.jamSelesai}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                durationText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Notifikasi toggle
                    IconButton(
                      onPressed: () => _toggleNotifikasi(jadwal),
                      icon: Icon(
                        jadwal.notifikasi == 1
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: jadwal.notifikasi == 1
                            ? kategoriColor
                            : Colors.grey,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Judul kegiatan
                Text(
                  jadwal.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Status & Kategori
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
                            ? Colors.green.withOpacity(0.1)
                            : kategoriColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOngoing
                              ? Colors.green.withOpacity(0.3)
                              : kategoriColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOngoing ? Colors.green : kategoriColor,
                        ),
                      ),
                    ),
                    // Kategori badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kategoriColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kategoriColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        jadwal.deskripsi ?? 'Lainnya',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kategoriColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          _showTambahJadwalDialog(jadwalEdit: jadwal),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteJadwal(jadwal.id),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Hapus'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil diupdate')),
              );
            } else {
              await _jadwalService.addJadwal(jadwal);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
              );
            }
            Navigator.pop(context);
            _loadJadwal();
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
          }
        },
        jadwalEdit: jadwalEdit,
      ),
    );
  }

  Future<void> _deleteJadwal(String jadwalId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _jadwalService.deleteJadwal(jadwalId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jadwal berhasil dihapus')),
                );
                _loadJadwal();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
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
      _loadJadwal();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextSchedule = _getNextSchedule();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.jadwal),
        elevation: 0,
        actions: [
          if (_daftarJadwal.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Total: ${_daftarJadwal.length}',
                  style: const TextStyle(fontSize: 14),
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
                    Icon(
                      Icons.event_note,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada jadwal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan jadwal untuk memulai',
                      style: TextStyle(color: Colors.grey),
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

                  // All schedules
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (nextSchedule != null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Semua Jadwal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ..._daftarJadwal.map((jadwal) {
                          final kategoriColor =
                              kategoriWarna[jadwal.deskripsi] ??
                              kategoriWarna['Lainnya'] ??
                              Colors.grey;
                          return _buildJadwalCard(jadwal, kategoriColor);
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahJadwalDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _JadwalPageState extends State<JadwalPage> {
  late JadwalService _jadwalService;
  List<Jadwal> _daftarJadwal = [];

  final Map<String, Color> kategoriWarna = {
    'Kuliah': const Color(0xFF6366F1),
    'Tugas': const Color(0xFFF97316),
    'Meeting': const Color(0xFF8B5CF6),
    'Olahraga': const Color(0xFF10B981),
    'Istirahat': const Color(0xFF6366F1),
    'Lainnya': const Color(0xFF64748B),
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
      // Urutkan berdasarkan hari
      _daftarJadwal.sort((a, b) {
        int hariA = daftarHari.indexOf(a.hari);
        int hariB = daftarHari.indexOf(b.hari);
        return hariA.compareTo(hariB);
      });
    });
  }

  Future<void> _showTambahJadwalDialog({Jadwal? jadwalEdit}) async {
    showDialog(
      context: context,
      builder: (context) => TambahJadwalDialog(
        onSave: (jadwal) async {
          try {
            if (jadwalEdit != null) {
              await _jadwalService.updateJadwal(jadwal);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil diupdate')),
              );
            } else {
              await _jadwalService.addJadwal(jadwal);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
              );
            }
            Navigator.pop(context);
            _loadJadwal();
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
          }
        },
        jadwalEdit: jadwalEdit,
      ),
    );
  }

  Future<void> _deleteJadwal(String jadwalId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _jadwalService.deleteJadwal(jadwalId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jadwal berhasil dihapus')),
                );
                _loadJadwal();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
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
      _loadJadwal();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notifikasi ${jadwal.notifikasi == 1 ? "dimatikan" : "diaktifkan"}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.jadwal),
        elevation: 0,
        actions: [
          if (_daftarJadwal.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Total: ${_daftarJadwal.length}',
                  style: const TextStyle(fontSize: 14),
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
                    Icon(
                      Icons.event_note,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada jadwal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan jadwal untuk memulai',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : FadeInUp(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _daftarJadwal.length,
                itemBuilder: (context, index) {
                  final jadwal = _daftarJadwal[index];
                  final kategoriColor =
                      kategoriWarna[jadwal.deskripsi] ??
                      kategoriWarna['Lainnya'] ??
                      Colors.grey;

                  return Dismissible(
                    key: Key(jadwal.id),
                    onDismissed: (direction) {
                      _deleteJadwal(jadwal.id);
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: kategoriColor, width: 4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Judul dan Notifikasi
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          jadwal.judul,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          jadwal.hari,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _toggleNotifikasi(jadwal),
                                    icon: Icon(
                                      jadwal.notifikasi == 1
                                          ? Icons.notifications_active
                                          : Icons.notifications_off,
                                      color: jadwal.notifikasi == 1
                                          ? kategoriColor
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Jam
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    jadwal.jam,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              if (jadwal.deskripsi != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: kategoriColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      jadwal.deskripsi ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 12),

                              // Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showTambahJadwalDialog(
                                      jadwalEdit: jadwal,
                                    ),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _deleteJadwal(jadwal.id),
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahJadwalDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
