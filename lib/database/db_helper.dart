import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task_manager/models/tasks.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'task_manager.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            dueDate TEXT,
            priority TEXT,
            isCompleted INTEGER DEFAULT 0
          )
        ''');
      },
    );

    return _db!;
  }

  //Add Task
  static Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await getDatabase();
    return await db.insert('tasks', task);
  }

  // 🗑️ Delete Task
  static Future<int> deleteTask(int id) async {
    final db = await getDatabase();
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  //Get All Tasks
  static Future<List<Task>> getTasks() async {
    final db = await getDatabase();
    final result = await db.query('tasks');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // 🔄 Update Task
  static Future<void> updateTask(int id, Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.update('tasks', data, where: 'id=?', whereArgs: [id]);
  }
}
