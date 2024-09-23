import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:baby/babyinfo/baby_provider.dart';
import 'package:baby/home/activ/active.dart';
import 'package:baby/home/activ/activity.dart';
import 'package:baby/home/color.dart';
import 'package:baby/log_in/languge.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BabyInfoForm extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  BabyInfoForm({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  _BabyInfoFormState createState() => _BabyInfoFormState();
}

class _BabyInfoFormState extends State<BabyInfoForm> {
  int _currentStep = 0;
  String _relationship = 'father';
  String _babyName = '';
  String _gender = '';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  DateTime _birthDate = DateTime.now();
  Color _selectedColor = AppColors.primary;
  bool _isEarlyLateBirth = false;

  final List<Color> _colorOptions = [
    AppColors.primary,
    AppColors.accent,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    try {
      final languageDoc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('language')
          .get();
      if (languageDoc.exists) {
        final languageCode = languageDoc.data()?['code'] as String?;
        if (languageCode != null) {
          widget.onLocaleChange(Locale(languageCode));
          setState(() {});
        }
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de l\'initialisation de la langue : $e');
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    try {
      if (_babyName.isEmpty || _gender.isEmpty) {
        throw Exception(
            AppLocalizations.of(context).translate('remplir tous les champs'));
      }

      _addTunisianVaccinationSchedule(_birthDate);

      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final String babyId = await babyProvider.addNewBaby(
        name: _babyName,
        gender: _gender,
        birthDate: _birthDate,
        relationship: _relationship,
        profileImage: _profileImage,
        selectedColor: _selectedColor,
        isEarlyLateBirth: _isEarlyLateBirth,
      );

      babyProvider.setCurrentBabyId(babyId);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          AppLocalizations.of(context).translate('infos bebe'),
          style: AppStyles.heading,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(child: _buildCurrentStep()),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: _currentStep == index
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return Container();
    }
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(
              AppLocalizations.of(context)
                  .translate('parlez nous de votre bebe'),
              style: AppStyles.heading),
          SizedBox(height: 20),
          _buildLabelAndDropdown(
              AppLocalizations.of(context).translate('relation avec bebe')),
          SizedBox(height: 20),
          _buildLabelAndTextField(
              AppLocalizations.of(context).translate('nom bebe')),
          SizedBox(height: 20),
          _buildLabelAndGenderButtons(
              AppLocalizations.of(context).translate('genre')),
        ],
      ),
    );
  }

  Widget _buildLabelAndDropdown(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: AppStyles.caption),
        SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondaryText),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _relationship,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
              onChanged: (String? newValue) {
                setState(() {
                  _relationship = newValue!;
                });
              },
              items: <String>['father', 'mother', 'guardian']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(AppLocalizations.of(context).translate(value),
                      style: AppStyles.body),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelAndTextField(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: AppStyles.caption),
        SizedBox(height: 10),
        TextField(
          onChanged: (value) {
            setState(() {
              _babyName = value;
            });
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).translate('nom'),
            hintStyle: TextStyle(color: AppColors.secondaryText),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondaryText),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelAndGenderButtons(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: AppStyles.caption),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _gender = 'Garçon'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gender == 'Garçon'
                      ? AppColors.primary
                      : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.male),
                label: Text(AppLocalizations.of(context).translate('garcon'),
                    style: TextStyle(
                        color: _gender == 'Garçon'
                            ? AppColors.background
                            : AppColors.text)),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _gender = 'Fille'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gender == 'Fille'
                      ? AppColors.primary
                      : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.female),
                label: Text(AppLocalizations.of(context).translate('fille'),
                    style: TextStyle(
                        color: _gender == 'Fille'
                            ? AppColors.background
                            : AppColors.text)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(AppLocalizations.of(context).translate('photo de profil'),
              style: AppStyles.heading),
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.surface,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : AssetImage('image/baby.png') as ImageProvider,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, color: AppColors.primary, size: 30)
                    : null,
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildDatePicker(
              AppLocalizations.of(context).translate('date de naissance')),
          SizedBox(height: 20),
          _buildColorPicker(
              AppLocalizations.of(context).translate('choisissez une couleur')),
          SizedBox(height: 20),
          _buildSwitch(
              AppLocalizations.of(context).translate('naissance prematuree')),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildDatePicker(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: AppStyles.caption),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: _birthDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null && selectedDate != _birthDate) {
              setState(() {
                _birthDate = selectedDate;
              });
            }
          },
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: DateFormat('yyyy-MM-dd').format(_birthDate),
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondaryText),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: AppStyles.caption),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colorOptions.map((color) {
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == color
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitch(String labelText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(labelText, style: AppStyles.caption),
        Switch(
          value: _isEarlyLateBirth,
          onChanged: (value) {
            setState(() {
              _isEarlyLateBirth = value;
            });
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(AppLocalizations.of(context).translate('votre confirmation'),
              style: AppStyles.heading),
          SizedBox(height: 20),
          Text(
              AppLocalizations.of(context)
                  .translate('verifiez les informations'),
              style: AppStyles.body),
          SizedBox(height: 20),
          Text(
              '${AppLocalizations.of(context).translate('nom')}: $_babyName\n'
              '${AppLocalizations.of(context).translate('genre')}: $_gender\n'
              '${AppLocalizations.of(context).translate('date de naissance')}: ${DateFormat('yyyy-MM-dd').format(_birthDate)}\n'
              '${AppLocalizations.of(context).translate('relation avec bebe')}: $_relationship\n'
              '${AppLocalizations.of(context).translate('naissance prematuree')}: ${_isEarlyLateBirth ? AppLocalizations.of(context).translate('oui') : AppLocalizations.of(context).translate('non')}\n',
              style: AppStyles.body),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _currentStep < 2
              ? AppLocalizations.of(context).translate('suivant')
              : AppLocalizations.of(context).translate('soumettre'),
          style: TextStyle(color: AppColors.background),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('erreur')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).translate('ok')),
            ),
          ],
        );
      },
    );
  }

  void _addTunisianVaccinationSchedule(DateTime birthDate) {
    final List<Map<String, dynamic>> tunisianVaccinationSchedule = [
      {
        'type': ActivityType.vaccination,
        'title': 'BCG',
        'description':
            'Vaccin de la tuberculose: 1 seule dose le plus tôt possible après la naissance',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.green,
        'iconColor': Colors.white,
        'daysAfterBirth': 0,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'VHB-0',
        'description':
            'Vaccin de l\'hépatite B: à administrer durant les 24 heures qui suivent la naissance',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.blue,
        'iconColor': Colors.white,
        'daysAfterBirth': 0,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'Pentavalent-1 + VPI + VPC-1',
        'description': '1ère injection du vaccin Pentavalent, VPI et VPC',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.amber,
        'iconColor': Colors.white,
        'daysAfterBirth': 60,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'Pentavalent-2 + VPI',
        'description': '2ème prise du vaccin pentavalent et VPI',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.orange,
        'iconColor': Colors.white,
        'daysAfterBirth': 90,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'VPC-2',
        'description': '2ème prise du vaccin pneumococcique',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.pink,
        'iconColor': Colors.white,
        'daysAfterBirth': 120,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'Pentavalent-3 + VPO',
        'description': '3ème prise du vaccin pentavalent et VPO',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.purple,
        'iconColor': Colors.white,
        'daysAfterBirth': 180,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'VPC-3',
        'description': '3ème prise du vaccin pneumococcique',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.indigo,
        'iconColor': Colors.white,
        'daysAfterBirth': 330,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'RR-1 + VHA',
        'description':
            '1ère prise du vaccin de la rougeole - rubéole et une prise du vaccin de l\'hépatite virale A',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.cyan,
        'iconColor': Colors.white,
        'daysAfterBirth': 365,
        'duration': 5,
      },
      {
        'type': ActivityType.vaccination,
        'title': 'DTC-4 + VPO + RR-2',
        'description': 'Rappel par les vaccins DTC, VPO, et rougeole - rubéole',
        'iconAsset': 'image/svg/vaccine.svg',
        'iconBgColor': Colors.teal,
        'iconColor': Colors.white,
        'daysAfterBirth': 540,
        'duration': 5,
      },
    ];
    final activityManager =
        Provider.of<ActivityManager>(context, listen: false);

    for (var activityData in tunisianVaccinationSchedule) {
      try {
        final vaccinationDate =
            birthDate.add(Duration(days: activityData['daysAfterBirth']));

        final activity = Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: ActivityType.vaccination,
          title: AppLocalizations.of(context).translate(activityData['title']),
          description: AppLocalizations.of(context)
              .translate(activityData['description']),
          iconAsset: activityData['iconAsset'],
          startTime: vaccinationDate,
          painScores: [],
          duration: Duration(minutes: activityData['duration']),
          time: TimeOfDay(hour: 9, minute: 0),
        );

        activityManager.addActivity(activity, context);

        _scheduleNotification(
          id: activity.id,
          title: activity.title,
          body: activity.description,
          scheduledDate: vaccinationDate,
        );
      } catch (e) {
        print(
            'Error adding vaccination activity: ${activityData['title']} - $e');
      }
    }
  }

  Future<void> _scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      print('Scheduling notification for $id at $scheduledDate');
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: int.parse(id),
          channelKey: 'activity_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          icon: 'resource://drawable/noti',
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: scheduledDate.second,
          millisecond: scheduledDate.millisecond,
        ),
      );
    } catch (e) {
      print('Failed to schedule notification: $e');
    }
  }
}
