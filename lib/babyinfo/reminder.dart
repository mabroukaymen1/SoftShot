import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:baby/home/activ/activity.dart';
import 'package:baby/home/activ/active.dart';
import 'package:baby/home/color.dart';
import 'package:baby/home/drawer.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: SharedDrawer(),
      body: Consumer<ActivityManager>(
        builder: (context, activityManager, child) {
          final allActivities = _getAllActivitiesSorted(activityManager);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBreastfeedingSummary(allActivities),
                      const SizedBox(height: 16),
                      Text('All Activities', style: AppStyles.subheading),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < allActivities.length) {
                      return _buildActivityTile(
                        allActivities[index],
                        activityManager,
                        context,
                      );
                    }
                    return null;
                  },
                  childCount: allActivities.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
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
      title: Text('Reminders & Activities', style: AppStyles.heading),
      actions: const [
        CircleAvatar(
          backgroundImage: AssetImage('image/baby.png'),
          radius: 18,
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBreastfeedingSummary(List<Activity> allActivities) {
    final breastfeedingCount = allActivities
        .where((activity) => activity.type == ActivityType.breastfeeding)
        .length;

    return Card(
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Breastfeeding Sessions:',
              style: AppStyles.subheading.copyWith(color: Colors.white),
            ),
            Text(
              '$breastfeedingCount',
              style: AppStyles.subheading.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Activity activity, ActivityManager activityManager,
      BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
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
                    Text(activity.title, style: AppStyles.subheading),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(activity.startTime)} at ${timeFormat.format(activity.startTime)}',
                      style: AppStyles.caption,
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

  List<Activity> _getAllActivitiesSorted(ActivityManager activityManager) {
    final allActivities = activityManager.daysWithActivities
        .expand((date) => activityManager.getActivitiesForDate(date))
        .toList();
    allActivities.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allActivities;
  }
}
