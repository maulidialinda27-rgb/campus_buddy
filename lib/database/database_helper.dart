import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:campus_buddy/core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Tugas
    await db.execute('''
      CREATE TABLE ${AppConstants.tugasTable} (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        deadline TEXT,
        prioritas TEXT,
        status TEXT DEFAULT 'pending',
        dibuat_pada TEXT,
        diperbarui_pada TEXT
      )
    ''');

    // Tabel Scan/Catatan
    await db.execute('''
      CREATE TABLE ${AppConstants.scanTable} (
        id TEXT PRIMARY KEY,
        judul TEXT,
        deskripsi TEXT,
        foto_path TEXT NOT NULL,
        dibuat_pada TEXT,
        diperbarui_pada TEXT
      )
    ''');

    // Tabel Keuangan
    await db.execute('''
      CREATE TABLE ${AppConstants.keuanganTable} (
        id TEXT PRIMARY KEY,
        jumlah REAL NOT NULL,
        kategori TEXT NOT NULL,
        deskripsi TEXT,
        tanggal TEXT NOT NULL,
        dibuat_pada TEXT,
        diperbarui_pada TEXT
      )
    ''');

    // Tabel Jadwal
    await db.execute('''
      CREATE TABLE ${AppConstants.jadwalTable} (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        hari TEXT NOT NULL,
        jam TEXT NOT NULL,
        notifikasi INTEGER DEFAULT 1,
        dibuat_pada TEXT,
        diperbarui_pada TEXT
      )
    ''');

    // Tabel Profil
    await db.execute('''
      CREATE TABLE ${AppConstants.profilTable} (
        id TEXT PRIMARY KEY,
        nama TEXT,
        email TEXT,
        mode_gelap INTEGER DEFAULT 0,
        dibuat_pada TEXT,
        diperbarui_pada TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades jika diperlukan
  }

  // CRUD Operations untuk Tugas
  Future<String> insertTugas(Map<String, dynamic> tugas) async {
    final db = await database;
    await db.insert(
      AppConstants.tugasTable,
      tugas,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tugas['id'];
  }

  Future<List<Map<String, dynamic>>> getAllTugas() async {
    final db = await database;
    return await db.query(AppConstants.tugasTable, orderBy: 'deadline ASC');
  }

  Future<Map<String, dynamic>?> getTugasById(String id) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tugasTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateTugas(Map<String, dynamic> tugas) async {
    final db = await database;
    return await db.update(
      AppConstants.tugasTable,
      tugas,
      where: 'id = ?',
      whereArgs: [tugas['id']],
    );
  }

  Future<int> deleteTugas(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tugasTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations untuk Scan
  Future<String> insertScan(Map<String, dynamic> scan) async {
    final db = await database;
    await db.insert(
      AppConstants.scanTable,
      scan,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return scan['id'];
  }

  Future<List<Map<String, dynamic>>> getAllScan() async {
    final db = await database;
    return await db.query(AppConstants.scanTable, orderBy: 'dibuat_pada DESC');
  }

  Future<int> deleteScan(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.scanTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations untuk Keuangan
  Future<String> insertKeuangan(Map<String, dynamic> keuangan) async {
    final db = await database;
    await db.insert(
      AppConstants.keuanganTable,
      keuangan,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return keuangan['id'];
  }

  Future<List<Map<String, dynamic>>> getAllKeuangan() async {
    final db = await database;
    return await db.query(AppConstants.keuanganTable, orderBy: 'tanggal DESC');
  }

  Future<int> deleteKeuangan(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.keuanganTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations untuk Jadwal
  Future<String> insertJadwal(Map<String, dynamic> jadwal) async {
    final db = await database;
    await db.insert(
      AppConstants.jadwalTable,
      jadwal,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return jadwal['id'];
  }

  Future<List<Map<String, dynamic>>> getAllJadwal() async {
    final db = await database;
    return await db.query(AppConstants.jadwalTable, orderBy: 'jam ASC');
  }

  Future<int> updateJadwal(Map<String, dynamic> jadwal) async {
    final db = await database;
    return await db.update(
      AppConstants.jadwalTable,
      jadwal,
      where: 'id = ?',
      whereArgs: [jadwal['id']],
    );
  }

  Future<int> deleteJadwal(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.jadwalTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Operations untuk Profil
  Future<void> insertProfil(Map<String, dynamic> profil) async {
    final db = await database;
    await db.insert(
      AppConstants.profilTable,
      profil,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getProfil() async {
    final db = await database;
    final result = await db.query(AppConstants.profilTable);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProfil(Map<String, dynamic> profil) async {
    final db = await database;
    return await db.update(
      AppConstants.profilTable,
      profil,
      where: 'id = ?',
      whereArgs: [profil['id']],
    );
  }
}
