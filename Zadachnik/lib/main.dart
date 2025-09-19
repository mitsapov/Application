// Импорт необходимых пакетов Flutter
import 'package:flutter/material.dart';// Импорт пакета для работы с SQLite базой данных
import 'database_helper.dart';
// Импорт модели данных Task из локального файла
import 'task.dart';

/// Функция main() - точка входа в приложение Flutter
/// Все приложения Flutter должны иметь функцию main(), которая запускает приложение
void main() {
  // Запуск приложения с виджетом MyApp в качестве корневого
  runApp(const MyApp());
}

/// Класс MyApp является корневым виджетом приложения
/// Наследуется от StatelessWidget, так как не требует изменения состояния
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// MaterialApp - основа приложения, использующего Material Design
    /// Он предоставляет навигацию, темы и другие базовые функции
    return MaterialApp(
      title: 'DoList', // Название приложения
      theme: ThemeData(
        primarySwatch: Colors.blue, // Основной цвет приложения
        useMaterial3: true, // Использовать Material 3 дизайн
      ),
      home: const TaskManagerScreen(), // Стартовый экран приложения
    );
  }
}

/// Класс TaskManagerScreen - основной экран приложения
/// Наследуется от StatefulWidget, так как требует изменения состояния
class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

/// Класс _TaskManagerScreenState управляет состоянием виджета TaskManagerScreen
class _TaskManagerScreenState extends State<TaskManagerScreen> {
  /// Контроллер для текстового поля ввода новых задач
  /// TextEditingController позволяет управлять текстом в TextField
  final TextEditingController _taskInputController = TextEditingController();
  
  /// Список задач
  /// СОВЕТ: Для сложных приложений лучше использовать отдельный класс для управления состоянием
  final List<Task> _tasks = [];
  
  /// Переменная для отслеживания задачи, которую редактируют
  /// Если null - значит, мы добавляем новую задачу, а не редактируем существующую
  Task? _editingTask;
  
  /// Экземпляр DatabaseHelper для работы с базой данных
  /// Используем паттерн Singleton для доступа к базе данных
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    /// initState() вызывается один раз при создании виджета
    super.initState();
    _loadTasks(); // Загружаем задачи из БД при инициализации
  }

  @override
  void dispose() {
    /// dispose() вызывается при удалении виджета из дерева
    /// Здесь нужно освобождать ресурсы (контроллеры, подписки и т.д.)
    _taskInputController.dispose(); // Освобождаем контроллер
    _dbHelper.close(); // Закрываем соединение с БД
    super.dispose();
  }

  /// Загрузка задач из базы данных
  /// 
  /// Все операции с БД являются асинхронными, используем await
  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.getAllTasks();
    setState(() {
      _tasks.clear();
      _tasks.addAll(tasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Расчет количества выполненных задач
    final completedTasksCount = _tasks.where((task) => task.isCompleted).length;
    
    /// Scaffold обеспечивает базовую структуру экрана Material Design
    /// Содержит AppBar, тело экрана и FloatingActionButton
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoLis'), // Заголовок AppBar
        actions: [
          /// Отображение счетчика выполненных задач в виде Chip в AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: Text('$completedTasksCount/${_tasks.length} выполнено'),
            ),
          ),
        ],
      ),
      body: _buildBody(), // Тело экрана
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrEditTask, // Обработчик нажатия на кнопку
        child: const Icon(Icons.add), // Иконка кнопки
      ),
    );
  }

  /// Метод для построения тела экрана
  Widget _buildBody() {
    return Column(
      children: [
        _buildTaskInput(), // Поле для ввода задач
        const SizedBox(height: 16), // Отступ между элементами
        Expanded(
          /// Условный рендеринг: показываем список задач или пустое состояние
          child: _tasks.isEmpty ? _buildEmptyState() : _buildTaskList(),
        ),
      ],
    );
  }

  /// Виджет для ввода новых задач
  Widget _buildTaskInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _taskInputController, // Связываем контроллер с TextField
        decoration: InputDecoration(
          labelText: _editingTask == null ? 'Новая задача' : 'Редактирование задачи',
          border: const OutlineInputBorder(), // Граница поля ввода
          /// Условное отображение иконки отмены при редактировании
          suffixIcon: _editingTask != null
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: _cancelEditing,
                )
              : null,
        ),
        /// Обработчик нажатия Enter на клавиатуре
        onSubmitted: (_) => _addOrEditTask(),
      ),
    );
  }

  /// Виджет для отображения пустого состояния
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey), // Иконка
          SizedBox(height: 16), // Отступ
          Text(
            'Задачи отсутствуют',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Добавьте новую задачу с помощью кнопки ниже',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Метод для построения списка задач
  Widget _buildTaskList() {
    /// ListView.separated более эффективен для длинных списков,
    /// чем ListView(children: []), так как создает элементы только когда они нужны на экране
    return ListView.separated(
      itemCount: _tasks.length, // Количество элементов в списке
      separatorBuilder: (context, index) => const Divider(height: 1), // Разделитель между элементами
      itemBuilder: (context, index) {
        final task = _tasks[index]; // Получаем задачу по индексу
        return _buildTaskItem(task); // Строим элемент списка
      },
    );
  }

  /// Метод для построения отдельного элемента списка задач
  Widget _buildTaskItem(Task task) {
    /// Dismissible позволяет удалять элементы свайпом
    /// Требует уникального ключа для правильной работы анимаций
    return Dismissible(
      key: Key(task.id), // Уникальный ключ на основе id задачи
      direction: DismissDirection.endToStart, // Направление свайпа (справа налево)
      background: _buildDismissibleBackground(), // Фон при свайпе
      confirmDismiss: (direction) => _confirmDismiss(task), // Подтверждение удаления
      onDismissed: (direction) => _deleteTask(task), // Обработчик удаления
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted, // Текущее состояние checkbox
          onChanged: (value) => _toggleTaskCompletion(task, value!), // Обработчик изменения
        ),
        title: Text(
          task.title,
          /// Условное оформление текста: зачеркивание для выполненных задач
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кнопка редактирования
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _startEditingTask(task),
            ),
            // Кнопка удаления
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(task), // Подтверждение удаления
            ),
          ],
        ),
      ),
    );
  }

  /// Метод для построения фона при свайпе элемента
  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.red, // Красный фон
      alignment: Alignment.centerRight, // Выравнивание по правому краю
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white), // Иконка корзины
    );
  }

  /// Метод для добавления или редактирования задачи
  Future<void> _addOrEditTask() async {
    final text = _taskInputController.text.trim(); // Получаем и очищаем текст
    
    /// Проверяем ввод пользователя
    if (text.isEmpty) return; // Игнорируем пустой ввод

    /// setState() уведомляет Flutter о изменении состояния
    /// Это приводит к перерисовке виджета с новыми данными
    setState(() {
      if (_editingTask != null) {
        // Режим редактирования существующей задачи
        final index = _tasks.indexWhere((t) => t.id == _editingTask!.id);
        if (index != -1) {
          final updatedTask = _tasks[index].copyWith(title: text);
          _tasks[index] = updatedTask;
          _dbHelper.updateTask(updatedTask); // Обновляем в БД
        }
        _editingTask = null; // Сбрасываем режим редактирования
      } else {
        // Режим добавления новой задачи
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Генерируем уникальный id
          title: text,
        );
        _tasks.add(newTask);
        _dbHelper.insertTask(newTask); // Сохраняем в БД
      }
      _taskInputController.clear(); // Очищаем поле ввода
    });
  }

  /// Метод для начала редактирования задачи
  void _startEditingTask(Task task) {
    setState(() {
      _editingTask = task; // Устанавливаем задачу для редактирования
      _taskInputController.text = task.title; // Заполняем поле ввода текстом задачи
    });
  }

  /// Метод для отмены редактирования
  void _cancelEditing() {
    setState(() {
      _editingTask = null; // Сбрасываем режим редактирования
      _taskInputController.clear(); // Очищаем поле ввода
    });
  }

  /// Метод для подтверждения удаления задачи
  Future<bool?> _confirmDismiss(Task task) async {
    /// showDialog отображает модальное диалоговое окно
    /// Возвращает Future, который завершается при закрытии диалога
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление задачи'),
          content: Text('Вы уверены, что хотите удалить задачу "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Отмена удаления
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Подтверждение удаления
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  /// Метод для подтверждения удаления через кнопку
  /// 
  /// Предоставляем пользователю два способа удаления:
  /// через свайп и через кнопку
  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление задачи'),
          content: Text('Вы уверены, что хотите удалить задачу "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteTask(task);
    }
  }

  /// Метод для удаления задачи
  Future<void> _deleteTask(Task task) async {
    // Сначала удаляем из БД
    await _dbHelper.deleteTask(task.id);
    
    // Затем обновляем UI
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    
    // Показываем уведомление с возможностью отмены
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задача "${task.title}" удалена'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () async {
            // Восстанавливаем задачу
            await _dbHelper.insertTask(task);
            setState(() {
              _tasks.add(task);
            });
          },
        ),
      ),
    );
  }

  /// Метод для переключения статуса выполнения задачи
  Future<void> _toggleTaskCompletion(Task task, bool isCompleted) async {
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    
    // Сначала обновляем в БД
    await _dbHelper.updateTask(updatedTask);
    
    // Затем обновляем UI
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
  }
}