import 'package:baby/home/activ/active.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:baby/home/color.dart'; // Ensure this file contains AppColors and AppStyles
import 'package:baby/home/activ/activity.dart'; // Ensure this file contains Activity and ActivityManager

class ActivityChartDialog extends StatelessWidget {
  final DateTime selectedDate;

  const ActivityChartDialog({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityManager>(
      builder: (context, activityManager, child) {
        final activities = activityManager.getActivitiesForDate(selectedDate);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                activities.isEmpty
                    ? _buildEmptyState()
                    : _buildActivityList(activities),
                _buildCloseButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Activity Chart',
          style: AppStyles.heading.copyWith(fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          DateFormat('MMMM d, yyyy').format(selectedDate),
          style: AppStyles.subheading.copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No activities for this day.',
              style: AppStyles.body.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        child: Text('Close'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildActivityList(List<Activity> activities) {
    return Container(
      height: 300,
      child: ListView.separated(
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          return ActivityListTile(activity: activities[index]);
        },
      ),
    );
  }
}

class ActivityListTile extends StatelessWidget {
  final Activity activity;

  const ActivityListTile({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      leading: CircleAvatar(
        child: SvgPicture.asset(
          activity.iconAsset,
          width: 24,
          height: 24,
        ),
      ),
      title: Text(
        activity.title,
        style: AppStyles.subheading.copyWith(fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(
            'Duration: ${activity.duration.inMinutes} min',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            'Start: ${_formatTime(activity.startTime)}',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
      trailing: _buildCompletionIndicator(),
    );
  }

  Widget _buildCompletionIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: activity.completed ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        activity.completed ? 'Completed' : 'Pending',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}
