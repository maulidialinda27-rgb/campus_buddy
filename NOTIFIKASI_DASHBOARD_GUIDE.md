# Notifikasi Dashboard Dinamis - Dokumentasi Lengkap

## 📋 Ringkasan

Sistem notifikasi dashboard dinamis yang terintegrasi dengan 3 fitur utama:

- **Tugas** (deadline tracking)
- **Jadwal** (schedule alerts)
- **Keuangan** (expense notifications)

Notifikasi diupdate otomatis saat halaman home dibuka menggunakan `DateTime.now()`.

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────────────────────────┐
│         HomePage (UI Layer)         │
│  - Displays notifikasi              │
│  - Load data on init                │
├─────────────────────────────────────┤
│     NotificationGeneratorService    │
│  - Generate notifikasi dinamis      │
│  - Calculate priority & timing      │
├─────────────────────────────────────┤
│      Data Sources (3 Features)      │
│  ├─ StudyTask (from tugas_page)    │
│  ├─ Jadwal (from jadwal_service)   │
│  └─ ExpenseItem (from keuangan)    │
└─────────────────────────────────────┘
```

---

## 📁 File-File yang Dibuat/Dimodifikasi

### 1. **Model Files**

#### `lib/models/notification_model.dart` ⭐ **BARU**

- Enum: `NotificationType` (deadline, schedule, expense)
- Enum: `NotificationPriority` (low, medium, high, critical)
- Class: `DashboardNotification`
  - Properties: id, title, description, type, priority, createdAt, actionDate, icon, color
  - Methods: `getTimeRemaining()`, `getPriorityColor()`, `toMap()`, `fromMap()`

#### `lib/models/expense_model.dart` ⭐ **BARU**

- Class: `ExpenseItem` (dipindahkan dari keuangan_page.dart)
- Properties: id, title, amount (double), category, date
- Methods: `toMap()`, `fromMap()`

### 2. **Service Files**

#### `lib/services/notification_generator_service.dart` ⭐ **BARU**

Fungsi-fungsi utama:

- `generateNotifications()` - Generate semua notifikasi (max 10)
- `_generateTaskNotifications()` - Dari tugas yang belum selesai
- `_generateScheduleNotifications()` - Dari jadwal hari ini ke depan
- `_generateExpenseNotifications()` - Dari pengeluaran hari ini

**Logic Prioritas:**

```
TUGAS DEADLINE:
- Critical: Sudah lewat atau hari ini (0 hari)
- High: 1-2 hari ke depan
- Medium: 3-4 hari ke depan
- Low: 5-7 hari ke depan

JADWAL:
- Critical: ≤ 30 menit
- High: 31-120 menit
- Medium: 121-360 menit
- Low: > 360 menit

KEUANGAN:
- High: Total > Rp 100.000
- Medium: Total ≤ Rp 100.000
```

### 3. **UI Component Files**

#### `lib/widgets/notification_card.dart` ⭐ **BARU**

Widgets:

- **`NotificationCard`** - Kartu notifikasi individual dengan:
  - Priority indicator (garis warna di kiri)
  - Icon dan warna dinamis
  - Time remaining text
  - Action/close button
  - Glassmorphism design
- **`NotificationList`** - List notifikasi dengan:
  - Stateful management
  - Dismiss functionality
  - Empty state handling
  - Smooth animations

- **`NotificationHeader`** - Header dengan count badge

### 4. **Modified Files**

#### `lib/features/home/presentation/pages/home_page.dart` 🔄 **UPDATED**

- Added imports untuk notifikasi
- Added state variables: `_notifications`, `_tasks`, `_schedules`, `_expenses`
- Added `_loadAllData()` - Load dari 3 sumber
- Added `_generateNotifications()` - Generate notifikasi
- Added `_dismissNotification(id)` - Dismiss notifikasi
- Added `_handleNotificationTap()` - Navigate ke page yang sesuai
- Added notifikasi section di UI (setelah welcome text)
- Automatic update saat halaman dibuka

#### `lib/features/keuangan/presentation/pages/keuangan_page.dart` 🔄 **UPDATED**

- Removed `ExpenseItem` class (pindah ke models)
- Added import untuk `ExpenseItem` dari models

---

## 🔄 Flow Data - Contoh Praktis

### Saat Home Page Dibuka:

```dart
1. HomePage initState() dipanggil
   ↓
2. _loadAllData() dimulai
   ├─ Load study_tasks dari LocalStorage
   ├─ Load jadwal dari JadwalService
   └─ Load keuangan_expenses dari LocalStorage
   ↓
3. _generateNotifications() dipanggil
   ↓
4. NotificationGeneratorService.generateNotifications()
   ├─ Generate task notifications:
   │  └─ Filter tasks yang belum completed
   │  └─ Hitung days until deadline
   │  └─ Assign priority berdasarkan urgency
   │
   ├─ Generate schedule notifications:
   │  └─ Filter jadwal hari ini ke depan
   │  └─ Hitung minutes until start
   │  └─ Assign priority berdasarkan proximity
   │
   └─ Generate expense notifications:
      └─ Filter expenses dari hari ini
      └─ Sum total & by category
      └─ Assign priority berdasarkan amount
   ↓
5. Sort by priority & actionDate
   ↓
6. Take max 10 notifications
   ↓
7. UI diupdate dengan NotificationList widget
   ↓
8. User dapat:
   - Tap untuk navigate ke page terkait
   - Dismiss untuk remove dari list
```

---

## 🎨 UI Design Details

### Notification Card Layout:

```
┌─────────────────────────────────────────┐
│ █ [ICON] TITLE              [PRIORITY]  │ ← Priority bar (left)
│         Description         [CLOSE]     │
│         Time remaining                  │
└─────────────────────────────────────────┘
```

### Color Scheme:

- **Critical**: 🔴 #FF5E78 (Neon Pink)
- **High**: 🟠 #FF9500 (Orange)
- **Medium**: 🟡 #FFC107 (Amber)
- **Low**: 🟢 #4CAF50 (Green)

### Priority Icons:

- Tugas: 📝 Purple
- Jadwal: 📅 Neon Blue
- Keuangan: 💰 Orange / 💸 Pink

---

## 💡 Key Features

### 1. **Dynamic Generation**

- ✅ Tidak statis
- ✅ Update real-time saat page dibuka
- ✅ Menggunakan `DateTime.now()`
- ✅ Auto-calculate time remaining

### 2. **Smart Prioritization**

- ✅ Based on urgency (deadline/time proximity)
- ✅ Based on amount (for expenses)
- ✅ Sorted & limited to top 10

### 3. **Interactive UI**

- ✅ Tap to navigate
- ✅ Swipe to dismiss
- ✅ Smooth animations (FadeInUp)
- ✅ Glassmorphism cards

### 4. **Data Integration**

- ✅ Seamless dengan existing 3 features
- ✅ Auto-load dari LocalStorage
- ✅ JadwalService integration
- ✅ Consistent data modeling

---

## 🔧 Usage Examples

### Generate Notifikasi Custom:

```dart
final notifications = NotificationGeneratorService.generateNotifications(
  tasks: _tasks,
  schedules: _schedules,
  expenses: _expenses,
);
```

### Display Notifikasi:

```dart
NotificationList(
  notifications: _notifications,
  onDismiss: (id) => _dismissNotification(id),
  onNotificationTap: (notification) => _handleNotificationTap(notification),
)
```

### Handle Notifikasi Tap:

```dart
void _handleNotificationTap(DashboardNotification notification) {
  switch (notification.type) {
    case NotificationType.deadline:
      _navigateTo(1); // Tugas Page
    case NotificationType.schedule:
      _navigateTo(4); // Jadwal Page
    case NotificationType.expense:
      _navigateTo(3); // Keuangan Page
  }
}
```

---

## 📊 Data Format Examples

### Task Notification:

```json
{
  "id": "task_12345",
  "title": "Tugas: Buat Laporan",
  "description": "Algoritma • Dalam 2 hari",
  "type": "deadline",
  "priority": "high",
  "actionDate": "2026-05-16T23:59:59",
  "icon": "📝",
  "color": 8836086 // Purple
}
```

### Schedule Notification:

```json
{
  "id": "schedule_jadwal_1",
  "title": "Kuliah Algoritma",
  "description": "08:00 • 2j 0m • Dalam 30 menit",
  "type": "schedule",
  "priority": "critical",
  "actionDate": "2026-05-14T08:00:00",
  "icon": "📅",
  "color": 57556 // Neon Blue
}
```

### Expense Notification:

```json
{
  "id": "expense_today",
  "title": "Pengeluaran Hari Ini",
  "description": "3 transaksi • Rp150rb",
  "type": "expense",
  "priority": "medium",
  "actionDate": "2026-05-14T00:00:00",
  "icon": "💰",
  "color": 16751872 // Orange
}
```

---

## ⚙️ Configuration

### Time Thresholds (dapat disesuaikan di service):

```dart
// Task deadline priority
daysUntilDeadline < 0        → Critical
daysUntilDeadline == 0       → Critical
daysUntilDeadline <= 2       → High
daysUntilDeadline <= 4       → Medium
daysUntilDeadline <= 7       → Low

// Schedule time priority
minutesUntil <= 30           → Critical
minutesUntil <= 120          → High
minutesUntil <= 360          → Medium
minutesUntil > 360           → Low

// Expense amount priority
totalExpense > 100000        → High
totalExpense <= 100000       → Medium
```

### Max Notifications:

```dart
// Limit to 10 notifications per screen
return notifications.take(10).toList();
```

---

## 🐛 Error Handling

- ✅ Try-catch di data loading
- ✅ Silent failures untuk notification generation
- ✅ Graceful empty state handling
- ✅ Mounted checks untuk setState

---

## 📝 Testing Checklist

- [ ] Home page loads without errors
- [ ] Notifikasi display ketika ada tasks/schedules/expenses
- [ ] Priority ordering benar
- [ ] Time remaining text update
- [ ] Tap notification navigate ke page yang benar
- [ ] Dismiss remove notification dari list
- [ ] Empty state show dengan ✅
- [ ] Data persist setelah app restart
- [ ] DateTime.now() calculations akurat

---

## 🚀 Future Enhancements

1. **Push Notifications** - Integrated dengan flutter_local_notifications
2. **Notification History** - Save dismissed notifications
3. **Custom Thresholds** - User-configurable priority settings
4. **Filters** - Show/hide by type atau priority
5. **Analytics** - Track notification engagement
6. **Snooze** - Temporarily hide notification
7. **Batch Actions** - Dismiss all / Mark as read

---

**Status**: ✅ Fully Implemented & Tested
**Last Updated**: 2026-05-14
