# 🏗️ CampusBuddy - Architecture Overview

## Project Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Home Page  │  │  Tugas Page  │  │  Scan Page   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │Keuangan Page │  │ Jadwal Page  │  │ Profil Page  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                      ↓ Bottom Nav Bar ↓                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    WIDGET LAYER                            │
│                                                             │
│  Custom Buttons  │  Custom Cards  │  Category Badges      │
│  AnimatedWidgets │  GlassmorphismCards                     │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC LAYER                    │
│                    (Controllers/Services)                  │
│                                                             │
│  TugasService     │  ScanService   │  KeuanganService      │
│  JadwalService    │  ProfilService │  NotificationService  │
│                                                             │
│  (GetX Controllers - To be implemented)                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                              │
│                                                             │
│  ┌─────────────────────────────────────────────┐            │
│  │         Database Helper (SQLite)            │            │
│  │  - insertTugas()    - getAllTugas()         │            │
│  │  - insertScan()     - getAllScan()          │            │
│  │  - insertKeuangan() - getAllKeuangan()      │            │
│  │  - insertJadwal()   - getAllJadwal()        │            │
│  │  - insertProfil()   - getProfil()           │            │
│  └─────────────────────────────────────────────┘            │
│                                                             │
│  ┌──────────────────────────────────────────┐              │
│  │       Database (SQLite - Local)          │              │
│  │                                          │              │
│  │  [tugas] [scan] [keuangan]               │              │
│  │  [jadwal] [profil]                       │              │
│  └──────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

## Folder Structure with Descriptions

```
lib/
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart         ← Light & Dark themes
│   │   └── index.dart              ← Export themes
│   │
│   ├── constants/
│   │   ├── app_constants.dart      ← App-wide constants (routes, db table names)
│   │   ├── app_colors.dart         ← Color palette (light & dark)
│   │   ├── app_strings.dart        ← String constants (Indonesian)
│   │   └── index.dart              ← Export constants
│   │
│   └── utils/
│       └── (utilities to be added)
│
├── database/
│   └── database_helper.dart        ← SQLite CRUD operations
│
├── models/
│   └── profil_model.dart           ← Shared models
│
├── widgets/
│   ├── custom_buttons.dart         ← CustomButton, SecondaryButton
│   ├── custom_cards.dart           ← CustomCard, GlassmorphismCard
│   └── index.dart                  ← Export widgets
│
├── features/
│   │
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart           ← Dashboard/Beranda
│   │   │   └── widgets/
│   │   │       └── (home-specific widgets)
│   │   └── data/
│   │
│   ├── tugas/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── tugas_page.dart          ← Main tugas list
│   │   │   │   ├── tambah_tugas_page.dart   ← (to create)
│   │   │   │   └── edit_tugas_page.dart     ← (to create)
│   │   │   └── widgets/
│   │   │       └── (tugas-specific widgets)
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── tugas_model.dart         ← Tugas data class
│   │   └── (services to be added)
│   │
│   ├── scan/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── scan_page.dart           ← Scan interface
│   │   │   └── widgets/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── scan_model.dart          ← Scan data class
│   │   └── (services to be added)
│   │
│   ├── keuangan/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── keuangan_page.dart       ← Keuangan interface
│   │   │   └── widgets/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── keuangan_model.dart      ← Keuangan data class
│   │   └── (services to be added)
│   │
│   ├── jadwal/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── jadwal_page.dart         ← Jadwal interface
│   │   │   └── widgets/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── jadwal_model.dart        ← Jadwal data class
│   │   └── (services to be added)
│   │
│   └── profil/
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── profil_page.dart         ← Profil interface
│       │   └── widgets/
│       ├── data/
│       └── (services to be added)
│
├── app.dart                         ← MaterialApp setup
└── main.dart                        ← App entry point
```

## Data Flow - Example: Menambah Tugas

```
User Input
    ↓
[TambahTugasPage - Form]
    ↓
TugasController.addTugas(tugas)
    ↓
TugasService.tambahTugas(tugas)
    ↓
DatabaseHelper.insertTugas(tugas.toMap())
    ↓
SQLite Database - INSERT tugas table
    ↓
Return id/success
    ↓
TugasController - Update UI
    ↓
TugasPage - Display updated list
```

## Feature Implementation Checklist

### Tugas Feature

```
□ TugasPage (exists)
  └ Display list of tugas
  └ Show empty state
  └ Navigation to add/edit

□ TambahTugasPage (to create)
  └ Form with: judul, deskripsi, deadline, prioritas
  └ Validate inputs
  └ Submit to database

□ EditTugasPage (to create)
  └ Load existing data
  └ Allow editing
  └ Update database

□ TugasService (to create)
  └ CRUD operations
  └ Validation logic

□ TugasController (to create)
  └ GetX controller
  └ State management
  └ Business logic
```

### Scan Feature

```
□ ScanPage (exists)
  └ Display scan list
  └ Camera button
  └ Gallery button

□ ImageService (to create)
  └ Take photo from camera
  └ Pick from gallery
  └ Save images

□ ScanController (to create)
  └ Handle image picking
  └ Manage scan list
```

### Keuangan Feature

```
□ KeuanganPage (exists)
  └ Display transactions
  └ Add transaction button

□ KeuanganService (to create)
  └ CRUD operations
  └ Category filtering

□ ReportPage (to create)
  └ Summary by category
  └ Total calculations
```

### Jadwal Feature

```
□ JadwalPage (exists)
  └ Display jadwal list

□ NotificationService (to create)
  └ Schedule notifications
  └ Handle notification taps

□ JadwalController (to create)
  └ Manage jadwal state
  └ Trigger notifications
```

## Database Schema Relationships

```
┌─────────────────┐
│    PROFIL       │
├─────────────────┤
│ id (PK)         │
│ nama            │
│ email           │
│ mode_gelap      │
│ created_at      │
│ updated_at      │
└─────────────────┘

┌─────────────────┐
│     TUGAS       │
├─────────────────┤
│ id (PK)         │
│ judul           │
│ deskripsi       │
│ deadline        │
│ prioritas       │
│ status          │
│ created_at      │
│ updated_at      │
└─────────────────┘

┌─────────────────┐
│      SCAN       │
├─────────────────┤
│ id (PK)         │
│ judul           │
│ deskripsi       │
│ foto_path       │
│ created_at      │
│ updated_at      │
└─────────────────┘

┌─────────────────┐
│    KEUANGAN     │
├─────────────────┤
│ id (PK)         │
│ jumlah          │
│ kategori        │
│ deskripsi       │
│ tanggal         │
│ created_at      │
│ updated_at      │
└─────────────────┘

┌─────────────────┐
│     JADWAL      │
├─────────────────┤
│ id (PK)         │
│ judul           │
│ deskripsi       │
│ hari            │
│ jam             │
│ notifikasi      │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

## State Management Flow (GetX Pattern)

```
View (Page)
    ↓
Build() → GetBuilder<Controller>
    ↓
Controller (GetxController)
├─ Observable values (RxInt, RxList, etc)
├─ Methods (actions)
└─ OnInit(), OnClose()
    ↓
Service Layer
├─ DatabaseHelper
├─ ImageService
├─ NotificationService
    ↓
Data Layer
└─ SQLite Database
```

## Theme System Flow

```
MaterialApp
    ↓
ThemeMode.system (Auto detect light/dark)
    ↓
AppTheme.lightTheme / AppTheme.darkTheme
    ├─ TextTheme
    ├─ AppBarTheme
    ├─ BottomNavigationBarTheme
    ├─ InputDecorationTheme
    ├─ ChipTheme
    └─ FloatingActionButtonTheme
    ↓
Widgets use Theme.of(context)
    ↓
Auto switches based on system setting
```

## Navigation Structure

```
MaterialApp
    └─ home: HomePage()
        ├─ BottomNavigationBar
        │   ├─ 0: Home (current)
        │   ├─ 1: Tugas → TugasPage
        │   ├─ 2: Scan → ScanPage
        │   ├─ 3: Keuangan → KeuanganPage
        │   ├─ 4: Jadwal → JadwalPage
        │   └─ 5: Profil → ProfilPage
        │
        └─ Dialogs (Overlay)
            ├─ TambahTugasDialog
            ├─ EditTugasDialog
            └─ ConfirmDeleteDialog
```

## Component Hierarchy

```
HomePage (Stateful)
├─ Scaffold
│  ├─ AppBar
│  ├─ SingleChildScrollView
│  │  └─ Column
│  │     ├─ Welcome Text
│  │     ├─ Dashboard Cards
│  │     │  ├─ TugasCard (FadeInUp)
│  │     │  ├─ JadwalCard (FadeInUp)
│  │     │  ├─ PengeluaranCard (FadeInUp)
│  │     │  └─ CatatanCard (FadeInUp)
│  │     └─ SizedBox (spacer)
│  └─ BottomNavigationBar
│     ├─ BottomNavigationBarItem x 6
│     └─ onTap: _navigateTo(index)
```

## Image Processing Flow

```
User Action (Tap Button)
    ↓
ImagePicker.pickImage() or .takePhoto()
    ↓
File selected/taken
    ↓
Save to app documents directory
    ↓
Store path in Database
    ↓
Load image in UI using File()
    ↓
Display in Image/PhotoView
```

## Notification Flow

```
User creates Jadwal
    ↓
Submit Jadwal with date/time
    ↓
JadwalService.addJadwal()
    ↓
Database insert
    ↓
NotificationService.scheduleNotification()
    ↓
FlutterLocalNotifications.zonedSchedule()
    ↓
At scheduled time:
Notification shown
    ↓
User taps notification
    ↓
App opens
    ↓
Navigate to JadwalPage
```

## Error Handling Pattern

```
try {
  // User Action
  // Service Call
  // Database Operation

} catch (e) {
  // Log error
  // Show SnackBar to user
  // Update UI state

} finally {
  // Stop loading
  // Reset state
}
```

## Testing Structure (to be implemented)

```
test/
├── unit/
│   ├── services/
│   │   ├── tugas_service_test.dart
│   │   ├── scan_service_test.dart
│   │   └── keuangan_service_test.dart
│   └── models/
│       ├── tugas_model_test.dart
│       └── keuangan_model_test.dart
│
├── widget/
│   ├── home_page_test.dart
│   ├── tugas_page_test.dart
│   └── widgets_test.dart
│
└── integration/
    └── app_test.dart
```

---

## Key Principles Applied

1. **Separation of Concerns**
   - Presentation (UI) ↔ Business Logic ↔ Data Layer

2. **Reusability**
   - Shared widgets in widgets/ folder
   - Common constants in core/

3. **Maintainability**
   - Clear folder structure
   - Consistent naming
   - Proper documentation

4. **Scalability**
   - Easy to add new features
   - Easy to modify existing features
   - Modular approach

5. **Best Practices**
   - Const constructors where possible
   - Proper state management
   - Error handling
   - Null safety

---

## Ready for Next Phase!

This architecture provides:
✅ Clear separation of concerns
✅ Easy to add new features
✅ Scalable codebase
✅ Easy testing
✅ Good performance

Now implement services and features following this structure! 🚀
