/// Класс для работы с базой данных
/// 
library;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'task.dart'; 

/// Класс-помощник для работы с базой данных SQLite
/// 
/// Реализует паттерн Singleton, чтобы гарантировать одно подключение к БД
/// 
/// Все операции с базой данных являются асинхронными и возвращают Future
/// 
/// Документация: (https://medium.com/@hemant.ramphul/complete-sqlite-crud-operations-in-flutter-6cbba8582c45)
class DatabaseHelper {
  // Singleton паттерн
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _databaseName = 'tasks.db';
  static const int _databaseVersion = 1;

  // Название таблицы и имена столбцов
  static const String tableTasks = 'tasks';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnIsCompleted = 'isCompleted';

  /// Получаем подключение к базе данных (создаем если нет)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Инициализация базы данных
  /// 
  /// SQLite хранит базу в файле, нужно указать правильный путь
  /// path_provider помогает получить правильный путь для каждой платформы
  Future<Database> _initDatabase() async {
    // Получаем директорию для хранения базы данных
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    // Открываем/создаем базу данных
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Создание таблицы при первом запуске приложения
  /// 
  /// SQLite не поддерживает тип boolean, используем INTEGER (0/1)
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTasks (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnIsCompleted INTEGER NOT NULL
      )
    ''');
  }

  /// CRUD операции

  /// Добавить задачу в базу данных
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      tableTasks, 
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Заменяем если запись уже exists
    );
  }

  /// Получить все задачи из базы данных
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableTasks);
    
    // Конвертируем каждую Map в объект Task
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  /// Обновить задачу в базе данных
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      tableTasks,
      task.toMap(),
      where: '$columnId = ?',
      whereArgs: [task.id], // Защита от SQL-инъекций
    );
  }

  /// Удалить задачу из базы данных
  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      tableTasks,
      where: '$columnId = ?',
      whereArgs: [id], // Защита от SQL-инъекций
    );
  }

  /// Закрыть подключение к базе данных
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}