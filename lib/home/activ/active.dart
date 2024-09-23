import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ActivityType { vaccination, breastfeeding }

class PainScore {
  final DateTime time;
  final int score;
  final String? note;

  PainScore(this.time, this.score, {this.note});

  Map<String, dynamic> toMap() => {
        'time': time.toIso8601String(),
        'score': score,
        'note': note,
      };

  factory PainScore.fromMap(Map<String, dynamic> map) => PainScore(
        DateTime.parse(map['time']),
        map['score'],
        note: map['note'],
      );
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String iconAsset;
  final bool completed;
  final DateTime startTime;
  final List<PainScore> painScores;
  final Duration duration;
  final TimeOfDay time;
  final Duration? leftDuration;
  final Duration? rightDuration;
  final bool isActive;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    this.completed = false,
    required this.description,
    required this.iconAsset,
    required this.startTime,
    required this.painScores,
    required this.duration,
    required this.time,
    this.leftDuration,
    this.rightDuration,
    this.isActive = false,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(startTime.add(duration));
  }

  Widget getIcon({double? size}) {
    return SvgPicture.asset(
      iconAsset,
      width: size,
      height: size,
    );
  }

  Activity copyWith({
    String? id,
    ActivityType? type,
    String? title,
    String? description,
    String? iconAsset,
    DateTime? startTime,
    List<PainScore>? painScores,
    Duration? duration,
    TimeOfDay? time,
    bool? completed,
    Duration? leftDuration,
    Duration? rightDuration,
    bool? isActive,
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      iconAsset: iconAsset ?? this.iconAsset,
      startTime: startTime ?? this.startTime,
      painScores: painScores ?? this.painScores,
      duration: duration ?? this.duration,
      time: time ?? this.time,
      completed: completed ?? this.completed,
      leftDuration: leftDuration ?? this.leftDuration,
      rightDuration: rightDuration ?? this.rightDuration,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'iconAsset': iconAsset,
      'completed': completed,
      'startTime': startTime.toIso8601String(),
      'painScores': painScores.map((e) => e.toMap()).toList(),
      'duration': duration.inMinutes,
      'time': '${time.hour}:${time.minute}',
      'leftDuration': leftDuration?.inSeconds,
      'rightDuration': rightDuration?.inSeconds,
      'isActive': isActive,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    ActivityType activityType;
    try {
      activityType = ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${map['type']}',
      );
    } catch (e) {
      print('Invalid activity type: ${map['type']}');
      activityType = ActivityType.vaccination;
    }

    return Activity(
      id: map['id'] ?? '',
      type: activityType,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconAsset: map['iconAsset'] ?? '',
      completed: map['completed'] ?? false,
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      painScores: (map['painScores'] as List<dynamic>?)
              ?.map((e) => PainScore.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      duration: Duration(minutes: map['duration'] ?? 0),
      time: _parseTimeOfDay(map['time']),
      leftDuration: map['leftDuration'] != null
          ? Duration(seconds: map['leftDuration'])
          : null,
      rightDuration: map['rightDuration'] != null
          ? Duration(seconds: map['rightDuration'])
          : null,
      isActive: map['isActive'] ?? false,
    );
  }

  static TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null) return TimeOfDay.now();
    final parts = timeString.split(':');
    if (parts.length != 2) return TimeOfDay.now();
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  void addPainScore(PainScore newPainScore) {
    painScores.add(newPainScore);
  }
}
