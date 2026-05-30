class CatatanModel {
  final String id;
  final String judul;
  final String isi;
  final DateTime dibuatPada;
  final DateTime diperbaruidPada;

  CatatanModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.dibuatPada,
    required this.diperbaruidPada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbaruidPada.toIso8601String(),
    };
  }

  factory CatatanModel.fromMap(Map<String, dynamic> map) {
    return CatatanModel(
      id: map['id'] as String,
      judul: map['judul'] as String,
      isi: map['isi'] as String? ?? '',
      dibuatPada: DateTime.parse(map['dibuat_pada'] as String),
      diperbaruidPada: DateTime.parse(map['diperbarui_pada'] as String),
    );
  }

  CatatanModel copyWith({
    String? id,
    String? judul,
    String? isi,
    DateTime? dibuatPada,
    DateTime? diperbaruidPada,
  }) {
    return CatatanModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbaruidPada: diperbaruidPada ?? this.diperbaruidPada,
    );
  }
}
