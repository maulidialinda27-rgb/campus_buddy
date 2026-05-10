class Profil {
  final String id;
  final String? nama;
  final String? email;
  final int modeGelap;
  final DateTime dibuatPada;
  final DateTime diperbarui;

  Profil({
    required this.id,
    this.nama,
    this.email,
    this.modeGelap = 0,
    required this.dibuatPada,
    required this.diperbarui,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'mode_gelap': modeGelap,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbarui.toIso8601String(),
    };
  }

  factory Profil.fromMap(Map<String, dynamic> map) {
    return Profil(
      id: map['id'],
      nama: map['nama'],
      email: map['email'],
      modeGelap: map['mode_gelap'] ?? 0,
      dibuatPada: DateTime.parse(map['dibuat_pada']),
      diperbarui: DateTime.parse(map['diperbarui_pada']),
    );
  }

  Profil copyWith({
    String? id,
    String? nama,
    String? email,
    int? modeGelap,
    DateTime? dibuatPada,
    DateTime? diperbarui,
  }) {
    return Profil(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      modeGelap: modeGelap ?? this.modeGelap,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
