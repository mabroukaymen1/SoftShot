import 'package:baby/home/activ/active.dart';
import 'package:baby/home/activ/activity.dart';
import 'package:baby/home/activ/activity_chart.dart';
import 'package:baby/home/activ/activity_picker.dart';
import 'package:baby/home/bottombar.dart';
import 'package:baby/home/color.dart';
import 'package:baby/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:baby/log_in/languge.dart';

class DailyActivityPage extends StatefulWidget {
  const DailyActivityPage({Key? key}) : super(key: key);

  @override
  _DailyActivityPageState createState() => _DailyActivityPageState();
}

class _DailyActivityPageState extends State<DailyActivityPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: SharedDrawer(),
      body: Consumer<ActivityManager>(
        builder: (context, activityManager, child) {
          final activities =
              activityManager.getActivitiesForDate(_selectedDate);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildDatePicker(activityManager)),
              _buildActivityList(activities, activityManager),
              SliverToBoxAdapter(child: _buildActivitySummary(activityManager)),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SharedBottomAppBar(
        selectedIndex: 0,
        onItemSelected: _handleBottomNavigation,
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
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      title: Text(AppLocalizations.of(context).translate('daily_activities'),
          style: AppStyles.heading),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.text),
          onPressed: _showYearlyCalendar,
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, color: AppColors.text),
          onPressed: _showActivityChart,
        ),
      ],
    );
  }

  Widget _buildDatePicker(ActivityManager activityManager) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 15));
          return _buildDateCard(date, activityManager);
        },
      ),
    );
  }

  Widget _buildDateCard(DateTime date, ActivityManager activityManager) {
    final isSelected = date.day == _selectedDate.day &&
        date.month == _selectedDate.month &&
        date.year == _selectedDate.year;
    final hasActivities =
        activityManager.daysWithActivities.contains(_normalizeDate(date));

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat('E').format(date),
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white70 : AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (hasActivities)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(
      List<Activity> activities, ActivityManager activityManager) {
    if (activities.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    final vaccinationActivities = activities
        .where((activity) => activity.type == ActivityType.vaccination)
        .toList();
    final otherActivities = activities
        .where((activity) => activity.type != ActivityType.vaccination)
        .toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0 && vaccinationActivities.isNotEmpty) {
            return _buildVaccinationSection(
                vaccinationActivities, activityManager);
          } else {
            final otherIndex = index - (vaccinationActivities.isEmpty ? 0 : 1);
            if (otherIndex < otherActivities.length) {
              return _buildActivityItem(
                  otherActivities[otherIndex], activityManager);
            }
          }
          return null;
        },
        childCount:
            (vaccinationActivities.isEmpty ? 0 : 1) + otherActivities.length,
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildVaccinationSection(
      List<Activity> vaccinationActivities, ActivityManager activityManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(AppLocalizations.of(context).translate('vaccinations'),
              style: AppStyles.subheading),
        ),
        ...vaccinationActivities
            .map((activity) => _buildActivityItem(activity, activityManager))
            .toList(),
      ],
    );
  }

  Widget _buildActivityItem(
      Activity activity, ActivityManager activityManager) {
    return Dismissible(
      key: Key(activity.id),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        activityManager.deleteActivity(activity);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .translate('activity_deleted', {'title': activity.title}))),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            child: activity.getIcon(size: 24),
          ),
          title: Text(activity.title, style: AppStyles.subheading),
          subtitle: Text(activity.description),
          trailing: Switch(
            value: activity.completed,
            onChanged: (value) {
              activityManager.toggleActivityCompletion(activity);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySummary(ActivityManager activityManager) {
    final activities = activityManager.getActivitiesForDate(_selectedDate);
    final totalDuration = activities.fold<Duration>(
      Duration.zero,
      (prev, curr) => prev + curr.duration,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).translate(
                  'total_activities', {'count': activities.length.toString()}),
              style: AppStyles.body,
            ),
            Text(
              AppLocalizations.of(context).translate('total_duration', {
                'hours': totalDuration.inHours.toString(),
                'minutes': (totalDuration.inMinutes % 60).toString()
              }),
              style: AppStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy,
              size: 80, color: AppColors.secondaryText),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('no_activities'),
            style:
                const TextStyle(fontSize: 18, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showActivityPicker,
            child: Text(AppLocalizations.of(context).translate('add_activity')),
            style: AppStyles.primaryButton,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showActivityPicker,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(AppLocalizations.of(context).translate('add_activity'),
          style: const TextStyle(color: Colors.white)),
      elevation: 4,
    );
  }

  void _showActivityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ActivityPicker(
          selectedDate: _selectedDate,
          onActivityAdded: (activity) {
            final activityManager =
                Provider.of<ActivityManager>(context, listen: false);
            activityManager.addActivity(activity, context);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  DateTime _normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  void _showYearlyCalendar() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year, 1, 1),
      lastDate: DateTime(_selectedDate.year, 12, 31),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  void _showActivityChart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ActivityChartDialog(selectedDate: _selectedDate);
      },
    );
  }
}
