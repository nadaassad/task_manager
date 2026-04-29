import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task_manager/models/tasks.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_task_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        gender TEXT,
        email TEXT NOT NULL UNIQUE,
        studentId TEXT NOT NULL UNIQUE,
        academicLevel TEXT,
        password TEXT NOT NULL,
        profilePhoto TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        priority TEXT,
        isCompleted INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // ===== USER METHODS =====
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> user, int id) async {
    final db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  // ===== TASK METHODS =====
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  // get task by user
  Future<List<Map<String, dynamic>>> getTasksByUser(int userId) async {
    final db = await database;
    return await db.query('tasks', where: 'userId = ?', whereArgs: [userId]);
  }

  // update task
  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('tasks', data, where: 'id=?', whereArgs: [id]);
  }

  // delete task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // get all tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result.map((map) => Task.fromMap(map)).toList();
  }
}
