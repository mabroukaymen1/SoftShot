import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:baby/home/activ/activity.dart';
import 'package:baby/home/activ/active.dart';
import 'package:baby/home/bottombar.dart';
import 'package:baby/home/color.dart';
import 'package:baby/home/drawer.dart';
import 'package:baby/log_in/languge.dart';

class HomePage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const HomePage({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: SharedDrawer(),
      body: Consumer<ActivityManager>(
        builder: (context, activityManager, child) {
          final allActivities = activityManager.getAllActivities();
          final filteredActivities =
              _getRecentAndUpcomingActivities(allActivities);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDailyProgramCard(activityManager),
                      const SizedBox(height: 16),
                      _buildAdviceCard(context),
                      const SizedBox(height: 16),
                      _buildUpcomingActivityHeader(context),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < filteredActivities.length) {
                      return _buildActivityItem(
                          filteredActivities[index], activityManager);
                    }
                    return null;
                  },
                  childCount: filteredActivities.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SharedBottomAppBar(
        selectedIndex: 0,
        onItemSelected: (index) => _onBottomNavItemSelected(context, index),
      ),
    );
  }

  List<Activity> _getRecentAndUpcomingActivities(List<Activity> allActivities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    return allActivities.where((activity) {
      final activityDate = DateTime(
        activity.startTime.year,
        activity.startTime.month,
        activity.startTime.day,
      );
      return activityDate.isAtSameMomentAs(today) ||
          (activityDate.isAfter(today) && activityDate.isBefore(nextWeek));
    }).toList();
  }

  void _onBottomNavItemSelected(BuildContext context, int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/daily');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.grid_view, color: AppColors.text),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).translate('today'),
              style: AppStyles.heading),
          Text(
            DateFormat('dd MMM yyyy').format(DateTime.now()),
            style: AppStyles.caption,
          ),
        ],
      ),
      actions: const [
        CircleAvatar(
          backgroundImage: AssetImage('image/baby.png'),
          radius: 18,
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/chat');
      },
      backgroundColor: AppColors.primary,
      child: SvgPicture.asset(
        'image/svg/chat.svg',
        width: 24,
        height: 24,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDailyProgramCard(ActivityManager activityManager) {
    final progress = activityManager.getProgressPercentage(DateTime.now());
    final completedActivities =
        activityManager.getCompletedActivitiesCount(DateTime.now());
    final totalActivities =
        activityManager.getActivitiesForDate(DateTime.now()).length;
    final daysWithActivities = activityManager.daysWithActivities;

    return Card(
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).translate('daily_program'),
                style: AppStyles.subheading.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        AppLocalizations.of(context).translate(
                            'total_activities',
                            {'count': totalActivities.toString()}),
                        style: AppStyles.body.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                        AppLocalizations.of(context).translate(
                            'completed_activities',
                            {'count': completedActivities.toString()}),
                        style: AppStyles.body.copyWith(color: Colors.white)),
                  ],
                ),
                CircularProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                AppLocalizations.of(context).translate('days_with_activities',
                    {'count': daysWithActivities.length.toString()}),
                style: AppStyles.body.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context) {
    return Card(
      color: AppColors.accent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).translate('tips'),
                style: AppStyles.caption.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).translate('newborn_baby_care'),
              style: AppStyles.subheading.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset('image/da.png', height: 120),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/breastfeeding_guide');
                },
                child: Text(
                    AppLocalizations.of(context).translate('learn_more'),
                    style: TextStyle(color: AppColors.accent)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingActivityHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context).translate('upcoming_activities'),
            style: AppStyles.subheading),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/daily'),
          child: Text(AppLocalizations.of(context).translate('see_all'),
              style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      Activity activity, ActivityManager activityManager) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to activity details page
          _showActivityDetails(context, activity);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                child: activity.getIcon(size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).translate(activity.title),
                        style: AppStyles.subheading),
                    const SizedBox(height: 4),
                    Text(
                      activity.completed
                          ? AppLocalizations.of(context).translate('completed')
                          : AppLocalizations.of(context).translate(
                              'scheduled_for', {
                              'date': DateFormat('MMM dd, yyyy')
                                  .format(activity.startTime)
                            }),
                      style: TextStyle(
                        color: activity.completed
                            ? AppColors.success
                            : AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: activity.completed,
                onChanged: (value) {
                  activityManager.toggleActivityCompletion(activity);
                },
                activeColor: AppColors.primary,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityDetails(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(activity.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Type: ${activity.type.toString().split('.').last}'),
                Text('Description: ${activity.description}'),
                Text('Start Time: ${activity.startTime}'),
                Text('Duration: ${activity.duration}'),
                Text('Completed: ${activity.completed ? 'Yes' : 'No'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
