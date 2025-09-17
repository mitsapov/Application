// Импорт необходимых пакетов Flutter
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    /// initState() вызывается один раз при создании виджета
    /// Так же здесь можно выполнить инициализацию данных
    super.initState();
    // Так же здесь можно загрузить сохраненные задачи (опционально)
  }

  @override
  void dispose() {
    /// dispose() вызывается при удалении виджета из дерева
    /// Здесь нужно освобождать ресурсы (контроллеры, подписки и т.д.)
    _taskInputController.dispose(); // Освобождаем контроллер
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Расчет количества выполненных задач
    /// СОВЕТ: Функциональный подход к обработке коллекций часто более читаем
    final completedTasksCount = _tasks.where((task) => task.isCompleted).length;
    
    /// Scaffold обеспечивает базовую структуру экрана Material Design
    /// Содержит AppBar, тело экрана и FloatingActionButton
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер задач'), // Заголовок AppBar
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
        trailing: IconButton(
          icon: const Icon(Icons.edit), // Иконка редактирования
          onPressed: () => _startEditingTask(task), // Обработчик нажатия
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
  void _addOrEditTask() {
    final text = _taskInputController.text.trim(); // Получаем и очищаем текст
    
    /// Всегда проверяем ввод пользователя
    if (text.isEmpty) return; // Игнорируем пустой ввод

    /// setState() уведомляет Flutter о изменении состояния
    /// Это приводит к перерисовке виджета с новыми данными
    setState(() {
      if (_editingTask != null) {
        // Режим редактирования существующей задачи
        final index = _tasks.indexWhere((t) => t.id == _editingTask!.id);
        if (index != -1) {
          _tasks[index] = _tasks[index].copyWith(title: text); // Обновляем задачу
        }
        _editingTask = null; // Сбрасываем режим редактирования
      } else {
        // Режим добавления новой задачи
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Генерируем уникальный id
          title: text,
        );
        _tasks.add(newTask); // Добавляем задачу в список
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

  /// Метод для удаления задачи
  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id); // Удаляем задачу из списка
    });
    
    /// Показываем уведомление об удалении с возможностью отмены
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задача "${task.title}" удалена'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            // Возвращаем задачу при отмене удаления
            setState(() {
              _tasks.add(task);
            });
          },
        ),
      ),
    );
  }

  /// Метод для переключения статуса выполнения задачи
  void _toggleTaskCompletion(Task task, bool isCompleted) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        // Обновляем статус выполнения задачи
        _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
      }
    });
  }
}