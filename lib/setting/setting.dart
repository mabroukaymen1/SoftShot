import 'package:baby/home/color.dart';
import 'package:baby/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baby/home/profile.dart';
import 'package:baby/setting/changepass.dart';
import 'package:baby/setting/notifscreen.dart';
import 'package:baby/setting/policy.dart';

class ParameterScreen extends StatefulWidget {
  const ParameterScreen(
      {Key? key, required Future<void> Function(Locale locale) onLocaleChange})
      : super(key: key);

  @override
  _ParameterScreenState createState() => _ParameterScreenState();
}

class _ParameterScreenState extends State<ParameterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = '';
  String _userEmail = '';

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
    const double paddingValue = 20.0;
    const String clientPhotoUrl = 'image/baby.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.grid_view, color: AppColors.text),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('Settings', style: AppStyles.heading),
      ),
      drawer: SharedDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _navigateToScreen(context, const ProfileScreen()),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(clientPhotoUrl),
                ),
              ),
              const SizedBox(height: 20),
              Text(_userName, style: AppStyles.heading),
              Text(_userEmail, style: AppStyles.caption),
              const SizedBox(height: 40),
              _buildSection('Profile', [
                _buildSettingTile(
                  title: 'Profile',
                  icon: Icons.person,
                  onTap: () =>
                      _navigateToScreen(context, const ProfileScreen()),
                ),
                _buildSettingTile(
                  title: 'Notifications',
                  icon: Icons.notifications,
                  onTap: () => _navigateToScreen(context, NotificationScreen()),
                ),
              ]),
              _buildSection('Support', [
                _buildSettingTile(
                  title: 'Change Password',
                  icon: Icons.lock,
                  onTap: () =>
                      _navigateToScreen(context, AccountSettingsPage()),
                ),
                _buildSettingTile(
                  title: 'Privacy',
                  icon: Icons.security,
                  onTap: () => _navigateToScreen(context, PrivacyPolicyPage()),
                ),
                _buildSettingTile(
                  title: 'Logout',
                  icon: Icons.exit_to_app,
                  onTap: () => _confirmLogout(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.heading),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
      leading: Icon(icon, color: AppColors.text),
      trailing: const Icon(Icons.chevron_right, color: AppColors.text),
      onTap: onTap,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushReplacementNamed('/login'); // Adjust as needed
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
