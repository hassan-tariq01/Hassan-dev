import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import '../models/task_model.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();

  static Database? _database;

  TaskDatabase._init();

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const boolType = 'INTEGER';

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description $textType,
        date $textType,
        isCompleted $boolType,
        isRepeated $boolType,
        repeatDays $textType
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    final db = await _db;
    debugPrint('Inserting task: ${task.title}');
    return await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks({bool? completed}) async {
    final db = await _db;
    final List<Map<String, dynamic>> taskMaps = await db.query(
      'tasks',
      where: completed == null ? null : 'isCompleted = ?',
      whereArgs: completed == null ? null : [completed ? 1 : 0],
    );
    debugPrint('Fetched ${taskMaps.length} tasks');
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await _db;
    debugPrint('Updating task: ${task.title}, isCompleted: ${task.isCompleted}');
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _db;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> exportToCsv() async {
    final tasks = await getTasks();
    List<List<dynamic>> csvData = [
      ['ID', 'Title', 'Description', 'Date', 'Completed', 'Repeated', 'Repeat Days'],
      ...tasks.map((task) => [
        task.id ?? '',
        task.title,
        task.description,
        task.date.toIso8601String(),
        task.isCompleted ? 'Yes' : 'No',
        task.isRepeated ? 'Yes' : 'No',
        task.repeatDays,
      ]),
    ];
    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getTemporaryDirectory();
    final path = join(directory.path, 'tasks.csv');
    final file = File(path);
    await file.writeAsString(csv);
    debugPrint('Exported CSV to: $path');
    return path;
  }

  Future<void> debugTasks() async {
    final db = await _db;
    final tasks = await db.query('tasks');
    debugPrint('Tasks in database: $tasks');
  }

  Future<void> clearDatabase() async {
    final db = await _db;
    await db.delete('tasks');
    debugPrint('Database cleared');
  }

  Future close() async {
    final db = await _db;
    db.close();
  }
}

void debugPrint(String s) {
}