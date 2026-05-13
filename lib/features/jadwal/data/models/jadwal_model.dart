class Jadwal {
  final String id;
  final String judul;
  final String? deskripsi;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final int notifikasi;
  final DateTime dibuatPada;
  final DateTime diperbarui;

  Jadwal({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    this.notifikasi = 1,
    required this.dibuatPada,
    required this.diperbarui,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'notifikasi': notifikasi,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbarui.toIso8601String(),
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      hari: map['hari'],
      jamMulai: map['jam_mulai'] ?? map['jam'] ?? '00:00', // Support old data
      jamSelesai:
          map['jam_selesai'] ?? map['jam'] ?? '00:00', // Support old data
      notifikasi: map['notifikasi'] ?? 1,
      dibuatPada: DateTime.parse(map['dibuat_pada']),
      diperbarui: DateTime.parse(map['diperbarui_pada']),
    );
  }

  Jadwal copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
    int? notifikasi,
    DateTime? dibuatPada,
    DateTime? diperbarui,
  }) {
    return Jadwal(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      hari: hari ?? this.hari,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      notifikasi: notifikasi ?? this.notifikasi,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
