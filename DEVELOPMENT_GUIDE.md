# DEVELOPMENT GUIDE - CampusBuddy

## 📖 Panduan Pengembangan Aplikasi CampusBuddy

Dokumen ini berisi panduan lengkap untuk melanjutkan dan mengembangkan aplikasi CampusBuddy.

---

## 🎯 Struktur Proyek yang Telah Dibuat

### Core Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # Konstanta aplikasi
│   │   ├── app_colors.dart         # Palet warna
│   │   ├── app_strings.dart        # String teks
│   │   └── index.dart              # Export semua constants
│   └── theme/
│       ├── app_theme.dart          # Light & Dark theme
│       └── index.dart
├── database/
│   └── database_helper.dart        # SQLite helper
├── models/
│   └── profil_model.dart          # Profil model
├── widgets/
│   ├── custom_buttons.dart         # Custom button widgets
│   ├── custom_cards.dart           # Custom card widgets
│   └── index.dart
└── features/
    ├── home/
    ├── tugas/
    ├── scan/
    ├── keuangan/
    ├── jadwal/
    └── profil/
```

---

## 🔧 Setup Awal

### 1. Dependencies Yang Sudah Ter-Install

```dart
// Database & Local Storage
sqflite              // SQLite management
path                 // Path operations

// UI & Design
google_fonts         // Plus Jakarta Sans font
animate_do           // Widget animations
lottie               // Lottie animations
get                  // Navigation & state management

// Notifications
flutter_local_notifications
timezone             // Timezone support

// Image & Media
image_picker         // Camera & gallery

// Utilities
intl                 // Date/time formatting
uuid                 // Unique ID generation
```

### 2. Struktur Feature

Setiap feature mengikuti pola:

```
feature_name/
├── presentation/
│   ├── pages/         # UI pages
│   └── widgets/       # Feature-specific widgets
└── data/
    └── models/        # Data models
```

---

## 📝 Next Steps - Pengembangan Selanjutnya

### Phase 1: Implementasi CRUD Fitur Tugas

#### 1.1 Buat UI untuk Tambah Tugas

File: `lib/features/tugas/presentation/pages/tambah_tugas_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:campus_buddy/widgets/custom_buttons.dart';
// ... imports lainnya

class TambahTugasPage extends StatefulWidget {
  const TambahTugasPage({Key? key}) : super(key: key);

  @override
  State<TambahTugasPage> createState() => _TambahTugasPageState();
}

class _TambahTugasPageState extends State<TambahTugasPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  String? _prioritas;
  String? _deadline;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController();
    _deskripsiController = TextEditingController();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Form fields akan ditambahkan di sini
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 1.2 Implementasi CRUD Operations

Tambahkan service di folder `lib/features/tugas/data/services/`:

```dart
// File: tugas_service.dart
import 'package:campus_buddy/database/database_helper.dart';
import 'package:campus_buddy/features/tugas/data/models/tugas_model.dart';
import 'package:uuid/uuid.dart';

class TugasService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Create
  Future<String> tambahTugas(Tugas tugas) async {
    return await _dbHelper.insertTugas(tugas.toMap());
  }

  // Read
  Future<List<Tugas>> getAllTugas() async {
    final data = await _dbHelper.getAllTugas();
    return data.map((map) => Tugas.fromMap(map)).toList();
  }

  // Update
  Future<int> updateTugas(Tugas tugas) async {
    return await _dbHelper.updateTugas(tugas.toMap());
  }

  // Delete
  Future<int> deleteTugas(String id) async {
    return await _dbHelper.deleteTugas(id);
  }
}
```

### Phase 2: State Management dengan GetX

Buat controller untuk setiap fitur:

```dart
// File: lib/features/tugas/presentation/controllers/tugas_controller.dart
import 'package:get/get.dart';
import 'package:campus_buddy/features/tugas/data/models/tugas_model.dart';
import 'package:campus_buddy/features/tugas/data/services/tugas_service.dart';

class TugasController extends GetxController {
  final tugasService = TugasService();

  final tugasList = <Tugas>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTugas();
  }

  void loadTugas() async {
    try {
      isLoading.value = true;
      final tugas = await tugasService.getAllTugas();
      tugasList.assignAll(tugas);
    } finally {
      isLoading.value = false;
    }
  }

  void addTugas(Tugas tugas) async {
    await tugasService.tambahTugas(tugas);
    loadTugas();
  }

  void deleteTugas(String id) async {
    await tugasService.deleteTugas(id);
    loadTugas();
  }
}
```

### Phase 3: Implementasi Image Picker untuk Scan

```dart
// File: lib/features/scan/data/services/image_service.dart
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return null;

      // Simpan ke app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${appDir.path}/$fileName';

      // Copy file
      await photo.saveTo(savedPath);
      return savedPath;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${appDir.path}/$fileName';

      await image.saveTo(savedPath);
      return savedPath;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
```

### Phase 4: Setup Notifikasi

```dart
// File: lib/core/utils/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'campus_buddy_channel',
          'CampusBuddy Notifications',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
```

---

## 🔄 Git Workflow

### Branching Strategy

```bash
# Main branches
- main          # Production ready
- develop       # Development

# Feature branches
git checkout -b feature/tambah-fitur-tugas

# Bug fix branches
git checkout -b bugfix/fix-issue-name

# Hotfix branches
git checkout -b hotfix/critical-fix
```

### Commit Message Format

```
# Format: <type>(<scope>): <subject>

Examples:
feat(tugas): tambah fitur tambah tugas
fix(scan): perbaiki error image picker
docs(readme): update dokumentasi
refactor(core): reorganisasi struktur theme
test(tugas): tambah unit test untuk tugas service
```

---

## 🧪 Testing

### Unit Testing untuk Service

```dart
// File: test/features/tugas/data/services/tugas_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_buddy/features/tugas/data/models/tugas_model.dart';
import 'package:campus_buddy/features/tugas/data/services/tugas_service.dart';

void main() {
  group('TugasService', () {
    late TugasService tugasService;

    setUp(() {
      tugasService = TugasService();
    });

    test('tambahTugas should return id', () async {
      final tugas = Tugas(
        id: '1',
        judul: 'Buat Laporan',
        prioritas: 'High',
        dibuatPada: DateTime.now(),
        diperbarui: DateTime.now(),
      );

      final result = await tugasService.tambahTugas(tugas);
      expect(result, isNotNull);
    });
  });
}
```

---

## 📊 Checklist Fitur Implementation

### Tugas Feature

- [ ] Create tambah_tugas_page.dart
- [ ] Create edit_tugas_page.dart
- [ ] Create tugas_service.dart
- [ ] Create tugas_controller.dart
- [ ] Update tugas_page.dart untuk display list
- [ ] Add delete functionality
- [ ] Add filter & search
- [ ] Add unit tests

### Scan Feature

- [ ] Create scan_service.dart
- [ ] Create scan_controller.dart
- [ ] Implement camera integration
- [ ] Implement gallery integration
- [ ] Display scan list
- [ ] Add delete functionality

### Keuangan Feature

- [ ] Create keuangan_service.dart
- [ ] Create kategori_constants.dart
- [ ] Implement add transaction
- [ ] Display transactions
- [ ] Add category filter
- [ ] Generate reports

### Jadwal Feature

- [ ] Create jadwal_service.dart
- [ ] Implement notification scheduling
- [ ] Display jadwal list
- [ ] Add edit/delete functionality
- [ ] Test notifications

---

## 🚨 Common Issues & Solutions

### Issue: Image picker tidak bekerja

```dart
// Solution: Tambah permissions ke AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### Issue: Database sudah ada tapi ingin reset

```bash
# Delete app dan reinstall
# Database akan otomatis dibuat ulang
```

### Issue: GetX controller tidak update UI

```dart
// Gunakan .obs untuk observable
final tugasList = <Tugas>[].obs;

// Update dengan assign
tugasList.assignAll(newList);
```

---

## 📚 Referensi Berguna

- Flutter Documentation: https://flutter.dev/docs
- SQLite in Flutter: https://pub.dev/packages/sqflite
- GetX Documentation: https://github.com/jonataslaw/getx
- Image Picker: https://pub.dev/packages/image_picker
- Local Notifications: https://pub.dev/packages/flutter_local_notifications

---

## 📞 Bantuan & Support

Jika ada masalah atau pertanyaan:

1. Cek documentation yang relevan
2. Search issue di GitHub
3. Buat issue baru jika tidak menemukan solusi

---

**Happy Coding! 🚀**

Last Updated: May 10, 2026
