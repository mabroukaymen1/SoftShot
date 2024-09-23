import 'package:flutter/material.dart';
import 'package:baby/home/activ/active.dart';
import 'package:baby/home/activ/breast.dart';
import 'package:baby/notifff/notif.dart';

class ActivityManager extends ChangeNotifier {
  final Map<DateTime, List<Activity>> _activities = {};
  final Set<DateTime> _daysWithActivities = {};
  final NotificationManager _notificationManager;

  ActivityManager({required NotificationManager notificationManager})
      : _notificationManager = notificationManager;

  Set<DateTime> get daysWithActivities => _daysWithActivities;

  Future<void> addActivities(
      List<Activity> activities, BuildContext context) async {
    for (var activity in activities) {
      await addActivity(activity, context);
    }
  }

  Future<void> addActivity(Activity activity, BuildContext context) async {
    final date = _normalizeDate(activity.startTime);

    if (activity.type == ActivityType.breastfeeding) {
      await _handleBreastfeedingActivity(activity, date, context);
    } else if (activity.type == ActivityType.vaccination) {
      await _handleVaccinationActivity(activity, date);
    } else {
      await _addNewActivity(activity, date);
    }

    await _notificationManager.scheduleActivityNotifications(activity);
    notifyListeners();
  }

  Future<void> _handleBreastfeedingActivity(
      Activity activity, DateTime date, BuildContext context) async {
    final existingActivities = _activities[date] ?? [];
    final existingBreastfeeding = existingActivities
        .where((a) => a.type == ActivityType.breastfeeding)
        .toList();

    if (existingBreastfeeding.isEmpty) {
      final isFirstFeeding = await _showFirstBreastfeedingDialog(context);
      if (isFirstFeeding) {
        await _scheduleBreastfeedingActivities(activity.startTime);
      } else {
        await _addNewActivity(activity, date);
      }
    } else {
      final existingActivity = existingBreastfeeding.first;
      final updatedActivity = existingActivity.copyWith(
        startTime: activity.startTime,
        duration: activity.duration,
        leftDuration: activity.leftDuration,
        rightDuration: activity.rightDuration,
      );
      await updateActivity(updatedActivity);
    }
  }

  Future<bool> _showFirstBreastfeedingDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => FirstBreastfeedingDialog(),
        ) ??
        false;
  }

  Future<void> _scheduleBreastfeedingActivities(
      DateTime firstFeedingTime) async {
    final date = _normalizeDate(firstFeedingTime);
    final endOfDay = date.add(Duration(days: 1)).subtract(Duration(seconds: 1));
    DateTime currentTime = firstFeedingTime;

    while (currentTime.isBefore(endOfDay)) {
      await _addNewActivity(
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: ActivityType.breastfeeding,
          title: 'Breastfeeding',
          description: 'Scheduled breastfeeding',
          iconAsset: 'image/svg/mother.svg',
          startTime: currentTime,
          painScores: [],
          duration: Duration(minutes: 30),
          time: TimeOfDay.fromDateTime(currentTime),
        ),
        date,
      );
      currentTime = currentTime.add(Duration(hours: 2));
    }
  }

  Future<void> _handleVaccinationActivity(
      Activity activity, DateTime date) async {
    // Always add a new vaccination activity
    await _addNewActivity(activity, date);
  }

  Future<void> _addNewActivity(Activity activity, DateTime date) async {
    final newActivity =
        activity.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    _activities.update(date, (activities) => [...activities, newActivity],
        ifAbsent: () => [newActivity]);
    _daysWithActivities.add(date);
    notifyListeners();
  }

  Future<void> addBreastfeedingActivity(
      DateTime selectedDate, DateTime startTime, BuildContext context) async {
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.breastfeeding,
      title: 'Breastfeeding',
      description: 'Breastfeeding session',
      iconAsset: 'image/svg/mother.svg',
      startTime: startTime,
      painScores: [],
      duration: Duration(minutes: 30),
      time: TimeOfDay.fromDateTime(startTime),
    );
    await addActivity(activity, context);
  }

  Future<void> scheduleBreastfeedingActivities(
      DateTime firstFeedingTime, BuildContext context) async {
    final date = _normalizeDate(firstFeedingTime);
    final endOfDay = date.add(Duration(days: 1)).subtract(Duration(seconds: 1));
    DateTime currentTime = firstFeedingTime;

    while (currentTime.isBefore(endOfDay)) {
      await addActivity(
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: ActivityType.breastfeeding,
          title: 'Breastfeeding',
          description: 'Scheduled breastfeeding',
          iconAsset: 'image/svg/mother.svg',
          startTime: currentTime,
          painScores: [],
          duration: Duration(minutes: 30),
          time: TimeOfDay.fromDateTime(currentTime),
        ),
        context,
      );
      currentTime = currentTime.add(Duration(hours: 2));
    }
  }

  Activity? getActivityByType(ActivityType activityType) {
    try {
      return _activities.values
          .expand((list) => list)
          .firstWhere((activity) => activity.type == activityType);
    } catch (e) {
      print('Error in getActivityByType: $e');
      return null;
    }
  }

  double getProgressPercentage(DateTime date) {
    final activities = getActivitiesForDate(date);
    if (activities.isEmpty) return 0.0;
    final completedActivities = activities.where((a) => a.completed).length;
    return (completedActivities / activities.length) * 100;
  }

  int getCompletedActivitiesCount(DateTime date) {
    return getActivitiesForDate(date).where((a) => a.completed).length;
  }

  List<Activity> getActivitiesForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return _activities[normalizedDate] ?? [];
  }

  Future<void> toggleActivityCompletion(Activity activity) async {
    final updatedActivity = activity.copyWith(completed: !activity.completed);
    await updateActivity(updatedActivity);
  }

  Future<void> addPainScore(Activity activity, PainScore score) async {
    final updatedActivity =
        activity.copyWith(painScores: [...activity.painScores, score]);
    await updateActivity(updatedActivity);
  }

  List<Activity> getAllActivities() {
    return _activities.values.expand((list) => list).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> removeActivity(DateTime selectedDate, Activity activity) async {
    await deleteActivity(activity);
  }

  Future<void> updateActivity(Activity updatedActivity) async {
    final date = _normalizeDate(updatedActivity.startTime);
    final activities = _activities[date];
    if (activities != null) {
      final index = activities.indexWhere((a) => a.id == updatedActivity.id);
      if (index != -1) {
        activities[index] = updatedActivity;
        await _notificationManager
            .scheduleActivityNotifications(updatedActivity);
        notifyListeners();
      }
    }
  }

  Future<void> deleteActivity(Activity activity) async {
    final date = _normalizeDate(activity.startTime);
    _activities[date]?.removeWhere((a) => a.id == activity.id);
    if (_activities[date]?.isEmpty ?? false) {
      _activities.remove(date);
      _daysWithActivities.remove(date);
    }
    await _notificationManager.cancelActivityNotifications(activity);
    notifyListeners();
  }

  Activity? getMostRecentVaccination() {
    final vaccinations = _activities.values
        .expand((list) => list)
        .where((activity) => activity.type == ActivityType.vaccination);
    return vaccinations.isEmpty
        ? null
        : vaccinations
            .reduce((a, b) => a.startTime.isAfter(b.startTime) ? a : b);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
