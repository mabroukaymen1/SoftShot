import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:baby/home/color.dart';
import 'package:baby/home/activ/activity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:baby/log_in/languge.dart';

class PainTrackingPage extends StatefulWidget {
  @override
  _PainTrackingPageState createState() => _PainTrackingPageState();
}

class _PainTrackingPageState extends State<PainTrackingPage> {
  final List<int> _scores = List.filled(6, 0);
  final List<String> _scoreLabels = [
    'expression faciale',
    'pleurs',
    'mode respiratoire',
    'bras',
    'jambes',
    'etat d eveil'
  ];
  List<PainScore> _painScores = [];
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPainScores());
  }

  void _loadPainScores() async {
    final activityManager =
        Provider.of<ActivityManager>(context, listen: false);
    final recentVaccination = activityManager.getMostRecentVaccination();

    if (recentVaccination != null && recentVaccination.id.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? painScoresString = prefs.getString('painScores');

        if (painScoresString != null) {
          final List<dynamic> painScoresList = jsonDecode(painScoresString);
          setState(() {
            _painScores = painScoresList.map((e) {
              return PainScore(
                DateTime.parse(e['time']),
                e['score'],
                note: e['note'],
              );
            }).toList();
          });
        } else {
          setState(() {
            _painScores = [];
          });
        }
      } catch (e) {
        print('Erreur lors du chargement des scores de douleur : $e');
      }
    } else {
      setState(() {
        _painScores = [];
      });
      if (recentVaccination == null) {
        print('Aucune vaccination récente trouvée.');
      } else if (recentVaccination.id.isEmpty) {
        print('L\'ID de la vaccination est vide.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
            AppLocalizations.of(context).translate('suivi de la douleur'),
            style: AppStyles.heading),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                  AppLocalizations.of(context).translate('echelle nips')),
              SizedBox(height: 16),
              _buildNIPSScale(),
              SizedBox(height: 24),
              _buildSectionTitle(AppLocalizations.of(context)
                  .translate('notes additionnelles')),
              SizedBox(height: 8),
              _buildNoteInput(),
              SizedBox(height: 24),
              _buildSaveButton(),
              SizedBox(height: 24),
              _buildSectionTitle(AppLocalizations.of(context)
                  .translate('historique des scores de douleur')),
              SizedBox(height: 16),
              _buildPainChart(),
              SizedBox(height: 24),
              _buildPainScoreList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) =>
      Text(title, style: AppStyles.subheading);

  Widget _buildNIPSScale() {
    return Column(
      children: List.generate(
        _scoreLabels.length,
        (index) => _buildScoreSlider(
          AppLocalizations.of(context).translate(_scoreLabels[index]),
          _scores[index],
          (value) => setState(() => _scores[index] = value),
        ),
      ),
    );
  }

  Widget _buildScoreSlider(
      String title, int score, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.body),
        Slider(
          value: score.toDouble(),
          min: 0,
          max: 2,
          divisions: 2,
          label: score.toString(),
          onChanged: (double value) => onChanged(value.round()),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.surface,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context).translate('notes additionnelles'),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        onPressed: _savePainScore,
        child: Text(AppLocalizations.of(context)
            .translate('enregistrer score douleur')),
      ),
    );
  }

  void _savePainScore() async {
    final activityManager =
        Provider.of<ActivityManager>(context, listen: false);
    final recentVaccination = activityManager.getMostRecentVaccination();

    if (recentVaccination != null && recentVaccination.id.isNotEmpty) {
      final totalScore = _scores.reduce((a, b) => a + b);
      final newPainScore =
          PainScore(DateTime.now(), totalScore, note: _noteController.text);

      final prefs = await SharedPreferences.getInstance();
      final String? painScoresString = prefs.getString('painScores');
      List<dynamic> painScoresList = [];

      if (painScoresString != null) {
        painScoresList = jsonDecode(painScoresString);
      }

      painScoresList.add({
        'time': newPainScore.time.toIso8601String(),
        'score': newPainScore.score,
        'note': newPainScore.note,
      });

      await prefs.setString('painScores', jsonEncode(painScoresList));

      setState(() {
        _painScores.add(newPainScore);
        _resetScores();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('score douleur enregistre'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('aucune vaccination recente'))),
      );
    }
  }

  void _resetScores() {
    setState(() {
      _scores.fillRange(0, _scores.length, 0);
      _noteController.clear();
    });
  }

  Widget _buildPainChart() {
    if (_painScores.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)
              .translate('aucun score de douleur')));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < _painScores.length) {
                        return Text(DateFormat('dd/MM')
                            .format(_painScores[index].time));
                      }
                      return Text('');
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: (_painScores.length - 1).toDouble(),
              minY: 0,
              maxY: 12,
              lineBarsData: [
                LineChartBarData(
                  spots: _painScores.asMap().entries.map((entry) {
                    return FlSpot(
                        entry.key.toDouble(), entry.value.score.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPainScoreList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _painScores.length,
      itemBuilder: (context, index) {
        final painScore = _painScores[_painScores.length - 1 - index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            title: Text(
                '${AppLocalizations.of(context).translate('score')}: ${painScore.score}'),
            subtitle:
                Text(DateFormat('dd/MM/yyyy HH:mm').format(painScore.time)),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _deletePainScore(painScore),
            ),
            onTap: () => _showPainScoreDetails(painScore),
          ),
        );
      },
    );
  }

  void _deletePainScore(PainScore painScore) async {
    final activityManager =
        Provider.of<ActivityManager>(context, listen: false);
    final recentVaccination = activityManager.getMostRecentVaccination();
    if (recentVaccination != null && recentVaccination.id.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String? painScoresString = prefs.getString('painScores');
      List<dynamic> painScoresList = [];

      if (painScoresString != null) {
        painScoresList = jsonDecode(painScoresString);
      }

      painScoresList.removeWhere((e) =>
          DateTime.parse(e['time']) == painScore.time &&
          e['score'] == painScore.score &&
          e['note'] == painScore.note);

      await prefs.setString('painScores', jsonEncode(painScoresList));

      setState(() {
        _painScores.remove(painScore);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('score douleur supprime'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('aucune vaccination recente pour suppression'))),
      );
    }
  }

  void _showPainScoreDetails(PainScore painScore) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)
            .translate('details du score de douleur')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${AppLocalizations.of(context).translate('score')}: ${painScore.score}'),
            Text(
                '${AppLocalizations.of(context).translate('temps')}: ${DateFormat('dd/MM/yyyy HH:mm').format(painScore.time)}'),
            if (painScore.note != null && painScore.note!.isNotEmpty)
              Text(
                  '${AppLocalizations.of(context).translate('note')}: ${painScore.note}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).translate('fermer')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

class PainScore {
  final DateTime time;
  final int score;
  final String? note;

  PainScore(this.time, this.score, {this.note});
}
