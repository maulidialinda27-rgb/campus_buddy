/// Helper functions untuk time management

/// Parse jam format HH:MM ke DateTime hari ini
DateTime parseJam(String jam) {
  final parts = jam.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

/// Format DateTime ke HH:MM
String formatJam(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// Cek apakah waktu sekarang berada dalam range
bool isTimeInRange(String jamMulai, String jamSelesai) {
  final now = DateTime.now();
  final mulai = parseJam(jamMulai);
  final selesai = parseJam(jamSelesai);

  // Adjust if selesai is next day
  var adjustedSelesai = selesai;
  if (selesai.isBefore(mulai)) {
    adjustedSelesai = selesai.add(const Duration(days: 1));
  }

  return now.isAfter(mulai) && now.isBefore(adjustedSelesai);
}

/// Hitung berapa menit sampai jadwal berikutnya
int minutesUntilSchedule(String jamMulai) {
  final now = DateTime.now();
  final jadwal = parseJam(jamMulai);

  if (jadwal.isBefore(now)) {
    // Jika sudah lewat hari ini, jadwal berikutnya besok
    final tomorrowJadwal = jadwal.add(const Duration(days: 1));
    return tomorrowJadwal.difference(now).inMinutes;
  }

  return jadwal.difference(now).inMinutes;
}

/// Format durasi dari jam mulai ke selesai
String formatDuration(String jamMulai, String jamSelesai) {
  final mulai = parseJam(jamMulai);
  final selesai = parseJam(jamSelesai);

  var adjustedSelesai = selesai;
  if (selesai.isBefore(mulai)) {
    adjustedSelesai = selesai.add(const Duration(days: 1));
  }

  final duration = adjustedSelesai.difference(mulai);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    return '${hours}j ${minutes}m';
  } else {
    return '${minutes}m';
  }
}

/// Get status string untuk jadwal
String getScheduleStatus(String jamMulai, String jamSelesai) {
  if (isTimeInRange(jamMulai, jamSelesai)) {
    return 'Sedang berlangsung';
  }

  final minutesUntil = minutesUntilSchedule(jamMulai);
  if (minutesUntil < 0) {
    return 'Selesai';
  } else if (minutesUntil == 0) {
    return 'Dimulai sekarang';
  } else if (minutesUntil < 60) {
    return 'Dalam $minutesUntil menit';
  } else if (minutesUntil < 1440) {
    final hours = minutesUntil ~/ 60;
    final mins = minutesUntil % 60;
    return 'Dalam ${hours}j ${mins}m';
  } else {
    final days = minutesUntil ~/ 1440;
    return 'Dalam $days hari';
  }
}

/// Validasi format jam
bool isValidTimeFormat(String time) {
  final parts = time.split(':');
  if (parts.length != 2) return false;

  try {
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
  } catch (e) {
    return false;
  }
}

/// Compare 2 jam (mulai < selesai?)
bool isValidTimeRange(String jamMulai, String jamSelesai) {
  try {
    final mulai = parseJam(jamMulai);
    final selesai = parseJam(jamSelesai);
    return mulai.isBefore(selesai) || selesai.isBefore(mulai); // Allow next day
  } catch (e) {
    return false;
  }
}
