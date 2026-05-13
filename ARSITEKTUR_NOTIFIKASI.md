# 📊 ARSITEKTUR SISTEM NOTIFIKASI JADWAL

## 🏗️ Arsitektur Aplikasi

```
┌─────────────────────────────────────────────────────────────┐
│                        CampusBuddy App                      │
└─────────────────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │  JadwalPage  │ │  Notification│ │   Services   │
    │  (UI Layer)  │ │   Dialog     │ │              │
    └──────────────┘ └──────────────┘ └──────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ JadwalService│ │   Jadwal     │ │ NotificationS│
    │   (Logic)    │ │   Model      │ │   Service    │
    └──────────────┘ └──────────────┘ └──────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │SharedPrefs   │ │  Data Class  │ │ FlutterLocal │
    │  (Storage)   │ │              │ │ Notifications│
    └──────────────┘ └──────────────┘ └──────────────┘
```

---

## 📁 Struktur File

```
lib/
│
├── main.dart
│   ├── ✅ Inisialisasi NotificationService
│   └── ✅ Inisialisasi JadwalService
│
├── services/
│   ├── notification_service.dart
│   │   ├── initNotification()           → Setup notifikasi
│   │   ├── scheduleNotification()       → Jadwalkan notifikasi
│   │   ├── cancelNotification()         → Batalkan notifikasi
│   │   ├── cancelAllNotifications()     → Batalkan semua
│   │   └── showTestNotification()       → Test notifikasi
│   │
│   └── jadwal_service.dart
│       ├── init()                       → Inisialisasi SharedPrefs
│       ├── addJadwal()                  → Tambah + notifikasi
│       ├── getAllJadwal()               → Baca semua
│       ├── getJadwalByHari()            → Baca per hari
│       ├── updateJadwal()               → Update + update notifikasi
│       ├── deleteJadwal()               → Hapus + batalkan notifikasi
│       ├── toggleNotifikasi()           → On/Off notifikasi
│       └── getStatistik()               → Statistik
│
├── features/jadwal/
│   ├── data/models/
│   │   └── jadwal_model.dart
│   │       ├── id: String
│   │       ├── judul: String
│   │       ├── hari: String
│   │       ├── jam: String
│   │       └── notifikasi: int (1 = aktif, 0 = nonaktif)
│   │
│   └── presentation/pages/
│       ├── jadwal_page.dart
│       │   ├── List jadwal
│       │   ├── Edit/Delete
│       │   ├── Toggle notifikasi
│       │   └── FAB untuk tambah
│       │
│       └── tambah_jadwal_dialog.dart
│           ├── Input judul
│           ├── Pilih hari
│           ├── Pilih jam
│           ├── Toggle notifikasi
│           └── Save/Update/Cancel
│
└── pubspec.yaml
    ├── flutter_local_notifications: ^17.0.0
    ├── timezone: ^0.9.2
    ├── uuid: ^4.0.0
    └── shared_preferences: ^2.2.2
```

---

## 🔄 Alur Data

### Alur 1: Tambah Jadwal dengan Notifikasi

```
┌────────────────┐
│  User Input    │
│ Form Dialog    │
└────────┬───────┘
         │
         ▼
┌────────────────────────────────────┐
│ onSave() → JadwalService.addJadwal()│
└────────┬───────────────────────────┘
         │
         ├─── Step 1: Parse data jadwal
         │
         ├─── Step 2: Simpan ke SharedPreferences
         │
         ├─── Step 3: Cek notifikasi = 1?
         │
         ├─yes─→ Parse jam + tanggal
         │
         ├─yes─→ Hitung waktu notifikasi (jam - 10 menit)
         │
         ├─yes─→ Call NotificationService.scheduleNotification()
         │
         │       ┌──────────────────────────────────────────┐
         │       │ FlutterLocalNotifications.zonedSchedule()│
         │       │ dengan timezone lokal (TZDateTime)       │
         │       └──────────────┬───────────────────────────┘
         │                      │
         │       ┌─────────────┬┴──┬──────────┐
         │       │             │   │          │
         │       ▼             ▼   ▼          ▼
         │    Android        iOS  macOS    Windows
         │  (Channel)       (Push) (Push)  (Toast)
         │
         ▼
    ✅ Jadwal + Notifikasi
       tersimpan & terjadwal
```

### Alur 2: Notifikasi Muncul

```
┌──────────────────────────────────────┐
│ Device time == Notifikasi time?      │
└──────────────┬───────────────────────┘
               │
               ├─ YES ─────────────────┐
               │                       │
               ▼                       ▼
        ┌─────────────────┐    ┌──────────────┐
        │ Foreground?     │    │ Background?  │
        │ (App terbuka)   │    │ (App tertutup)
        └────┬────────────┘    └──────┬───────┘
             │                        │
             ▼                        ▼
        FlutterLocal...         System Native
        onDidReceiveNotif...    Notification
             │                        │
             │                        │
        ┌────┴─────────────────────────┴────┐
        │                                    │
        ▼                                    ▼
   Notifikasi          🔔 Notifikasi Muncul di Tray
   ditampilkan in-app          │
                               │
                            User tap?
                               │
                               ▼
                          onSelectNotification()
                          (Handle user action)
```

### Alur 3: Update Jadwal

```
┌──────────────────────┐
│ Edit Jadwal Existing │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────┐
│ JadwalService.updateJadwal()         │
└────────────┬─────────────────────────┘
             │
             ├─ Step 1: Find old jadwal by ID
             │
             ├─ Step 2: Cancel old notification
             │          NotificationService.cancelNotification(id)
             │
             ├─ Step 3: Save updated data to SharedPreferences
             │
             ├─ Step 4: Schedule new notification
             │          (dengan waktu baru jika ada perubahan)
             │
             ▼
         ✅ Jadwal + Notifikasi
            diupdate & dijadwalkan ulang
```

---

## 🔐 Data Flow Diagram

```
      User Interface
      ├─ JadwalPage
      │  └─ Display list jadwal
      │
      ├─ TambahJadwalDialog
      │  └─ Form input jadwal
      │
      └─ Actions
         ├─ Add
         ├─ Edit
         ├─ Delete
         └─ Toggle notifikasi
              │
              ▼
    ┌──────────────────────────┐
    │   JadwalService          │
    ├──────────────────────────┤
    │ Business Logic Layer     │
    ├──────────────────────────┤
    │ • addJadwal()            │
    │ • updateJadwal()         │
    │ • deleteJadwal()         │
    │ • toggleNotifikasi()     │
    │ • getJadwalByHari()      │
    │ • getAllJadwal()         │
    │ • getStatistik()         │
    └────────┬─────────────────┘
             │
             ├─────────────────────────┬────────────────────┐
             │                         │                    │
             ▼                         ▼                    ▼
    ┌──────────────────┐    ┌──────────────────┐  ┌──────────────────┐
    │ SharedPreferences│    │ NotificationServ │  │  Jadwal Model    │
    ├──────────────────┤    ├──────────────────┤  ├──────────────────┤
    │ Storage Layer    │    │ Notification Mgmt│  │ Data Class       │
    ├──────────────────┤    ├──────────────────┤  ├──────────────────┤
    │ • Simpan JSON    │    │ • scheduleNotif()│  │ • id             │
    │ • Load JSON      │    │ • cancelNotif()  │  │ • judul          │
    │ • Update JSON    │    │ • showTest()     │  │ • hari           │
    │ • Delete data    │    │                  │  │ • jam            │
    │                  │    │ Flutter Local    │  │ • notifikasi     │
    │                  │    │ Notifications    │  │ • deskripsi      │
    └──────────────────┘    └────────┬─────────┘  │ • dibuatPada     │
                                     │            │ • diperbarui     │
                    ┌────────────────┘            └──────────────────┘
                    │
                    ▼
        ┌──────────────────────────────────┐
        │  Android/iOS/macOS/Windows       │
        │  Native Notification System      │
        │                                  │
        │ 🔔 Notifikasi muncul di user     │
        └──────────────────────────────────┘
```

---

## 🔌 Integrasi Dependencies

```
┌─────────────────────────────────────────────────────┐
│              pubspec.yaml                          │
├─────────────────────────────────────────────────────┤
│ flutter_local_notifications: ^17.0.0               │
│   ├─ Android: NotificationManager                  │
│   ├─ iOS: UNUserNotificationCenter                 │
│   ├─ macOS: NSUserNotificationCenter               │
│   └─ Windows: WinToast                             │
│                                                     │
│ timezone: ^0.9.2                                   │
│   ├─ Parse timezone                                │
│   ├─ TZDateTime untuk scheduling                   │
│   └─ Timezone data (IANA)                          │
│                                                     │
│ shared_preferences: ^2.2.2                         │
│   ├─ Android: SharedPreferences                    │
│   └─ iOS: NSUserDefaults                           │
│                                                     │
│ uuid: ^4.0.0                                       │
│   └─ Generate unique ID untuk jadwal              │
│                                                     │
│ animate_do: ^3.1.2                                 │
│   └─ Animation untuk UI                            │
│                                                     │
│ google_fonts: ^7.0.0                               │
│   └─ Custom fonts untuk UI                         │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 Sequence Diagram: Menambah Jadwal

```
User            Dialog           Service           Storage        Notif System
  │                 │                │                │                │
  │──[Tambah Jadwal]→│                │                │                │
  │                 │                │                │                │
  │    [Fill Form]  │                │                │                │
  │←────[Form UI]──│                │                │                │
  │                 │                │                │                │
  │────[Simpan]────→│                │                │                │
  │                 │──[addJadwal()]→│                │                │
  │                 │                │─[save JSON]───→│                │
  │                 │                │←─[success]────│                │
  │                 │                │                │                │
  │                 │                ├─ if notif==1 ─┐
  │                 │                │                │
  │                 │                ├─[scheduleNotif]──────────────→│
  │                 │                │                             [Set Timer]
  │                 │                │                                │
  │                 │←─[onSave]─────│                                │
  │                 │                │                                │
  │     [Success]   │                │                                │
  │←─[SnackBar]────│                │                                │
  │                 │                │                                │
  └─────────────────────────────────────────────────────────────────┘
```

---

## 📋 State Management Flow

```
JadwalPage State
├─ _daftarJadwal: List<Jadwal>
├─ _jadwalService: JadwalService
├─ _notificationService: NotificationService
│
├─ initState()
│   └─ _loadJadwal()
│
├─ _loadJadwal()
│   ├─ getAllJadwal() from service
│   ├─ Sort by hari
│   └─ setState()
│
├─ _showTambahJadwalDialog()
│   ├─ TambahJadwalDialog onSave callback
│   ├─ addJadwal() atau updateJadwal()
│   ├─ _loadJadwal() to refresh UI
│   └─ setState()
│
├─ _toggleNotifikasi()
│   ├─ toggleNotifikasi() from service
│   ├─ _loadJadwal()
│   └─ setState()
│
└─ _deleteJadwal()
    ├─ deleteJadwal() from service
    ├─ _loadJadwal()
    └─ setState()
```

---

## 🧪 Testing Scenario

```
Scenario 1: Add Jadwal dengan Notifikasi Aktif
┌─────────────────────────────────────────────────┐
│ 1. User membuka JadwalPage                     │
│ 2. Klik FAB "+", TambahJadwalDialog terbuka   │
│ 3. Isi form:                                   │
│    - Judul: "Kuliah Algoritma"                │
│    - Hari: "Senin"                            │
│    - Jam: "10:00"                             │
│    - Notifikasi: ON (toggle aktif)            │
│ 4. Klik "Simpan"                              │
│ 5. Expected:                                   │
│    ✓ Jadwal disimpan ke SharedPreferences     │
│    ✓ Notifikasi dijadwalkan untuk 09:50      │
│    ✓ SnackBar: "Jadwal berhasil ditambahkan" │
│    ✓ JadwalPage refresh dengan jadwal baru   │
└─────────────────────────────────────────────────┘

Scenario 2: Notifikasi Muncul pada Waktu Tepat
┌─────────────────────────────────────────────────┐
│ 1. Jadwal ada untuk Senin 10:00                │
│ 2. Device time = Senin 09:50                   │
│ 3. Expected:                                   │
│    ✓ Notifikasi muncul pada Senin 09:50      │
│    ✓ Judul: "Pengingat Jadwal"                │
│    ✓ Isi: "Kegiatan akan dimulai dalam 10 mnt│
│    ✓ Sound & vibration aktif                  │
│    ✓ User bisa tap untuk open app             │
└─────────────────────────────────────────────────┘

Scenario 3: Update Jadwal & Notifikasi
┌─────────────────────────────────────────────────┐
│ 1. Existing jadwal: Senin 10:00                │
│ 2. User klik "Edit"                            │
│ 3. Ubah jam menjadi 13:00                      │
│ 4. Klik "Update"                               │
│ 5. Expected:                                   │
│    ✓ Old notifikasi (09:50) dibatalkan        │
│    ✓ Jadwal diupdate ke 13:00                 │
│    ✓ New notifikasi (12:50) dijadwalkan       │
│    ✓ UI refresh dengan data baru              │
└─────────────────────────────────────────────────┘
```

---

**Versi:** 1.0.0
**Terakhir diupdate:** May 13, 2026
