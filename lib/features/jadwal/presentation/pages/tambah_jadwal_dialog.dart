import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/core/utils/time_helper.dart';

const uuid = Uuid();

class TambahJadwalDialog extends StatefulWidget {
  final Function(Jadwal) onSave;
  final Jadwal? jadwalEdit;

  const TambahJadwalDialog({Key? key, required this.onSave, this.jadwalEdit})
    : super(key: key);

  @override
  State<TambahJadwalDialog> createState() => _TambahJadwalDialogState();
}

class _TambahJadwalDialogState extends State<TambahJadwalDialog> {
  late TextEditingController judulController;
  late TextEditingController deskripsiController;
  late TextEditingController jamMulaiController;
  late TextEditingController jamSelesaiController;
  String? selectedHari;
  String? selectedKategori;
  bool enableNotifikasi = true;

  final List<String> daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final Map<String, Color> kategoriWarna = {
    'Kuliah': const Color(0xFF6366F1),
    'Tugas': const Color(0xFFF97316),
    'Meeting': const Color(0xFF8B5CF6),
    'Olahraga': const Color(0xFF10B981),
    'Istirahat': const Color(0xFF00D4FF),
    'Lainnya': const Color(0xFF64748B),
  };

  @override
  void initState() {
    super.initState();
    judulController = TextEditingController(
      text: widget.jadwalEdit?.judul ?? '',
    );
    deskripsiController = TextEditingController(
      text: widget.jadwalEdit?.deskripsi ?? '',
    );
    jamMulaiController = TextEditingController(
      text: widget.jadwalEdit?.jamMulai ?? '08:00',
    );
    jamSelesaiController = TextEditingController(
      text: widget.jadwalEdit?.jamSelesai ?? '09:00',
    );
    selectedHari = widget.jadwalEdit?.hari;
    enableNotifikasi = widget.jadwalEdit?.notifikasi == 1 ? true : false;
    selectedKategori = widget.jadwalEdit?.deskripsi ?? 'Kuliah';
  }

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    jamMulaiController.dispose();
    jamSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _saveJadwal() {
    if (judulController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul kegiatan tidak boleh kosong')),
      );
      return;
    }

    if (selectedHari == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih hari terlebih dahulu')),
      );
      return;
    }

    if (jamMulaiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jam mulai terlebih dahulu')),
      );
      return;
    }

    if (jamSelesaiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jam selesai terlebih dahulu')),
      );
      return;
    }

    if (!isValidTimeRange(jamMulaiController.text, jamSelesaiController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus lebih besar dari jam mulai'),
        ),
      );
      return;
    }

    final jadwal = Jadwal(
      id: widget.jadwalEdit?.id ?? uuid.v4(),
      judul: judulController.text,
      deskripsi: selectedKategori,
      hari: selectedHari!,
      jamMulai: jamMulaiController.text,
      jamSelesai: jamSelesaiController.text,
      notifikasi: enableNotifikasi ? 1 : 0,
      dibuatPada: widget.jadwalEdit?.dibuatPada ?? DateTime.now(),
      diperbarui: DateTime.now(),
    );

    widget.onSave(jadwal);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.jadwalEdit != null
                          ? 'Edit Jadwal'
                          : 'Tambah Jadwal',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Judul Input
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan',
                    hintText: 'Contoh: Kuliah Algoritma',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.event),
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih Hari
                DropdownButtonFormField<String>(
                  value: selectedHari,
                  items: daftarHari
                      .map(
                        (hari) =>
                            DropdownMenuItem(value: hari, child: Text(hari)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHari = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Pilih Hari',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),

                // Jam Mulai & Selesai Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: jamMulaiController,
                        readOnly: true,
                        onTap: () => _selectTime(context, jamMulaiController),
                        decoration: InputDecoration(
                          labelText: 'Jam Mulai',
                          hintText: 'HH:MM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: jamSelesaiController,
                        readOnly: true,
                        onTap: () => _selectTime(context, jamSelesaiController),
                        decoration: InputDecoration(
                          labelText: 'Jam Selesai',
                          hintText: 'HH:MM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kategori
                DropdownButtonFormField<String>(
                  value: selectedKategori,
                  items: kategoriWarna.keys
                      .map(
                        (kategori) => DropdownMenuItem(
                          value: kategori,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: kategoriWarna[kategori],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(kategori),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKategori = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle Notifikasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aktifkan Notifikasi',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '10 menit sebelum jadwal',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: enableNotifikasi,
                        onChanged: (value) {
                          setState(() {
                            enableNotifikasi = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveJadwal,
                        child: Text(
                          widget.jadwalEdit != null ? 'Update' : 'Simpan',
                        ),
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
}

class _TambahJadwalDialogState extends State<TambahJadwalDialog> {
  late TextEditingController judulController;
  late TextEditingController deskripsiController;
  late TextEditingController jamController;
  String? selectedHari;
  String? selectedKategori;
  bool enableNotifikasi = true;

  final List<String> daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final Map<String, Color> kategoriWarna = {
    'Kuliah': const Color(0xFF6366F1),
    'Tugas': const Color(0xFFF97316),
    'Meeting': const Color(0xFF8B5CF6),
    'Olahraga': const Color(0xFF10B981),
    'Istirahat': const Color(0xFF6366F1),
    'Lainnya': const Color(0xFF64748B),
  };

  @override
  void initState() {
    super.initState();
    judulController = TextEditingController(
      text: widget.jadwalEdit?.judul ?? '',
    );
    deskripsiController = TextEditingController(
      text: widget.jadwalEdit?.deskripsi ?? '',
    );
    jamController = TextEditingController(text: widget.jadwalEdit?.jam ?? '');
    selectedHari = widget.jadwalEdit?.hari;
    enableNotifikasi = widget.jadwalEdit?.notifikasi == 1 ? true : false;
    selectedKategori = 'Kuliah';
  }

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    jamController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      jamController.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _saveJadwal() {
    if (judulController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul kegiatan tidak boleh kosong')),
      );
      return;
    }

    if (selectedHari == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih hari terlebih dahulu')),
      );
      return;
    }

    if (jamController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jam terlebih dahulu')),
      );
      return;
    }

    final jadwal = Jadwal(
      id: widget.jadwalEdit?.id ?? uuid.v4(),
      judul: judulController.text,
      deskripsi: deskripsiController.text.isNotEmpty
          ? deskripsiController.text
          : null,
      hari: selectedHari!,
      jam: jamController.text,
      notifikasi: enableNotifikasi ? 1 : 0,
      dibuatPada: widget.jadwalEdit?.dibuatPada ?? DateTime.now(),
      diperbarui: DateTime.now(),
    );

    widget.onSave(jadwal);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.jadwalEdit != null
                          ? 'Edit Jadwal'
                          : 'Tambah Jadwal',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Judul Input
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan',
                    hintText: 'Contoh: Kuliah Algoritma',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.event),
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi Input
                TextField(
                  controller: deskripsiController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    hintText: 'Tambahkan catatan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Pilih Hari
                DropdownButtonFormField<String>(
                  value: selectedHari,
                  items: daftarHari
                      .map(
                        (hari) =>
                            DropdownMenuItem(value: hari, child: Text(hari)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHari = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Pilih Hari',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih Jam
                TextField(
                  controller: jamController,
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  decoration: InputDecoration(
                    labelText: 'Pilih Jam',
                    hintText: 'HH:MM',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 16),

                // Kategori
                DropdownButtonFormField<String>(
                  value: selectedKategori,
                  items: kategoriWarna.keys
                      .map(
                        (kategori) => DropdownMenuItem(
                          value: kategori,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: kategoriWarna[kategori],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(kategori),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKategori = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle Notifikasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aktifkan Notifikasi',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '10 menit sebelum jadwal',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: enableNotifikasi,
                        onChanged: (value) {
                          setState(() {
                            enableNotifikasi = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveJadwal,
                        child: Text(
                          widget.jadwalEdit != null ? 'Update' : 'Simpan',
                        ),
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
}
