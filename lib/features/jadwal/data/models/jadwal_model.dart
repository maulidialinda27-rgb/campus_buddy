class Jadwal {
  final String id;
  final String judul;
  final String? deskripsi;
  final String hari;
  final String jam;
  final int notifikasi;
  final DateTime dibuatPada;
  final DateTime diperbarui;

  Jadwal({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.hari,
    required this.jam,
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
      'jam': jam,
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
      jam: map['jam'],
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
    String? jam,
    int? notifikasi,
    DateTime? dibuatPada,
    DateTime? diperbarui,
  }) {
    return Jadwal(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      hari: hari ?? this.hari,
      jam: jam ?? this.jam,
      notifikasi: notifikasi ?? this.notifikasi,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
