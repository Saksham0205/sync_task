import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../models/group.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Schedule notification for a task deadline
  Future<void> scheduleTaskDeadlineNotification({
    required String taskId,
    required String taskText,
    required DateTime deadline,
    required TaskPriority priority,
    bool isGroupTask = false,
    String? groupId,
  }) async {
    if (!_initialized) await initialize();

    // Calculate notification time (30 minutes before deadline)
    final notificationTime = deadline.subtract(const Duration(minutes: 30));

    // Don't schedule if the notification time is in the past
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final notificationId = _generateNotificationId(taskId, isGroupTask);

    // Generate the notification details with report
    final notificationDetails = await _generateNotificationDetails(
      taskId: taskId,
      isGroupTask: isGroupTask,
      groupId: groupId,
    );

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      '⏰ Task Deadline Approaching',
      notificationDetails,
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_deadlines',
          'Task Deadlines',
          channelDescription: 'Notifications for task deadline reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(
    String taskId, {
    bool isGroupTask = false,
  }) async {
    final notificationId = _generateNotificationId(taskId, isGroupTask);
    await _notificationsPlugin.cancel(notificationId);
  }

  // Generate notification ID from task ID
  int _generateNotificationId(String taskId, bool isGroupTask) {
    // Generate a unique int ID from the string taskId
    final prefix = isGroupTask ? 1 : 0;
    final hash =
        taskId.hashCode.abs() % 1000000; // Keep it within reasonable range
    return prefix * 10000000 + hash;
  }

  // Generate notification details with task report
  Future<String> _generateNotificationDetails({
    required String taskId,
    required bool isGroupTask,
    String? groupId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Task deadline is approaching!';

    try {
      if (isGroupTask && groupId != null) {
        return await _generateGroupTaskReport(groupId, taskId, user.uid);
      } else {
        return await _generatePersonalTaskReport(user.uid);
      }
    } catch (e) {
      print('Error generating notification details: $e');
      return 'Task deadline is approaching!';
    }
  }

  // Generate report for personal tasks
  Future<String> _generatePersonalTaskReport(String userId) async {
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('completed', isEqualTo: false)
        .get();

    if (tasksSnapshot.docs.isEmpty) {
      return 'All tasks completed! 🎉';
    }

    final incompleteTasks = tasksSnapshot.docs
        .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Count by priority
    final priorityCounts = <TaskPriority, int>{};
    for (var task in incompleteTasks) {
      priorityCounts[task.priority] = (priorityCounts[task.priority] ?? 0) + 1;
    }

    final buffer = StringBuffer();
    buffer.write('${incompleteTasks.length} incomplete task(s): ');

    final priorityParts = <String>[];
    if (priorityCounts[TaskPriority.critical] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.critical]} Critical');
    }
    if (priorityCounts[TaskPriority.high] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.high]} High');
    }
    if (priorityCounts[TaskPriority.medium] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.medium]} Medium');
    }
    if (priorityCounts[TaskPriority.low] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.low]} Low');
    }

    buffer.write(priorityParts.join(', '));

    return buffer.toString();
  }

  // Generate report for group tasks
  Future<String> _generateGroupTaskReport(
    String groupId,
    String taskId,
    String userId,
  ) async {
    final groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();

    if (!groupDoc.exists) {
      return 'Group task deadline is approaching!';
    }

    final groupData = groupDoc.data()!;
    final groupName = groupData['name'] as String;
    final tasks =
        (groupData['tasks'] as List<dynamic>?)
            ?.map((t) => GroupTask.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    // Get current username
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final username = userDoc.data()?['username'] as String? ?? 'You';

    // Find incomplete tasks
    final incompleteTasks = tasks.where((task) {
      final isCompleted = task.completedBy[username] ?? false;
      return !isCompleted;
    }).toList();

    if (incompleteTasks.isEmpty) {
      return 'All tasks in "$groupName" completed! 🎉';
    }

    // Count by priority
    final priorityCounts = <TaskPriority, int>{};
    for (var task in incompleteTasks) {
      priorityCounts[task.priority] = (priorityCounts[task.priority] ?? 0) + 1;
    }

    final buffer = StringBuffer();
    buffer.write('$groupName: ${incompleteTasks.length} incomplete task(s) - ');

    final priorityParts = <String>[];
    if (priorityCounts[TaskPriority.critical] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.critical]} Critical');
    }
    if (priorityCounts[TaskPriority.high] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.high]} High');
    }
    if (priorityCounts[TaskPriority.medium] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.medium]} Medium');
    }
    if (priorityCounts[TaskPriority.low] != null) {
      priorityParts.add('${priorityCounts[TaskPriority.low]} Low');
    }

    buffer.write(priorityParts.join(', '));

    // Add info about who hasn't completed
    final currentTask = tasks.firstWhere((t) => t.id == taskId);
    final incompleteMemberNames = currentTask.completedBy.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    if (incompleteMemberNames.isNotEmpty) {
      buffer.write('. Not completed by: ${incompleteMemberNames.join(", ")}');
    }

    return buffer.toString();
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'general',
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
