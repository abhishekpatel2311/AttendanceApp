import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Database configuration
  static const _dbName = 'attendance.db';
  static const _dbVersion = 1;

  // Table names
  static const studentTable = 'students';
  static const subjectTable = 'subjects';
  static const attendanceTable = 'attendance';
  static const usersTable = 'users';

  // Singleton instance
  static final DBHelper _instance = DBHelper._internal();

  DBHelper._internal();

  factory DBHelper() => _instance;

  Database? _database;

  // Access the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $studentTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $subjectTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $attendanceTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        date TEXT NOT NULL,
        status INTEGER NOT NULL,
        FOREIGN KEY (studentId) REFERENCES $studentTable (id),
        FOREIGN KEY (subjectId) REFERENCES $subjectTable (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  // ---------------------- CRUD OPERATIONS ---------------------- //

  // Insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  // Query all records from a table
  Future<List<Map<String, dynamic>>> query(String table) async{
    final db = await database;
    return await db.query(table);
  }

  // Update a record in a table
  Future<int> update(String table, Map<String, dynamic> values,
      String whereClause, List<Object?> whereArgs) async {
    final db = await database;
    return await db.update(table, values,
        where: whereClause, whereArgs: whereArgs);
  }

  // Delete a record from a table
  Future<int> delete(
      String table, String whereClause, List<Object?> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  // ---------------------- USER OPERATIONS ---------------------- //

  // Register a new user
  Future<int> registerUser(String username, String password) async {
    final db = await database;
    return await db.insert(
      usersTable,
      {'username': username, 'password': password},
      conflictAlgorithm:
          ConflictAlgorithm.ignore, // Prevent duplicate usernames
    );
  }

  // Authenticate user login
  Future<bool> authenticateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      usersTable,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty; // True if the user exists
  }

  // ---------------------- ATTENDANCE OPERATIONS ---------------------- //

  // Fetch attendance records for a specific subject
  Future<List<Map<String, dynamic>>> fetchAttendance(int subjectId) async {
    final db = await database;
    return await db.query(
      attendanceTable,
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );
  }

  // Calculate attendance percentage for a specific student and subject
  Future<double> calculateAttendancePercentage(
      int studentId, int subjectId) async {
    final db = await database;
    final records = await db.query(
      attendanceTable,
      where: 'studentId = ? AND subjectId = ?',
      whereArgs: [studentId, subjectId],
    );

    if (records.isEmpty) return 0.0;

    final totalClasses = records.length;
    final presentCount =
        records.where((record) => record['status'] == 1).length;

    return (presentCount / totalClasses) * 100;
  }

  // ---------------------- SUBJECT & STUDENT OPERATIONS ---------------------- //

  // Add a student
  Future<int> addStudent(String name) async {
    return await insert(studentTable, {'name': name});
  }

  // Add a subject
  Future<int> addSubject(String name) async {
    return await insert(subjectTable, {'name': name});
  }
}
