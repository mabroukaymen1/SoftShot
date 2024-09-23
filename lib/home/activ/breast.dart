import 'package:baby/home/activ/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:baby/home/activ/active.dart';
import 'package:baby/home/color.dart';
import 'package:baby/log_in/languge.dart';
import 'package:provider/provider.dart';

class BreastfeedingTimerDialog extends StatefulWidget {
  @override
  _BreastfeedingTimerDialogState createState() =>
      _BreastfeedingTimerDialogState();
}

class _BreastfeedingTimerDialogState extends State<BreastfeedingTimerDialog> {
  Duration _leftDuration = Duration.zero;
  Duration _rightDuration = Duration.zero;
  bool _isLeftRunning = false;
  bool _isRightRunning = false;
  Timer? _leftTimer;
  Timer? _rightTimer;

  @override
  void dispose() {
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    super.dispose();
  }

  void _toggleLeftTimer() {
    setState(() {
      _isLeftRunning = !_isLeftRunning;
      if (_isLeftRunning) {
        _leftTimer = _startTimer(_leftDuration, (newDuration) {
          setState(() {
            _leftDuration = newDuration;
          });
        }, () {
          setState(() {
            _isLeftRunning = false; // Stop the timer when it reaches zero
          });
        });
      } else {
        _leftTimer?.cancel();
      }
    });
  }

  void _toggleRightTimer() {
    setState(() {
      _isRightRunning = !_isRightRunning;
      if (_isRightRunning) {
        _rightTimer = _startTimer(_rightDuration, (newDuration) {
          setState(() {
            _rightDuration = newDuration;
          });
        }, () {
          setState(() {
            _isRightRunning = false; // Stop the timer when it reaches zero
          });
        });
      } else {
        _rightTimer?.cancel();
      }
    });
  }

  Timer _startTimer(
      Duration duration, Function(Duration) onTick, VoidCallback onComplete) {
    return Timer.periodic(Duration(seconds: 1), (timer) {
      final newDuration = duration - Duration(seconds: 1);
      if (newDuration <= Duration.zero) {
        timer.cancel();
        onComplete();
      } else {
        onTick(newDuration);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> _showSetTimerDialog() async {
    bool? isFirstBreastfeeding = await showDialog<bool>(
      context: context,
      builder: (context) => FirstBreastfeedingDialog(),
    );

    if (isFirstBreastfeeding != null) {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 0, minute: 30),
      );
      if (picked != null) {
        setState(() {
          _leftDuration =
              Duration(hours: picked.hour, minutes: picked.minute) ~/ 2;
          _rightDuration =
              Duration(hours: picked.hour, minutes: picked.minute) ~/ 2;
        });

        if (isFirstBreastfeeding) {
          // Schedule breastfeeding activities
          final activityManager =
              Provider.of<ActivityManager>(context, listen: false);
          await activityManager.scheduleBreastfeedingActivities(
            DateTime.now().copyWith(hour: picked.hour, minute: picked.minute),
            context,
          );
        }
      }
    }
  }

  Future<void> _showManualInputDialog() async {
    final TextEditingController durationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context).translate('saisie manuelle')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: durationController,
                label: 'durée allaitement minutes',
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).translate('annuler')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('ok')),
              onPressed: () {
                int totalDuration = int.tryParse(durationController.text) ?? 0;
                setState(() {
                  _leftDuration = Duration(minutes: totalDuration ~/ 2);
                  _rightDuration = Duration(minutes: totalDuration ~/ 2);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).translate(label),
      ),
      keyboardType: TextInputType.number,
    );
  }

  void _saveActivity() {
    final newActivity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.breastfeeding,
      title: AppLocalizations.of(context).translate('allaitement'),
      description: AppLocalizations.of(context).translate('séance allaitement'),
      iconAsset: 'image/svg/mother.svg',
      startTime: DateTime.now(),
      painScores: [],
      duration: _leftDuration + _rightDuration,
      time: TimeOfDay.now(),
      leftDuration: _leftDuration,
      rightDuration: _rightDuration,
    );
    Navigator.pop(context, newActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              SizedBox(height: 20),
              _buildTimerDisplay(),
              SizedBox(height: 20),
              _buildTimerControls(),
              SizedBox(height: 20),
              _buildSetTimerButton(),
              SizedBox(height: 10),
              _buildManualInputButton(),
              SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context).translate('chronomètre allaitement'),
            style: AppStyles.heading,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.yellow[100],
          child: SvgPicture.asset(
            'image/svg/mother.svg',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 20),
        Text(
          _formatDuration(_leftDuration + _rightDuration),
          style: AppStyles.heading.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerControls() {
    return Row(
      children: [
        Expanded(
          child: _buildTimerButton(
            'gauche',
            _leftDuration,
            _isLeftRunning,
            _toggleLeftTimer,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildTimerButton(
            'droite',
            _rightDuration,
            _isRightRunning,
            _toggleRightTimer,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerButton(
      String label, Duration duration, bool isRunning, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDuration(duration),
                style: AppStyles.subheading.copyWith(fontSize: 16),
              ),
              Icon(
                isRunning ? Icons.pause : Icons.play_arrow,
                size: 24,
              ),
            ],
          ),
          onPressed: onPressed,
          style: AppStyles.primaryButton.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            foregroundColor: MaterialStateProperty.all(Colors.orange[300]),
            elevation: MaterialStateProperty.all(0),
            side: MaterialStateProperty.all(
              BorderSide(color: Colors.orange[300]!),
            ),
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 8)),
          ),
        ),
        SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).translate(label),
          style:
              AppStyles.body.copyWith(fontSize: 14, color: Colors.orange[300]),
        ),
      ],
    );
  }

  Widget _buildSetTimerButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.timer, size: 18),
      label: Text(
        AppLocalizations.of(context).translate('définir chronomètre'),
        style: TextStyle(fontSize: 14),
      ),
      onPressed: _showSetTimerDialog,
      style: AppStyles.primaryButton.copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
        foregroundColor: MaterialStateProperty.all(Colors.blue),
      ),
    );
  }

  Widget _buildManualInputButton() {
    return TextButton.icon(
      icon: Icon(Icons.edit, size: 18),
      label: Text(
        AppLocalizations.of(context).translate('saisir manuellement'),
        style: TextStyle(fontSize: 14),
      ),
      onPressed: _showManualInputDialog,
      style: AppStyles.secondaryButton,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      child: Text(
        AppLocalizations.of(context).translate('enregistrer'),
        style: TextStyle(fontSize: 16),
      ),
      onPressed: _saveActivity,
      style: AppStyles.primaryButton,
    );
  }
}

class FirstBreastfeedingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate('allaitement')),
      content:
          Text(AppLocalizations.of(context).translate('première allaitement')),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context).translate('non')),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(AppLocalizations.of(context).translate('oui')),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
