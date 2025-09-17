import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Менеджер задач',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TaskManagerScreen(),
    );
  }
}

class Task {
  final String id;
  String title;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final TextEditingController _taskInputController = TextEditingController();
  final List<Task> _tasks = [];
  Task? _editingTask;

  @override
  void initState() {
    super.initState();
    // Загрузка сохраненных задач (реализуйте при необходимости)
  }

  @override
  void dispose() {
    _taskInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedTasksCount = _tasks.where((task) => task.isCompleted).length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер задач'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: Text('$completedTasksCount/${_tasks.length} выполнено'),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrEditTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTaskInput(),
        const SizedBox(height: 16),
        Expanded(
          child: _tasks.isEmpty ? _buildEmptyState() : _buildTaskList(),
        ),
      ],
    );
  }

  Widget _buildTaskInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _taskInputController,
        decoration: InputDecoration(
          labelText: _editingTask == null ? 'Новая задача' : 'Редактирование задачи',
          border: const OutlineInputBorder(),
          suffixIcon: _editingTask != null
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: _cancelEditing,
                )
              : null,
        ),
        onSubmitted: (_) => _addOrEditTask(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey),
          SizedBox(height: 16),
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

  Widget _buildTaskList() {
    return ListView.separated(
      itemCount: _tasks.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return _buildTaskItem(task);
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissibleBackground(),
      confirmDismiss: (direction) => _confirmDismiss(task),
      onDismissed: (direction) => _deleteTask(task),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTaskCompletion(task, value!),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _startEditingTask(task),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  void _addOrEditTask() {
    final text = _taskInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (_editingTask != null) {
        final index = _tasks.indexWhere((t) => t.id == _editingTask!.id);
        if (index != -1) {
          _tasks[index] = _tasks[index].copyWith(title: text);
        }
        _editingTask = null;
      } else {
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text,
        );
        _tasks.add(newTask);
      }
      _taskInputController.clear();
    });
  }

  void _startEditingTask(Task task) {
    setState(() {
      _editingTask = task;
      _taskInputController.text = task.title;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingTask = null;
      _taskInputController.clear();
    });
  }

  Future<bool?> _confirmDismiss(Task task) async {
    return showDialog<bool>(
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
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задача "${task.title}" удалена'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            setState(() {
              _tasks.add(task);
            });
          },
        ),
      ),
    );
  }

  void _toggleTaskCompletion(Task task, bool isCompleted) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
      }
    });
  }
}