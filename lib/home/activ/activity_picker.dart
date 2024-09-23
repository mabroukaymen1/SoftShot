import 'package:baby/home/activ/breast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:baby/home/activ/activity.dart';
import 'package:baby/home/color.dart';
import 'package:baby/home/activ/active.dart';
import 'package:baby/log_in/languge.dart';

class ActivityPicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Activity activity) onActivityAdded;

  const ActivityPicker({
    Key? key,
    required this.selectedDate,
    required this.onActivityAdded,
  }) : super(key: key);

  @override
  _ActivityPickerState createState() => _ActivityPickerState();
}

class _ActivityPickerState extends State<ActivityPicker> {
  late ActivityManager _activityManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activityManager = Provider.of<ActivityManager>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              itemCount: ActivityType.values.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final activityType = ActivityType.values[index];
                return _buildActivityTile(context, activityType);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).translate('add_activity'),
            style: AppStyles.heading.copyWith(fontSize: 18),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, ActivityType activityType) {
    Activity activity = _getOrCreateActivity(context, activityType);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.yellow[100],
        child: SvgPicture.asset(
          activity.iconAsset,
          width: 24,
          height: 24,
        ),
      ),
      title: Text(activity.title, style: AppStyles.subheading),
      subtitle: Text(activity.description),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _handleActivitySelection(context, activity),
    );
  }

  Activity _getOrCreateActivity(
      BuildContext context, ActivityType activityType) {
    Activity? existingActivity =
        _activityManager.getActivityByType(activityType);
    if (existingActivity != null) {
      return existingActivity;
    }

    return Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: activityType,
      title: _getTitleForActivityType(context, activityType),
      description:
          AppLocalizations.of(context).translate('tap_to_add_activity'),
      iconAsset: _getIconAssetForActivityType(activityType),
      startTime: DateTime.now(),
      painScores: [],
      duration: const Duration(minutes: 30),
      time: TimeOfDay.now(),
    );
  }

  String _getTitleForActivityType(BuildContext context, ActivityType type) {
    switch (type) {
      case ActivityType.breastfeeding:
        return AppLocalizations.of(context).translate('breastfeeding');
      case ActivityType.vaccination:
        return AppLocalizations.of(context).translate('vaccination');
      default:
        return AppLocalizations.of(context)
            .translate(type.toString().split('.').last);
    }
  }

  String _getIconAssetForActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.breastfeeding:
        return 'image/svg/mother.svg';
      case ActivityType.vaccination:
        return 'image/svg/vaccine.svg';
      default:
        return 'image/svg/vaccine.svg';
    }
  }

  Future<void> _handleActivitySelection(
      BuildContext context, Activity activity) async {
    try {
      if (activity.type == ActivityType.breastfeeding) {
        await _handleBreastfeeding(context);
      } else if (activity.type == ActivityType.vaccination) {
        await _handleVaccination(context, activity);
      } else {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTime != null) {
          final newActivity = activity.copyWith(
            startTime: DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            ),
            time: selectedTime,
          );
          await _activityManager.addActivity(newActivity, context);
          widget.onActivityAdded(newActivity);
          Future.microtask(() => Navigator.pop(context));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding activity: $e')),
      );
    }
  }

  Future<void> _handleBreastfeeding(BuildContext context) async {
    final result = await showDialog<Activity>(
      context: context,
      builder: (context) => BreastfeedingTimerDialog(),
    );

    if (result != null) {
      await _activityManager.addActivity(result, context);
      widget.onActivityAdded(result);
      Future.microtask(() => Navigator.pop(context));
    }
  }

  Future<void> _handleVaccination(
      BuildContext context, Activity activity) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('add_vaccination')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate('vaccination_name')),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate('vaccination_description')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (selectedTime != null) {
                Navigator.pop(context, {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'time': selectedTime,
                });
              }
            },
            child: Text(AppLocalizations.of(context).translate('add')),
          ),
        ],
      ),
    );

    if (result != null) {
      final newActivity = activity.copyWith(
        title: result['title'],
        description: result['description'],
        startTime: DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          result['time'].hour,
          result['time'].minute,
        ),
        time: result['time'],
      );
      await _activityManager.addActivity(newActivity, context);
      widget.onActivityAdded(newActivity);
      Future.microtask(() => Navigator.pop(context));
    }
  }
}
