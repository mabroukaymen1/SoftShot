import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:baby/home/activ/active.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // Handle background message
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late final FirebaseMessaging _firebaseMessaging;
  String? _fcmToken;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;
    await _initializeAwesomeNotifications();
    await _configureFCM();
  }

  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/noti',
      [
        NotificationChannel(
          channelKey: 'activity_channel',
          channelName: 'Activity Notifications',
          channelDescription: 'Notifications for baby activities',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        )
      ],
    );
  }

  Future<void> _configureFCM() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $_fcmToken");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print("FCM Token Updated: $newToken");
      // TODO: Send the new token to your server
    });
  }

  String? get fcmToken => _fcmToken;

  void _handleForegroundMessage(RemoteMessage message) {
    print("Handling a foreground message: ${message.messageId}");
    _showNotification(
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new notification',
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print("Handling a background message: ${message.messageId}");
    // Handle notification tap when app is in background
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'activity_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        icon: 'resource://drawable/noti',
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'activity_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        icon: 'resource://drawable/noti',
      ),
    );
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void _showNotification(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'activity_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        icon: 'resource://drawable/noti',
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

class NotificationManager {
  final NotificationService _notificationService = NotificationService();

  Future<void> scheduleActivityNotifications(Activity activity) async {
    if (activity.type == ActivityType.breastfeeding) {
      await _scheduleBreastfeedingNotifications(activity);
    } else if (activity.type == ActivityType.vaccination) {
      await _scheduleVaccinationNotifications(activity);
    } else {
      await _scheduleRegularActivityNotification(activity);
    }
  }

  Future<void> _scheduleBreastfeedingNotifications(Activity activity) async {
    final endOfDay = DateTime(activity.startTime.year, activity.startTime.month,
            activity.startTime.day, 23, 59)
        .add(Duration(days: 1));

    DateTime currentTime = activity.startTime;
    int notificationId = activity.id.hashCode;

    while (currentTime.isBefore(endOfDay)) {
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: 'Breastfeeding Reminder',
        body: 'Your breastfeeding session is scheduled in 5 minutes',
        scheduledDate: currentTime.subtract(Duration(minutes: 5)),
      );

      currentTime = currentTime.add(Duration(hours: 2));
      notificationId++;
    }
  }

  Future<void> _scheduleVaccinationNotifications(Activity activity) async {
    final List<int> hoursBeforeActivity = [24, 6, 2, 1];

    for (int hours in hoursBeforeActivity) {
      final scheduledTime = activity.startTime.subtract(Duration(hours: hours));
      final notificationId =
          activity.id.hashCode + hours; // Unique ID for each notification

      await _notificationService.scheduleNotification(
        id: notificationId,
        title: 'Upcoming Vaccination',
        body:
            'Your vaccination is scheduled in $hours hour${hours == 1 ? '' : 's'}',
        scheduledDate: scheduledTime,
      );
    }
  }

  Future<void> _scheduleRegularActivityNotification(Activity activity) async {
    final timeString = DateFormat.jm().format(activity.startTime);
    await _notificationService.scheduleNotification(
      id: activity.id.hashCode,
      title: '${activity.title} in 5 minutes',
      body: 'You have ${activity.title} scheduled for $timeString',
      scheduledDate: activity.startTime.subtract(Duration(minutes: 5)),
    );
  }

  Future<void> cancelActivityNotifications(Activity activity) async {
    if (activity.type == ActivityType.vaccination) {
      final List<int> hoursBeforeActivity = [24, 6, 2, 1];
      for (int hours in hoursBeforeActivity) {
        await _notificationService
            .cancelNotification(activity.id.hashCode + hours);
      }
    } else {
      await _notificationService.cancelNotification(activity.id.hashCode);
    }
  }
}
