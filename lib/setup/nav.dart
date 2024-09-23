import 'package:baby/sign_up_staff/log.dart';
import 'package:flutter/material.dart';
import 'package:baby/log_in/login.dart';

class ProfileTypeScreen extends StatelessWidget {
  void _navigateToNextScreen(BuildContext context, String profileType) {
    print('Type de profil sélectionné : $profileType');
    // Exemple de navigation basée sur profileType
    if (profileType == 'nouvelle_famille') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            onLocaleChange: (Locale locale) {},
          ),
        ),
      );
    } else if (profileType == 'personnel') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login_Page(
            onLocaleChange: (Locale locale) {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Type de Profil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.0),
            Expanded(
              child: _buildProfileTypeCard(
                context,
                'Continuer en tant que parent ',
                'Parent souhaitant suivre l\'allaitement et la vaccination de son bébé ',
                Color(0xFFFFF3E0),
                'nouvelle_famille',
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _buildProfileTypeCard(
                context,
                'Continuer en tant que professionnel de la santé',
                'Professionnel de santé accompagnant l\'allaitement et la vaccination',
                Color(0xFFE8E3FF),
                'personnel',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTypeCard(
    BuildContext context,
    String title,
    String subtitle,
    Color backgroundColor,
    String profileType,
  ) {
    return InkWell(
      onTap: () => _navigateToNextScreen(context, profileType),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Icon(Icons.chevron_right, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
