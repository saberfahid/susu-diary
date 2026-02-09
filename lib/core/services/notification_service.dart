import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:shared_preferences/shared_preferences.dart';
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

    tzdata.initializeTimeZones();

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
      // Request notification permission
      final granted = await android.requestNotificationsPermission();
      // Also request exact alarm permission for Android 12+
      await android.requestExactAlarmsPermission();
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

  /// Convert a local DateTime to a TZDateTime in UTC.
  /// This avoids all timezone name resolution issues.
  tz.TZDateTime _localToTZDateTime(DateTime localDateTime) {
    // Convert local time to UTC using Dart's built-in conversion
    final utc = localDateTime.toUtc();
    return tz.TZDateTime.utc(
      utc.year, utc.month, utc.day,
      utc.hour, utc.minute, utc.second,
    );
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.cancelAll();

    // Build the target time in local DateTime (Dart handles local tz correctly)
    final now = DateTime.now();
    var scheduledLocal = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledLocal.isBefore(now)) {
      scheduledLocal = scheduledLocal.add(const Duration(days: 1));
    }

    // Convert to TZDateTime via UTC - bypasses all timezone name lookup issues
    final tzScheduled = _localToTZDateTime(scheduledLocal);

    final msg = _randomMessage;
    await _notifications.zonedSchedule(
      0,
      msg['title']!,
      msg['body']!,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_v2',
          'Daily Reminder',
          channelDescription: 'Daily reminder to write in your diary',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          sound: RawResourceAndroidNotificationSound('cute_notification'),
          enableVibration: true,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.reminder,
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
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_v2',
          'Daily Reminder',
          channelDescription: 'Daily reminder to write in your diary',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          sound: RawResourceAndroidNotificationSound('cute_notification'),
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Re-schedule reminder after device reboot.
  /// Called from main.dart on app start to ensure notifications persist.
  Future<void> rescheduleIfEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? false;
      if (enabled) {
        final hour = prefs.getInt('reminder_hour') ?? 21;
        final minute = prefs.getInt('reminder_minute') ?? 0;
        await scheduleDailyReminder(hour: hour, minute: minute);
      }
    } catch (_) {}
  }
}
