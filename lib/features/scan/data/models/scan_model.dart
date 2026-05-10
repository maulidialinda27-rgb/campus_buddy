class Scan {
  final String id;
  final String? judul;
  final String? deskripsi;
  final String fotoPath;
  final DateTime dibuatPada;
  final DateTime diperbarui;

  Scan({
    required this.id,
    this.judul,
    this.deskripsi,
    required this.fotoPath,
    required this.dibuatPada,
    required this.diperbarui,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'foto_path': fotoPath,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbarui.toIso8601String(),
    };
  }

  factory Scan.fromMap(Map<String, dynamic> map) {
    return Scan(
      id: map['id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      fotoPath: map['foto_path'],
      dibuatPada: DateTime.parse(map['dibuat_pada']),
      diperbarui: DateTime.parse(map['diperbarui_pada']),
    );
  }

  Scan copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? fotoPath,
    DateTime? dibuatPada,
    DateTime? diperbarui,
  }) {
    return Scan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoPath: fotoPath ?? this.fotoPath,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
