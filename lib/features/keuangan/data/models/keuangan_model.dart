class Keuangan {
  final String id;
  final double jumlah;
  final String kategori;
  final String? deskripsi;
  final String tanggal;
  final DateTime dibuatPada;
  final DateTime diperbarui;

  Keuangan({
    required this.id,
    required this.jumlah,
    required this.kategori,
    this.deskripsi,
    required this.tanggal,
    required this.dibuatPada,
    required this.diperbarui,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jumlah': jumlah,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'tanggal': tanggal,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbarui.toIso8601String(),
    };
  }

  factory Keuangan.fromMap(Map<String, dynamic> map) {
    return Keuangan(
      id: map['id'],
      jumlah: map['jumlah'].toDouble(),
      kategori: map['kategori'],
      deskripsi: map['deskripsi'],
      tanggal: map['tanggal'],
      dibuatPada: DateTime.parse(map['dibuat_pada']),
      diperbarui: DateTime.parse(map['diperbarui_pada']),
    );
  }

  Keuangan copyWith({
    String? id,
    double? jumlah,
    String? kategori,
    String? deskripsi,
    String? tanggal,
    DateTime? dibuatPada,
    DateTime? diperbarui,
  }) {
    return Keuangan(
      id: id ?? this.id,
      jumlah: jumlah ?? this.jumlah,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      tanggal: tanggal ?? this.tanggal,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
