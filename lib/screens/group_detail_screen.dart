import 'package:flutter/material.dart';

class GroupTask {
  String text;
  String createdBy;
  Map<String, bool> completedBy;
  String priority; // 'High', 'Medium', 'Low'

  GroupTask({
    required this.text,
    required this.createdBy,
    required this.completedBy,
    required this.priority,
  });
}

class GroupDetailScreen extends StatefulWidget {
  final String groupName;
  final int memberCount;

  const GroupDetailScreen({
    super.key,
    required this.groupName,
    required this.memberCount,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _taskController = TextEditingController();
  late List<GroupTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [
      GroupTask(
        text: 'Clean the house',
        createdBy: 'You',
        completedBy: {'You': true, 'Mom': true, 'Dad': false},
        priority: 'High',
      ),
      GroupTask(
        text: 'Buy groceries for dinner',
        createdBy: 'Mom',
        completedBy: {'You': false, 'Mom': true, 'Dad': false},
        priority: 'Medium',
      ),
      GroupTask(
        text: 'Plan weekend trip',
        createdBy: 'Dad',
        completedBy: {'You': false, 'Mom': false, 'Dad': false},
        priority: 'Low',
      ),
    ];
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(
          GroupTask(
            text: _taskController.text,
            createdBy: 'You',
            completedBy: {'You': false, 'Mom': false, 'Dad': false},
            priority: 'Medium',
          ),
        );
        _taskController.clear();
      });
    }
  }

  void _toggleTaskCompletion(int index, String member) {
    setState(() {
      _tasks[index].completedBy[member] =
          !(_tasks[index].completedBy[member] ?? false);
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFFF5252);
      case 'Medium':
        return const Color(0xFFFFB74D);
      case 'Low':
        return const Color(0xFF00D95F);
      default:
        return const Color(0xFF999999);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.people, size: 14, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(
                  '${widget.memberCount} members',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Invite'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Group Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: const InputDecoration(
                              hintText: 'What does the group need to do?',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D95F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _addTask,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Get AI Suggestions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8B7BF7),
                          side: const BorderSide(color: Color(0xFF8B7BF7)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    final completedCount = task.completedBy.values
                        .where((v) => v)
                        .length;
                    final totalMembers = task.completedBy.length;
                    final isCompleted = task.completedBy['You'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _toggleTaskCompletion(index, 'You'),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? const Color(0xFF00D95F)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isCompleted
                                          ? const Color(0xFF00D95F)
                                          : const Color(0xFF666666),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  task.text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    task.priority,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: _getPriorityColor(task.priority),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.priority,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getPriorityColor(task.priority),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Created by ${task.createdBy}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Completed by $completedCount of $totalMembers',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: task.completedBy.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: entry.value
                                      ? const Color(0xFF00D95F).withOpacity(0.2)
                                      : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      entry.value ? Icons.check : Icons.circle,
                                      size: 12,
                                      color: entry.value
                                          ? const Color(0xFF00D95F)
                                          : const Color(0xFF666666),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: entry.value
                                            ? const Color(0xFF00D95F)
                                            : const Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
