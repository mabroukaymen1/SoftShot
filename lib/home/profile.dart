import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  String userName = "";
  String babyName = "";
  int babyAgeMonths = 0;
  String profileImageUrl = "";
  List<String> babyProblems = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            userName = userData['fullName'] ?? "";
            babyName = userData['babyName'] ?? "";
            babyAgeMonths =
                _calculateAgeInMonths(userData['birthDate'].toDate());
            profileImageUrl = userData['profileImageUrl'] ?? "";
            babyProblems = List<String>.from(userData['babyProblems'] ?? []);
          });
        } else {
          print('Document does not exist for user ${user.uid}');
          // Handle case where document doesn't exist
        }
      } catch (e) {
        print('Error loading user data: $e');
        // Handle error fetching document
      }
    }
  }

  int _calculateAgeInMonths(DateTime birthDate) {
    DateTime now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  double get vaccinationHours {
    // This is a simplistic calculation. Adjust as needed.
    return babyAgeMonths * 0.5;
  }

  Future<void> pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7C72FF), // Purple background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _buildProfileImage(),
            SizedBox(height: 10),
            Text(
              userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '$babyName - $babyAgeMonths months old',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 20),
            _buildStatsRow(),
            SizedBox(height: 20),
            _buildMenuItems(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Color(0xFF9DEAC0), // Light green background color
      backgroundImage: AssetImage('image/baby.png'), // Placeholder image
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          vaccinationHours.toStringAsFixed(1),
          'Vaccination Hours',
          Icons.access_time,
        ),
        _buildProblemCheck(),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF7C72FF)), // Purple icon color
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProblemCheck() {
    bool hasProblems = babyProblems.isNotEmpty;

    return Container(
      width: 140,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: hasProblems ? Colors.red : Colors.green,
          ),
          SizedBox(height: 5),
          Text(
            hasProblems ? 'Has Problems' : 'No Problems',
            style: TextStyle(
              fontSize: 14,
              color: hasProblems ? Colors.red : Colors.green,
            ),
          ),
          Text(
            'Check Chart',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem('Notification', Icons.notifications, () {
            Navigator.of(context).pushNamed('/notifScreen');
          }),
          _buildMenuItem('Settings', Icons.settings, () {
            Navigator.of(context).pushNamed('/setting');
          }),
          _buildMenuItem('Support Service', Icons.headset_mic, () {}),
          _buildMenuItem('Privacy & Policy', Icons.lock, () {
            Navigator.of(context).pushNamed('/policy');
          }),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushReplacementNamed('/login'); // Adjust as needed
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: 16),
              ),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF7C72FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF7C72FF)), // Purple icon color
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
