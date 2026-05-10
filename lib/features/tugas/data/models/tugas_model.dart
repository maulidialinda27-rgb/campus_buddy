class Tugas {
  final String id;
  final String judul;
  final String? deskripsi;
  final String? deadline;
  final String? prioritas;
  final String status;
  final DateTime dibuatPada;
  final DateTime diperbarui;

  Tugas({
    required this.id,
    required this.judul,
    this.deskripsi,
    this.deadline,
    this.prioritas,
    this.status = 'pending',
    required this.dibuatPada,
    required this.diperbarui,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'deadline': deadline,
      'prioritas': prioritas,
      'status': status,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbarui.toIso8601String(),
    };
  }

  factory Tugas.fromMap(Map<String, dynamic> map) {
    return Tugas(
      id: map['id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      deadline: map['deadline'],
      prioritas: map['prioritas'],
      status: map['status'] ?? 'pending',
      dibuatPada: DateTime.parse(map['dibuat_pada']),
      diperbarui: DateTime.parse(map['diperbarui_pada']),
    );
  }

  Tugas copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? deadline,
    String? prioritas,
    String? status,
    DateTime? dibuatPada,
    DateTime? diperbarui,
  }) {
    return Tugas(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      deadline: deadline ?? this.deadline,
      prioritas: prioritas ?? this.prioritas,
      status: status ?? this.status,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
