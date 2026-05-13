import 'package:flutter/material.dart';
import 'package:campus_buddy/services/notification_service.dart';
import 'package:campus_buddy/services/jadwal_service.dart';
import 'app.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Notification Service
  final notificationService = NotificationService();
  await notificationService.initNotification();

  // Inisialisasi Jadwal Service
  final jadwalService = JadwalService();
  await jadwalService.init();

  // Jalankan aplikasi
  runApp(const CampusBuddyApp());
}
