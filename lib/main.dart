import 'package:flutter/material.dart';
import 'package:campus_buddy/services/notification_service.dart';
import 'package:campus_buddy/services/local_storage_service.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale id_ID untuk DateFormat
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Notification Service + minta izin otomatis
  await NotificationService().initNotification();

  // Inisialisasi local storage
  await LocalStorageService.instance.init();

  // Jalankan aplikasi
  runApp(const CampusBuddyApp());
}
