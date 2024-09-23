import 'package:baby/log_in/languge.dart';
import 'package:baby/sign_up_staff/log.dart';
import 'package:baby/sign_up_staff/ver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baby/home/color.dart';

class Register_Screen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  Register_Screen({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<Register_Screen> {
  String countryCode = '+216';
  String countryName = 'Tunisia';
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _hospitalController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeLanguage();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          countryCode = '+${country.phoneCode}';
          countryName = country.name;
        });
      },
    );
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

  Future<void> _register() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _hospitalController.text.isEmpty ||
        _positionController.text.isEmpty ||
        !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('fill_all_fields'))),
      );
      return;
    }

    if (!_validatePhoneNumber(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('invalid_phone_number'))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the current language
      final languageDoc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('language')
          .get();
      String languageCode = 'en'; // Default to English
      if (languageDoc.exists) {
        languageCode = languageDoc.data()?['code'] as String? ?? 'en';
      }

      // Save additional user info to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': '$countryCode${_phoneController.text}',
        'emailVerified': false,
        'phoneVerified': false,
        'language': languageCode,
        'hospital': _hospitalController.text,
        'position': _positionController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('registration_successful'))),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationMethod_Screen(
            userPhone: '$countryCode${_phoneController.text}',
            onLocaleChange: widget.onLocaleChange,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context).translate('registration_failed')}: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validatePhoneNumber(String phoneNumber) {
    // This is a basic validation. You might want to implement more sophisticated validation based on country codes.
    return phoneNumber.length >= 8 && phoneNumber.length <= 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Login_Page(
                        onLocaleChange: widget.onLocaleChange,
                      )),
            ),
            child: Text(AppLocalizations.of(context).translate('login'),
                style: AppStyles.body.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).translate('register'),
                  style: AppStyles.heading.copyWith(color: AppColors.primary)),
              SizedBox(height: 8),
              Text(
                  AppLocalizations.of(context).translate('create_your_account'),
                  style: AppStyles.caption),
              SizedBox(height: 24),
              _buildTextField(
                  controller: _fullNameController,
                  labelText:
                      AppLocalizations.of(context).translate('full_name')),
              SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: AppLocalizations.of(context).translate('email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildCountryCodePicker(),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      labelText: AppLocalizations.of(context)
                          .translate('phone_number'),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                labelText: AppLocalizations.of(context).translate('password'),
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.secondaryText,
                  ),
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _hospitalController,
                labelText: AppLocalizations.of(context).translate('hospital'),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _positionController,
                labelText: AppLocalizations.of(context).translate('position'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreeToTerms = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Terms and Conditions screen
                      },
                      child: Text.rich(
                        TextSpan(
                          text: AppLocalizations.of(context)
                              .translate('i_agree_to_the'),
                          style: AppStyles.caption,
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('terms_and_conditions'),
                              style: AppStyles.caption.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary)))
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: AppStyles.primaryButton,
                        child: Text(
                            AppLocalizations.of(context).translate('register'),
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppStyles.caption,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildCountryCodePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: _showCountryPicker,
        child: Text(countryCode, style: AppStyles.body),
      ),
    );
  }
}
