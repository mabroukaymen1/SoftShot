import 'package:baby/sign_up_staff/rappel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baby/home/librarys/artical.dart';
import 'package:baby/home/chart.dart';
import 'package:baby/log_in/languge.dart'; // Import the language file

class Shared_Drawer extends StatefulWidget {
  @override
  _SharedDrawerState createState() => _SharedDrawerState();
}

class _SharedDrawerState extends State<Shared_Drawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'User';
  String _userEmail = 'Backup to save every memory';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userName = userData['fullName'] ?? 'No Name';
        _userEmail = user.email ?? 'No Email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(),
          _buildLogoutButton(context),
          _buildDrawerItem(
            icon: Icons.child_care,
            title: AppLocalizations.of(context).translate('home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/homme');
            },
          ),
          _buildDrawerItem(
            icon: Icons.insert_chart,
            title: AppLocalizations.of(context).translate('analysis'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PainTrackingPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.library_books,
            title: AppLocalizations.of(context).translate('library'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BabyLibraryPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.access_time,
            title: AppLocalizations.of(context).translate('reminders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Reminder_Screen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: AppLocalizations.of(context).translate('settings'),
            onTap: () {
              Navigator.of(context).pushNamed('/settting');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      accountName: Text(
        _userName,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        _userEmail,
        style: TextStyle(color: Colors.grey),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Icon(Icons.person, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        child: Text(AppLocalizations.of(context).translate('log out')),
        onPressed: () async {
          await _auth.signOut();
          Navigator.of(context).pushReplacementNamed('/loginn');
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.yellow,
          minimumSize: Size(double.infinity, 40),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      onTap: onTap,
    );
  }
}
