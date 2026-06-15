# 📱 Campus Buddy - Complete Blueprint

**Versi**: 1.0.0  
**Framework**: Flutter  
**Platform**: Android, iOS, Web, Windows, macOS, Linux  
**Tanggal**: June 15, 2026

---

## 📋 Daftar Isi

1. [Overview Aplikasi](#overview-aplikasi)
2. [Fitur Utama](#fitur-utama)
3. [Arsitektur Aplikasi](#arsitektur-aplikasi)
4. [Struktur Project](#struktur-project)
5. [Services & Utilities](#services--utilities)
6. [Dependencies](#dependencies)

---

## 📌 Overview Aplikasi

**Campus Buddy** adalah aplikasi mobile untuk mahasiswa yang membantu mengelola:

- 📅 Jadwal kuliah dan kegiatan
- 📝 Catatan kuliah dan materi pembelajaran
- ✅ Daftar tugas dan deadline
- 💰 Manajemen keuangan
- 👤 Profil pengguna
- 🔍 Pencarian global
- 📱 OCR (Text Recognition) untuk scan catatan

---

## 🎯 Fitur Utama

### 1. **🏠 HOME PAGE (Dashboard)**

**File**: `lib/features/home/presentation/pages/home_page_modern.dart`

**Fungsi Utama**:

- Dashboard utama yang menampilkan ringkasan aktivitas mahasiswa
- Notifikasi jadwal, tugas, dan keuangan
- Quick access ke semua fitur utama
- Dark mode support

**Komponen**:

- Header dengan greeting dan profil
- Section notifikasi jadwal
- Section notifikasi tugas
- Section notifikasi keuangan
- Quick action buttons
- List aktivitas/events terbaru

---

### 2. **📅 JADWAL (Schedule)**

**File**: `lib/features/jadwal/presentation/pages/jadwal_page.dart`  
**File Dialog**: `lib/features/jadwal/presentation/pages/tambah_jadwal_dialog.dart`

**Fungsi Utama**:

- Menampilkan jadwal kuliah dan kegiatan kampus
- Tambah, edit, hapus jadwal
- Notifikasi jadwal (reminder)
- Kategori jadwal (Kuliah, Aktivitas, Event, dll)

**Features**:

- ✅ CRUD Jadwal (Create, Read, Update, Delete)
- 🔔 Reminder/Notifikasi otomatis
- 📊 View kalender atau list
- 🏷️ Kategori dan warna berbeda
- ⏰ Set waktu awal dan akhir
- 📍 Lokasi/Ruangan
- 📝 Deskripsi detail

**Data Storage**: LocalStorage (Shared Preferences)

---

### 3. **✅ TUGAS (Tasks/To-Do)**

**File**: `lib/features/tugas/presentation/pages/tugas_page.dart`

**Fungsi Utama**:

- Manajemen daftar tugas dan PR
- Tracking deadline tugas
- Priority dan status tracking
- Notifikasi tugas deadline

**Features**:

- ✅ CRUD Tugas
- 🎯 Priority levels (High, Medium, Low)
- ✔️ Checkbox untuk completion status
- 📅 Deadline tracking
- 🔔 Notifikasi reminder
- 🏷️ Kategori tugas
- 📝 Deskripsi dan attachment

**Data Storage**: LocalStorage (Shared Preferences)

---

### 4. **💰 KEUANGAN (Finance/Expense Tracker)**

**File**: `lib/features/keuangan/presentation/pages/keuangan_page.dart`

**Fungsi Utama**:

- Manajemen pengeluaran dan pemasukan
- Tracking budget
- Laporan keuangan bulanan/harian
- Kategori pengeluaran

**Features**:

- 💵 Input pemasukan dan pengeluaran
- 📊 Grafik pengeluaran (menggunakan `fl_chart`)
- 🏷️ Kategori (Makan, Transportasi, Hiburan, dll)
- 📈 Analytics dan statistik
- 🎯 Budget planning
- 📄 Report bulanan

**Data Storage**: LocalStorage (Shared Preferences)

---

### 5. **👤 PROFIL (Profile & Authentication)**

**Files**:

- `lib/features/profil/presentation/pages/login_page.dart` - Login screen
- `lib/features/profil/presentation/pages/profile_page.dart` - Profile detail
- `lib/features/profil/presentation/pages/profil_page.dart` - Profile management

**Fungsi Utama**:

- Login/Sign Up pengguna
- Edit profil (nama, email, foto, dll)
- Theme preference (Light/Dark mode)
- Settings dan preferences
- Logout

**Features**:

- 🔐 Login authentication
- 👤 Edit profil lengkap
- 🖼️ Profile picture upload
- 🌙 Dark mode toggle
- 📧 Email dan kontak
- 🔐 Change password
- 📱 Personal info management

**Data Storage**: LocalStorage (Shared Preferences)

---

### 6. **📝 CATATAN (Notes)**

**File**: `lib/features/catatan/presentation/pages/catatan_page.dart`

**Fungsi Utama**:

- Buat dan simpan catatan kuliah
- Organize catatan per mata kuliah/topik
- Search catatan
- Edit dan hapus catatan

**Features**:

- ✍️ Create/Edit catatan
- 📌 Pin catatan penting
- 🏷️ Tag dan kategori
- 🔍 Search & filter
- 📅 Tanggal dibuat/diupdate
- 📝 Rich text/formatting (optional)

**Data Storage**: LocalStorage (Shared Preferences)

---

### 7. **📱 SCAN (OCR - Text Recognition)**

**File**: `lib/features/scan/presentation/pages/scan_to_note_page.dart`  
**Library**: `google_mlkit_text_recognition`, `image_picker`

**Fungsi Utama**:

- Scan foto/gambar menggunakan camera
- Extract text dari gambar (OCR)
- Convert hasil scan ke catatan
- Save ke catatan otomatis

**Features**:

- 📷 Camera integration
- 🖼️ Image picker dari galeri
- 🔤 Text recognition (OCR)
- ✏️ Edit hasil scan
- 💾 Save ke catatan
- 📋 Copy hasil text

**Technology**: Google ML Kit Text Recognition

---

### 8. **🔍 SEARCH (Global Search)**

**File**: `lib/features/search/presentation/pages/global_search_delegate.dart`

**Fungsi Utama**:

- Search global di semua fitur
- Cari jadwal, tugas, catatan, dll
- Real-time search suggestions

**Features**:

- 🔍 Full text search
- 💡 Search suggestions
- 📊 Kategorisasi hasil (Jadwal, Tugas, Catatan, dll)
- ⚡ Real-time filtering
- 🎯 Smart search results

---

## 🏛️ Arsitektur Aplikasi

### Architecture Pattern: **Clean Architecture + MVC**

```
lib/
├── features/           # Fitur-fitur utama (Domain layers)
│   ├── home/          # Home/Dashboard
│   ├── jadwal/        # Schedule
│   ├── tugas/         # Tasks
│   ├── keuangan/      # Finance
│   ├── profil/        # Profile
│   ├── catatan/       # Notes
│   ├── scan/          # OCR
│   └── search/        # Search
├── core/              # Utilities dan tema
│   └── theme/         # App theme (Light/Dark)
├── services/          # Business logic & data management
├── database/          # Database layer (jika ada)
├── models/            # Data models
├── widgets/           # Reusable widgets & components
├── main.dart          # Entry point
└── app.dart           # App configuration & routing
```

### Layers dalam Setiap Feature:

```
feature_name/
├── data/              # Data layer (API, local storage)
│   └── models/
├── presentation/      # UI layer
│   ├── pages/        # Full screens
│   ├── widgets/      # Sub-components
│   └── controllers/  # State management (jika ada)
└── domain/           # Business logic (optional)
```

---

## 📁 Struktur Project

### Core Directory

```
lib/core/
├── theme/
│   └── app_theme.dart    # Light & dark theme configuration
└── ...
```

### Services Directory

```
lib/services/
├── notification_service.dart          # Notifikasi push
├── notification_generator_service.dart # Generate notifikasi
├── jadwal_service.dart               # Jadwal business logic
├── tugas_service.dart                # Tugas business logic
├── catatan_service.dart              # Catatan business logic
├── local_storage_service.dart        # Local storage management
└── user_service.dart                 # User & authentication
```

### Widgets (Reusable Components)

```
lib/widgets/
├── custom_buttons.dart         # Custom button designs
├── custom_cards.dart           # Card components
├── dashboard_widgets.dart      # Dashboard specific widgets
├── gradient_card.dart          # Gradient card component
├── modern_button.dart          # Modern button style
├── modern_card.dart            # Modern card style
├── modern_page_widgets.dart    # Modern page layouts
├── modern_textfield.dart       # Modern text field
├── notification_card.dart      # Notification display card
└── section_widgets.dart        # Section/container widgets
```

---

## ⚙️ Services & Utilities

### 1. **NotificationService**

- Inisialisasi push notification
- Set channel dan permission
- Handle notification click events
- Local notification scheduling

### 2. **NotificationGeneratorService**

- Generate notifikasi untuk jadwal
- Generate notifikasi untuk tugas
- Generate notifikasi untuk keuangan
- Auto-schedule notifications

### 3. **JadwalService**

- CRUD jadwal
- Retrieve jadwal by date range
- Search jadwal
- Get upcoming events

### 4. **TugasService**

- CRUD tugas
- Track completion status
- Filter by deadline
- Priority management

### 5. **CatatanService**

- CRUD catatan
- Search catatan
- Tag management
- Organize by category

### 6. **LocalStorageService**

- Singleton pattern
- Initialize shared preferences
- Store/retrieve data semua fitur
- Data persistence

### 7. **UserService**

- Login/Logout management
- User profile data
- Theme preference
- Authentication state

---

## 📦 Dependencies

### UI & Styling

```
cupertino_icons: ^1.0.8        # iOS icons
google_fonts: ^7.0.0           # Google Fonts integration
lottie: ^3.0.0                 # Animation library
animate_do: ^3.1.2             # Animation effects
```

### Data & Charts

```
fl_chart: ^0.68.0              # Financial charts (pie, bar, line)
```

### Database & Storage

```
shared_preferences: ^2.2.2     # Local key-value storage
```

### Notifications

```
flutter_local_notifications: ^17.0.0  # Local notifications
timezone: ^0.9.2                      # Timezone support
```

### Image & OCR

```
image_picker: ^1.1.0                      # Pick image dari camera/gallery
google_mlkit_text_recognition: ^0.13.0    # OCR - Text recognition
```

### Utilities

```
intl: ^0.19.0                  # Internationalization & date format
uuid: ^4.0.0                   # Generate unique IDs
get: ^4.6.5                    # State management & navigation
```

---

## 🎨 Theme & Design

### Colors

- **Primary**: Custom brand color
- **Accent**: Secondary color for highlights
- **Success/Error**: Status colors
- **Light/Dark Mode**: Full dark mode support

### Typography

- **Font**: Google Fonts integration
- **Sizes**: Responsive text sizes
- **Styles**: Heading, body, caption styles

### Components

- **Modern UI**: Gradient cards, rounded corners
- **Smooth Animations**: Lottie animations
- **Responsive**: Adapts to different screen sizes

---

## 🚀 Flow Aplikasi

### Initial Flow

```
main.dart
  ↓
CampusBuddyApp (Check login status)
  ├─→ User LoggedIn? YES → HomePageModern (Dashboard)
  └─→ User LoggedIn? NO → LoginPage
```

### Navigation Flow

```
Dashboard (HomePageModern)
  ├─→ Jadwal Page
  ├─→ Tugas Page
  ├─→ Keuangan Page
  ├─→ Catatan Page
  ├─→ Scan Page
  ├─→ Profile Page
  ├─→ Global Search
  └─→ Logout → LoginPage
```

---

## 🔐 Data Storage

### Local Storage (Shared Preferences)

- **Jadwal**: Disimpan dengan format JSON
- **Tugas**: List of tasks
- **Keuangan**: Transactions & budget
- **Catatan**: Notes dengan metadata
- **User**: Profile & preferences
- **Settings**: Theme, language, dll

### Persistence

- Semua data persistent (tidak hilang saat app close)
- Data sync otomatis
- Backup manual (optional)

---

## 📱 Features by Feature

### Jadwal

- [x] View semua jadwal
- [x] Tambah jadwal baru
- [x] Edit jadwal
- [x] Hapus jadwal
- [x] Notifikasi reminder
- [x] Kategori & warna
- [x] Filter by date/kategori

### Tugas

- [x] View semua tugas
- [x] Tambah tugas
- [x] Edit status (done/not done)
- [x] Priority levels
- [x] Deadline tracking
- [x] Notifikasi deadline
- [x] Filter by status/priority

### Keuangan

- [x] Input income/expense
- [x] Kategori pengeluaran
- [x] Chart & analytics
- [x] Monthly report
- [x] Budget tracking
- [x] Expense filtering

### Catatan

- [x] Buat catatan baru
- [x] Edit catatan
- [x] Hapus catatan
- [x] Search catatan
- [x] Tag & kategori
- [x] Pin penting

### Scan/OCR

- [x] Camera integration
- [x] Image picker
- [x] Text recognition
- [x] Save ke catatan
- [x] Edit hasil scan
- [x] Copy text

### Profile

- [x] Login/Logout
- [x] Edit profil
- [x] Foto profil
- [x] Dark mode toggle
- [x] Settings

---

## 🎯 Future Enhancements

- [ ] Cloud sync (Firebase)
- [ ] Kolaborasi dengan teman
- [ ] Export data (PDF, Excel)
- [ ] Widget desktop
- [ ] Offline-first sync
- [ ] Advanced analytics
- [ ] Custom notifications
- [ ] Multi-language support
- [ ] Voice input untuk catatan
- [ ] Kalender integration
- [ ] Student forums
- [ ] Study groups feature

---

## 📊 Statistics

| Aspek                   | Jumlah                                       |
| ----------------------- | -------------------------------------------- |
| **Main Features**       | 8                                            |
| **Pages**               | 10+                                          |
| **Services**            | 7                                            |
| **Reusable Widgets**    | 11+                                          |
| **Dependencies**        | 15+                                          |
| **Supported Platforms** | 6 (Android, iOS, Web, Windows, macOS, Linux) |

---

## 🛠️ Development Notes

### Tech Stack

- **Language**: Dart
- **Framework**: Flutter
- **State Management**: GetX (optional)
- **Database**: SharedPreferences (local)
- **Architecture**: Clean Architecture
- **Pattern**: MVC + Clean Architecture

### Best Practices

- ✅ Modular architecture
- ✅ Reusable components
- ✅ Proper error handling
- ✅ Responsive design
- ✅ Dark mode support
- ✅ Local persistence
- ✅ Notification system

### Testing

- Unit tests (recommended)
- Widget tests (recommended)
- Integration tests (recommended)

---

**End of Blueprint**  
_Generated: June 15, 2026_
