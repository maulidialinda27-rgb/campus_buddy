import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:campus_buddy/features/jadwal/data/models/jadwal_model.dart';
import 'package:campus_buddy/core/utils/time_helper.dart';

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

  final Color primaryColor = const Color(0xFFF59E0B);
  
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
    'Kuliah': const Color(0xFF4285F4),
    'Tugas': const Color(0xFFEA4335),
    'Meeting': const Color(0xFF64B5F6),
    'Olahraga': const Color(0xFF34A853),
    'Istirahat': const Color(0xFFFBBC05),
    'Lainnya': const Color(0xFF64748B),
  };

  @override
  void initState() {
    super.initState();
    judulController = TextEditingController(text: widget.jadwalEdit?.judul ?? '');
    deskripsiController = TextEditingController(text: widget.jadwalEdit?.deskripsi ?? '');
    jamMulaiController = TextEditingController(text: widget.jadwalEdit?.jamMulai ?? '08:00');
    jamSelesaiController = TextEditingController(text: widget.jadwalEdit?.jamSelesai ?? '09:00');
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

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
        const SnackBar(content: Text('Jam selesai harus lebih besar dari jam mulai')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600;
    
    // Thin transparent border color
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04);
    final cardColor = isDark ? Theme.of(context).colorScheme.surface : Colors.white;
    final inputFillColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF9FAFB);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: cardColor,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
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
                      widget.jadwalEdit != null ? 'Edit Jadwal' : 'Tambah Jadwal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: subTextColor, size: 20),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Judul Input
                TextFormField(
                  controller: judulController,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  cursorColor: primaryColor,
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan',
                    hintText: 'Contoh: Kuliah Algoritma',
                    labelStyle: TextStyle(color: subTextColor),
                    floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: inputFillColor,
                    prefixIcon: Icon(Icons.event_note_rounded, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih Hari
                DropdownButtonFormField<String>(
                  initialValue: selectedHari,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
                  items: daftarHari.map((hari) => DropdownMenuItem(
                    value: hari,
                    child: Text(hari, style: TextStyle(color: textColor)),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedHari = value),
                  decoration: InputDecoration(
                    labelText: 'Pilih Hari',
                    labelStyle: TextStyle(color: subTextColor),
                    floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: inputFillColor,
                    prefixIcon: Icon(Icons.calendar_today_rounded, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Jam Mulai & Selesai Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: jamMulaiController,
                        readOnly: true,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        onTap: () => _selectTime(context, jamMulaiController),
                        decoration: InputDecoration(
                          labelText: 'Jam Mulai',
                          hintText: 'HH:MM',
                          labelStyle: TextStyle(color: subTextColor),
                          floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          prefixIcon: Icon(Icons.access_time_rounded, color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: jamSelesaiController,
                        readOnly: true,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        onTap: () => _selectTime(context, jamSelesaiController),
                        decoration: InputDecoration(
                          labelText: 'Jam Selesai',
                          hintText: 'HH:MM',
                          labelStyle: TextStyle(color: subTextColor),
                          floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          prefixIcon: Icon(Icons.access_time_rounded, color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kategori
                DropdownButtonFormField<String>(
                  initialValue: selectedKategori,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
                  items: kategoriWarna.keys.map((kategori) => DropdownMenuItem(
                    value: kategori,
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: kategoriWarna[kategori],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kategoriWarna[kategori]!.withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(kategori, style: TextStyle(color: textColor)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedKategori = value),
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(color: subTextColor),
                    floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: inputFillColor,
                    prefixIcon: Icon(Icons.category_rounded, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Toggle Notifikasi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 1),
                    borderRadius: BorderRadius.circular(16),
                    color: inputFillColor,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.notifications_active_rounded, color: primaryColor, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktifkan Notifikasi',
                              style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '10 menit sebelum jadwal',
                              style: TextStyle(color: subTextColor, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: enableNotifikasi,
                        onChanged: (value) => setState(() => enableNotifikasi = value),
                        activeColor: Colors.white,
                        activeTrackColor: primaryColor,
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: borderColor),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton(
                          onPressed: _saveJadwal,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            widget.jadwalEdit != null ? 'Update Jadwal' : 'Simpan Jadwal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
