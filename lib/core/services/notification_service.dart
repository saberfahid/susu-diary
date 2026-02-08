import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  final _random = Random();

  // Cute & funny notification messages!
  static const List<Map<String, String>> _cuteMessages = [
    {'title': 'Hey Cutie! \u{1F338}', 'body': 'Your diary misses you! Come write something sweet~'},
    {'title': 'Psst... \u{1F431}', 'body': 'Susu is lonely! Tell me about your day~'},
    {'title': 'Dear Diary Time! \u{1F4D6}', 'body': 'Your feelings matter! Let\'s capture them together \u2728'},
    {'title': 'Knock Knock! \u{1F49B}', 'body': 'Who\'s there? Your diary, waiting for your story!'},
    {'title': 'Meow~ \u{1F63A}', 'body': 'Don\'t forget to pet your diary today!'},
    {'title': 'Brain Dump Time! \u{1F9E0}', 'body': 'Empty your thoughts here, no judgment! \u{1F60A}'},
    {'title': 'Sparkle Check \u2728', 'body': 'You\'re doing amazing sweetie! Write it down!'},
    {'title': 'Susu Says Hi! \u{1F44B}', 'body': 'A moment of reflection makes life brighter \u{1F31F}'},
    {'title': 'Diary O\'Clock! \u23F0', 'body': 'Time to spill the tea! \u{1F375} What happened today?'},
    {'title': 'Feeling Check! \u{1F495}', 'body': 'How\'s your heart today? Tell Susu everything~'},
    {'title': 'Plot Twist! \u{1F300}', 'body': 'Your life story needs today\'s chapter!'},
    {'title': 'Hey Superstar! \u{1F31F}', 'body': 'Even small moments deserve to be remembered \u{1F496}'},
  ];

  Map<String, String> get _randomMessage => _cuteMessages[_random.nextInt(_cuteMessages.length)];

  NotificationService._init();

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    
    // Set the local timezone
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final locationName = 'Etc/GMT${offset.isNegative ? '+' : '-'}${offset.inHours.abs()}';
    try {
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (_) {
      // Fallback to UTC if location not found
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permission on Android 13+
    await requestPermissions();

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to diary entry screen
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.cancelAll();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final msg = _randomMessage;
    await _notifications.zonedSchedule(
      0,
      msg['title']!,
      msg['body']!,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily reminder to write in your diary',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  Future<void> showTestNotification() async {
    final msg = _randomMessage;
    await _notifications.show(
      999,
      msg['title']!,
      msg['body']!,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
