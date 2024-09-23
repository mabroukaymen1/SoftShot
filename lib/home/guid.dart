import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:baby/home/drawer.dart';
import 'package:baby/log_in/languge.dart'; // Import the language file

class BreastfeedingGuidePage extends StatefulWidget {
  const BreastfeedingGuidePage({Key? key}) : super(key: key);

  @override
  _BreastfeedingGuidePageState createState() => _BreastfeedingGuidePageState();
}

class _BreastfeedingGuidePageState extends State<BreastfeedingGuidePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  late FlutterTts _flutterTts;
  final ValueNotifier<int> _currentStep = ValueNotifier<int>(0);
  bool _isSpeaking = false;
  bool _isLoading = true;
  late List<BreastfeedingStep> _steps;

  @override
  void initState() {
    super.initState();
    _initializeResources();
  }

  Future<void> _initializeResources() async {
    try {
      await Future.wait([
        _initializeVideo(),
        _initializeTts(),
      ]);
      _initializeSteps();
    } catch (e) {
      print("Error initializing resources: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeSteps() {
    _steps = [
      BreastfeedingStep(
        title: AppLocalizations.of(context).translate('step1_title'),
        description:
            AppLocalizations.of(context).translate('step1_description'),
        imageAsset: 'image/step1.png',
      ),
      BreastfeedingStep(
        title: AppLocalizations.of(context).translate('step2_title'),
        description:
            AppLocalizations.of(context).translate('step2_description'),
        imageAsset: 'image/step2.png',
      ),
      BreastfeedingStep(
        title: AppLocalizations.of(context).translate('step3_title'),
        description:
            AppLocalizations.of(context).translate('step3_description'),
        imageAsset: 'image/step3.png',
      ),
      BreastfeedingStep(
        title: AppLocalizations.of(context).translate('step4_title'),
        description:
            AppLocalizations.of(context).translate('step4_description'),
        imageAsset: 'image/step4.png',
      ),
      BreastfeedingStep(
        title: AppLocalizations.of(context).translate('step5_title'),
        description:
            AppLocalizations.of(context).translate('step5_description'),
        imageAsset: 'image/step5.png',
      ),
    ];
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('video/allli.mp4');
    try {
      await _videoController.initialize();
      final videoSize = _videoController.value.size;
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        aspectRatio: videoSize.width / videoSize.height,
        autoPlay: false,
        looping: false,
        allowedScreenSleep: false,
        placeholder: Container(color: Colors.black),
      );
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setErrorHandler((msg) => print("TTS Error: $msg"));
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) await _flutterTts.stop();
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(text).catchError((error) {
      print("TTS Speak Error: $error");
      setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    _flutterTts.stop();
    _currentStep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: SharedDrawer(),
      body: _isLoading ? _buildLoadingIndicator() : _buildPageContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildPageContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVaccinationGuide(),
          const SizedBox(height: 16),
          _buildVideoSection(),
          const SizedBox(height: 16),
          _buildStepByStepInstructions(),
          const SizedBox(height: 16),
          _buildMilkProductionTips(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.grid_view),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).translate('guide')),
          Text(
            AppLocalizations.of(context)
                .translate('breastfeeding_and_vaccination'),
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return _buildCard(
      color: Colors.blue[50]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('explanatory_videos'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).translate('watch_videos_description'),
          ),
          const SizedBox(height: 8),
          if (_chewieController != null)
            AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
          else
            Text(AppLocalizations.of(context).translate('video_load_error')),
        ],
      ),
    );
  }

  Widget _buildStepByStepInstructions() {
    return _buildCard(
      color: Colors.pink[50]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('step_by_step_instructions'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)
                .translate('follow_detailed_instructions'),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _currentStep,
            builder: (context, step, child) {
              if (_steps.isEmpty) {
                return Text(AppLocalizations.of(context)
                    .translate('no_steps_available'));
              }
              final currentStep = _steps[step];
              return _buildStepContent(currentStep);
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep.value > 0)
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep.value > 0) {
                      _currentStep.value--;
                    }
                  },
                  child:
                      Text(AppLocalizations.of(context).translate('previous')),
                ),
              if (_currentStep.value < _steps.length - 1)
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep.value < _steps.length - 1) {
                      _currentStep.value++;
                    }
                  },
                  child: Text(AppLocalizations.of(context).translate('next')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BreastfeedingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(step.description),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              step.imageAsset,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () => _speak(step.description),
              icon: const Icon(Icons.volume_up),
              color: Colors.blue,
            ),
            ElevatedButton(
              onPressed: () {
                if (_isSpeaking) {
                  _flutterTts.stop();
                  setState(() => _isSpeaking = false);
                }
              },
              child: const Text('Stop'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVaccinationGuide() {
    return _buildCard(
      color: Colors.orange[50]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)
                .translate('interactive_breastfeeding_guide'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildVaccinationGuideItem(
            icon: Icons.video_library,
            text: AppLocalizations.of(context)
                .translate('explanatory_videos_item'),
          ),
          _buildVaccinationGuideItem(
            icon: Icons.list_alt,
            text: AppLocalizations.of(context)
                .translate('step_by_step_instructions_item'),
          ),
          _buildVaccinationGuideItem(
            icon: Icons.volume_up,
            text: AppLocalizations.of(context).translate('audio_guide_item'),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkProductionTips() {
    return _buildCard(
      color: Colors.green[50]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('milkProductionTips'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildMilkProductionTip(
            title: AppLocalizations.of(context).translate('frequentFeeding'),
            description: AppLocalizations.of(context)
                .translate('frequentFeedingDescription'),
          ),
          _buildMilkProductionTip(
            title: AppLocalizations.of(context).translate('stayHydrated'),
            description: AppLocalizations.of(context)
                .translate('stayHydratedDescription'),
          ),
          _buildMilkProductionTip(
            title: AppLocalizations.of(context).translate('balancedDiet'),
            description: AppLocalizations.of(context)
                .translate('balancedDietDescription'),
          ),
          _buildMilkProductionTip(
            title: AppLocalizations.of(context)
                .translate('restAndStressManagement'),
            description: AppLocalizations.of(context)
                .translate('restAndStressManagementDescription'),
          ),
          _buildMilkProductionTip(
            title: AppLocalizations.of(context).translate('useBreastPump'),
            description: AppLocalizations.of(context)
                .translate('useBreastPumpDescription'),
          ),
          _buildMilkProductionTip(
            title: AppLocalizations.of(context).translate('checkLatch'),
            description:
                AppLocalizations.of(context).translate('checkLatchDescription'),
          ),
          _buildMilkProductionTip(
            title: AppLocalizations.of(context).translate('avoidSupplements'),
            description: AppLocalizations.of(context)
                .translate('avoidSupplementsDescription'),
          ),
          _buildMilkProductionTip(
            title:
                AppLocalizations.of(context).translate('naturalGalactagogues'),
            description: AppLocalizations.of(context)
                .translate('naturalGalactagoguesDescription'),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkProductionTip(
      {required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationGuideItem(
      {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, required Color color}) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

class BreastfeedingStep {
  final String title;
  final String description;
  final String imageAsset;

  BreastfeedingStep({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}
