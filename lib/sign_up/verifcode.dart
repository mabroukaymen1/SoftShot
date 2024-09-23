import 'package:baby/home/color.dart';
import 'package:baby/babyinfo/chose.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String verificationId;
  final bool isEmail;
  final String userPhone;
  final String userEmail;

  PhoneVerificationScreen({
    required this.verificationId,
    required this.isEmail,
    required this.userPhone,
    required this.userEmail,
    required String verificationCode,
  });

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  static const int _codeLength = 6;
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());

  Future<void> _verifyCode() async {
    String enteredCode =
        _controllers.map((controller) => controller.text).join();

    try {
      if (widget.isEmail) {
        await _verifyEmail(enteredCode);
      } else {
        await _verifyPhone(enteredCode);
      }
    } catch (e) {
      _showSnackBar('Verification failed: ${e.toString()}');
    }
  }

  Future<void> _verifyEmail(String code) async {
    // Implement email verification logic here
    // This is a placeholder as Firebase doesn't have a built-in email code verification
    _showSnackBar('Email verification not implemented in this example');
    await _updateUserVerificationStatus(true);
    _navigateToBabyInfoForm();
  }

  Future<void> _verifyPhone(String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _updateUserVerificationStatus(false);
      _navigateToBabyInfoForm();
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Verification failed: ${e.message}');
    }
  }

  Future<void> _updateUserVerificationStatus(bool isEmail) async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({isEmail ? 'emailVerified' : 'phoneVerified': true});
  }

  void _navigateToBabyInfoForm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BabyInfoForm(
          onLocaleChange: (Locale locale) {
            // Implement the language change logic here
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_codeLength, (index) {
        return Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            style: AppStyles.subheading,
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryText),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < _codeLength - 1) {
                  FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                } else {
                  FocusScope.of(context).unfocus();
                }
              } else if (index > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              }
            },
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(widget.isEmail ? 'Verify Email' : 'Verify Phone',
                  style: AppStyles.heading),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Enter the verification code sent to your ${widget.isEmail ? 'email' : 'phone'}.',
                style: AppStyles.caption,
              ),
            ),
            SizedBox(height: 32),
            _buildCodeInput(),
            Spacer(),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _verifyCode,
                child: Text('Verify and continue',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                style: AppStyles.primaryButton.copyWith(
                  minimumSize:
                      MaterialStateProperty.all(Size(double.infinity, 56)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
