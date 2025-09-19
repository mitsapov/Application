/// Класс Task представляет модель данных для задачи
/// Содержит три поля: id, title и isCompleted
class Task {
  final String id; // Уникальный идентификатор задачи
  String title; // Название задачи
  bool isCompleted; // Статус выполнения задачи

  /// Конструктор класса Task
  Task({
    required this.id, // Обязательный параметр id
    required this.title, // Обязательный параметр title
    this.isCompleted = false, // Необязательный параметр, по умолчанию false
  });

/// Конвертируем задачу в Map для сохранения в базе данных
  /// 
  /// Ключи Map должны соответствовать названиям столбцов в таблице
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0, // SQLite не поддерживает bool, используем 0/1
    };
  }

  /// Создаем задачу из Map (данных из базы)
  /// Документация: https://docs.flutter.dev/cookbook/persistence/sqlite
  /// Этот factory constructor позволяет легко создавать объекты из данных БД
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1, // Конвертируем 1/0 обратно в bool
    );
  }

  /// Метод copyWith создает копию задачи с возможностью изменения полей
  /// Это распространенный паттерн в Flutter для работы с неизменяемыми данными
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id, // Если id не указан, используем текущий
      title: title ?? this.title, // Если title не указан, используем текущий
      isCompleted: isCompleted ?? this.isCompleted, // Если isCompleted не указан, используем текущий
    );
  }
}