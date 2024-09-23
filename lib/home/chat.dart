import 'package:baby/log_in/languge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:baby/home/color.dart';

class ChatScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  ChatScreen({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _messageController;
  final List<ChatMessage> _chatMessages = [];
  bool _isTyping = false;
  String _userName = 'Utilisateur'; // Default username for local testing

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _loadLanguage(); // Ajoutez cette ligne
  }

  void _loadLanguage() {
    // Simulate language loading
    setState(() {});
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) => _chatMessages[index],
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.text),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(AppLocalizations.of(context).translate('chat'),
          style: AppStyles.heading),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage('image/baby.png'),
          radius: 18,
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText:
                    AppLocalizations.of(context).translate('send_message_hint'),
                hintStyle:
                    AppStyles.body.copyWith(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              style: AppStyles.body,
              onChanged: (text) => _updateTypingStatus(text),
            ),
          ),
          SizedBox(width: 8),
          _buildSendButton(),
        ],
      ),
    );
  }

  void _updateTypingStatus(String text) {
    setState(() {
      _isTyping = text.trim().isNotEmpty;
    });
  }

  Widget _buildSendButton() {
    return Material(
      color: _isTyping ? AppColors.primary : AppColors.secondaryText,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: _isTyping ? _sendMessage : null,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.insert(
          0,
          ChatMessage(
            text: message,
            isUserMessage: true,
            time: DateTime.now(),
            userName: _userName,
          ));
    });

    _messageController.clear();
    _updateTypingStatus('');
    _addBotResponse(message);
  }

  void _addBotResponse(String message) {
    String normalizedMessage = message.toLowerCase().trim();
    String botResponse = BotResponses.getBotResponse(normalizedMessage);

    setState(() {
      _chatMessages.insert(
          0,
          ChatMessage(
            text: botResponse,
            isUserMessage: false,
            time: DateTime.now(),
            userName: 'Bot',
          ));
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  final DateTime time;
  final String userName;

  const ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.time,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) _buildAvatar(context),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUserMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isUserMessage ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    text,
                    style: AppStyles.body.copyWith(
                      color: isUserMessage ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat.Hm().format(time),
                  style: AppStyles.caption,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (isUserMessage) _buildAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      backgroundColor: isUserMessage ? AppColors.primary : AppColors.accent,
      child: Text(
        isUserMessage
            ? AppLocalizations.of(context)
                .translate('userPrefix')[0]
                .toUpperCase()
            : AppLocalizations.of(context)
                .translate('botName')[0]
                .toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class BotResponses {
  static final Map<String, String> _responses = {
    'meilleure position pour allaiter':
        'La meilleure position pour allaiter est celle où vous et votre bébé êtes confortables. Les positions courantes incluent :\n'
            '• Position en berceau\n'
            '• Position en croisé\n'
            '• Position football\n'
            '• Position allongée sur le côté\n'
            'Assurez-vous d\'avoir une bonne prise et que la tête et le corps du bébé sont alignés.',
    'signes que le bébé reçoit suffisamment de lait':
        'Les signes que votre bébé reçoit suffisamment de lait incluent :\n'
            '• Couches mouillées et sales régulières\n'
            '• Prise de poids régulière\n'
            '• Bébé satisfait après les tétées\n'
            '• Bonne prise et sons de déglutition\n'
            'Surveillez les signes de faim et consultez un professionnel de santé en cas de doute.',
    'allaitement après vaccination':
        'Oui, vous pouvez allaiter après une vaccination. Les avantages incluent :\n'
            '• Réconforter votre bébé\n'
            '• Réduire les effets secondaires légers\n'
            '• Fournir des anticorps renforçant le système immunitaire',
    'conseils pour allaiter': 'Conseils pour réussir l’allaitement :\n'
        '1. Assurez une bonne prise\n'
        '2. Allaiter à la demande\n'
        '3. Restez hydratée\n'
        '4. Mangez équilibré\n'
        '5. Cherchez du soutien si nécessaire\n'
        '6. Soyez patiente avec vous-même et votre bébé',
    'douleur lors de l’allaitement':
        'Bien que l’inconfort initial soit normal, la douleur persistante ne l’est pas. Causes possibles :\n'
            '• Mauvaise prise\n'
            '• Engorgement\n'
            '• Mastite\n'
            'Consultez un consultant en lactation ou un professionnel de santé si la douleur persiste.',
    'augmenter la production de lait': 'Pour augmenter la production de lait :\n'
        '• Allaiter plus fréquemment\n'
        '• Assurez une bonne prise\n'
        '• Utilisez les deux seins par tétée\n'
        '• Tire-lait après les tétées\n'
        '• Restez hydratée et bien nourrie\n'
        '• Gérez le stress\n'
        'Consultez un spécialiste de l’allaitement pour des conseils personnalisés.',
    'médicaments pendant l’allaitement':
        'De nombreux médicaments sont sûrs pendant l’allaitement, mais consultez toujours votre professionnel de santé avant de commencer tout nouveau médicament. Certains peuvent passer dans le lait maternel et affecter votre bébé.',
    'allaiter en public': 'Conseils pour allaiter en public :\n'
        '• Portez des vêtements accessibles\n'
        '• Utilisez une couverture d’allaitement si vous le souhaitez\n'
        '• Trouvez un endroit confortable\n'
        '• Pratiquez à la maison\n'
        '• Connaissez vos droits\n'
        'Rappelez-vous, l’allaitement est naturel et protégé dans de nombreux endroits.',
    'durée de l’allaitement': 'L’OMS recommande :\n'
        '• Allaitement exclusif pendant 6 mois\n'
        '• Allaitement continu avec des aliments complémentaires jusqu’à 2 ans ou plus\n'
        'La durée est une décision personnelle basée sur des circonstances individuelles.',
    'régime pendant l’allaitement':
        'Un régime équilibré pendant l’allaitement inclut :\n'
            '• Une variété de fruits et légumes\n'
            '• Céréales complètes\n'
            '• Protéines maigres\n'
            '• Graisses saines\n'
            'Restez hydratée et limitez la caféine et l’alcool. Surveillez votre bébé pour les sensibilités alimentaires.',
    'allaitement en cas de maladie':
        'Vous pouvez allaiter avec un rhume ou une grippe. Précautions :\n'
            '• Lavez-vous les mains fréquemment\n'
            '• Évitez de tousser/éternuer près de votre bébé\n'
            '• Envisagez de porter un masque\n'
            'Le lait maternel fournit des anticorps protecteurs à votre bébé.',
  };

  static String getBotResponse(String message) {
    final normalizedMessage = _normalizeText(message);
    final keys = _responses.keys.toList();

    final fuse = Fuzzy<String>(
      keys,
      options: FuzzyOptions(
        findAllMatches: true,
        tokenize: true,
        threshold: 0.3,
      ),
    );

    final result = fuse.search(normalizedMessage);

    if (result.isNotEmpty) {
      return _responses[result.first.item]!;
    }

    return 'Je suis désolé, je n\'ai pas d\'information spécifique à ce sujet. '
        'Comment puis-je vous aider autrement avec l’allaitement ?';
  }

  static List<String> getSupportedTopics() {
    return _responses.keys.toList();
  }

  static String _normalizeText(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
  }
}
