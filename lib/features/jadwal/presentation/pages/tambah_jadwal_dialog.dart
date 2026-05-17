import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/core/utils/time_helper.dart';
import 'package:campus_buddy/core/constants/app_colors.dart';

const uuid = Uuid();

class TambahJadwalDialog extends StatefulWidget {
  final Function(Jadwal) onSave;
  final Jadwal? jadwalEdit;

  const TambahJadwalDialog({super.key, required this.onSave, this.jadwalEdit});

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
    'Kuliah': AppColors.primary,
    'Tugas': AppColors.secondary,
    'Meeting': AppColors.accent,
    'Olahraga': AppColors.success,
    'Istirahat': AppColors.warning,
    'Lainnya': AppColors.gray500,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Judul Input
                TextField(
                  controller: judulController,
                  style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan',
                    hintText: 'Contoh: Kuliah Algoritma',
                    labelStyle: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
                    hintStyle: TextStyle(color: AppColors.gray300),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    prefixIcon: Icon(
                      Icons.event,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pilih Hari
                DropdownButtonFormField<String>(
                  initialValue: selectedHari,
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                  items: daftarHari
                      .map(
                        (hari) => DropdownMenuItem(
                          value: hari,
                          child: Text(
                            hari,
                            style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHari = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Pilih Hari',
                    labelStyle: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Jam Mulai & Selesai Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: jamMulaiController,
                        readOnly: true,
                        style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                        onTap: () => _selectTime(context, jamMulaiController),
                        decoration: InputDecoration(
                          labelText: 'Jam Mulai',
                          hintText: 'HH:MM',
                          labelStyle: TextStyle(
                            color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                          ),
                          hintStyle: TextStyle(
                            color: AppColors.gray300,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: AppColors.primary,
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: jamSelesaiController,
                        readOnly: true,
                        style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                        onTap: () => _selectTime(context, jamSelesaiController),
                        decoration: InputDecoration(
                          labelText: 'Jam Selesai',
                          hintText: 'HH:MM',
                          labelStyle: TextStyle(
                            color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                          ),
                          hintStyle: TextStyle(
                            color: AppColors.gray300,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: AppColors.primary,
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Kategori
                DropdownButtonFormField<String>(
                  initialValue: selectedKategori,
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
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
                              const SizedBox(width: 12),
                              Text(
                                kategori,
                                style: TextStyle(color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText)),
                              ),
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
                    labelStyle: TextStyle(color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    prefixIcon: Icon(
                      Icons.category,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle Notifikasi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aktifkan Notifikasi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '10 menit sebelum jadwal',
                                style: TextStyle(
                                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                                  fontSize: 12,
                                ),
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
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.lightSubText),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveJadwal,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.jadwalEdit != null ? 'Update' : 'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
