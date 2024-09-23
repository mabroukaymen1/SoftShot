import 'dart:async';
import 'package:baby/babyinfo/chose.dart';
import 'package:baby/sign_up_staff/home_staff.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baby/home/color.dart';
import 'package:baby/log_in/languge.dart';

class VerificationMethod_Screen extends StatefulWidget {
  final String userPhone;
  final Function(Locale) onLocaleChange;

  VerificationMethod_Screen(
      {required this.userPhone, required this.onLocaleChange});

  @override
  _VerificationMethodScreenState createState() =>
      _VerificationMethodScreenState();
}

class _VerificationMethodScreenState extends State<VerificationMethod_Screen>
    with WidgetsBindingObserver {
  String? _selectedMethod;
  String? userEmail;
  String? userPhone;
  bool _isLoading = false;
  Timer? _verificationCheckTimer;

  @override
  void initState() {
    super.initState();
    userPhone = widget.userPhone;
    _getUserInfo();
    WidgetsBinding.instance.addObserver(this);
    _startVerificationCheck();
    initializeLanguage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkEmailVerification();
    }
  }

  Future<void> initializeLanguage() async {
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
      print('Error initializing language: $e');
    }
  }

  void _startVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        _verificationCheckTimer?.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Home_Page(
            onLocaleChange: widget.onLocaleChange,
          ),
        ));
      }
    }
  }

  Future<void> _getUserInfo() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userEmail = user.email;
          userPhone = userDoc['phone'] as String?;
        });
      }
    } catch (e) {
      _showSnackBar('failed_to_load_user_data');
    }
    setState(() => _isLoading = false);
  }

  void _selectMethod(String method) {
    setState(() => _selectedMethod = method);
  }

  Future<void> _sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      _showSnackBar('verification_email_sent');
    }
  }

  Future<void> _sendPhoneVerification() async {
    _showSnackBar('phone_verification_not_implemented');
  }

  Future<void> _sendVerification() async {
    if (_selectedMethod == null) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedMethod == 'Email') {
        await _sendEmailVerification();
      } else if (_selectedMethod == 'Phone') {
        await _sendPhoneVerification();
      }
    } catch (e) {
      _showSnackBar('error_occurred');
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String messageKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context).translate(messageKey))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: AppColors.text, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)
                          .translate('verification_method'),
                      style: AppStyles.heading.copyWith(height: 1.2),
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)
                          .translate('choose_verification_method'),
                      style: AppStyles.body.copyWith(height: 1.5),
                    ),
                    SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildOptionCard(
                          icon: Icons.email_outlined,
                          title: 'email',
                          subtitle: userEmail ??
                              AppLocalizations.of(context)
                                  .translate('not_available'),
                          selected: _selectedMethod == 'Email',
                          onTap: () => _selectMethod('Email'),
                        ),
                        _buildOptionCard(
                          icon: Icons.phone_android,
                          title: 'phone',
                          subtitle: userPhone ??
                              AppLocalizations.of(context)
                                  .translate('not_available'),
                          selected: _selectedMethod == 'Phone',
                          onTap: () => _selectMethod('Phone'),
                        ),
                      ],
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed:
                          _selectedMethod != null ? _sendVerification : null,
                      style: AppStyles.primaryButton.copyWith(
                        minimumSize: MaterialStateProperty.all(
                            Size(double.infinity, 56)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('send_verification'),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: subtitle != AppLocalizations.of(context).translate('not_available')
          ? onTap
          : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 160,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? Colors.transparent : AppColors.surface),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : AppColors.primary, size: 24),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate(title),
              style: AppStyles.subheading
                  .copyWith(color: selected ? Colors.white : AppColors.text),
            ),
            SizedBox(height: 6),
            Text(
              subtitle,
              style: AppStyles.caption.copyWith(
                color: selected
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
