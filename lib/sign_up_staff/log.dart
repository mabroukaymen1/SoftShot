import 'package:baby/setup/nav.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baby/home/color.dart';
import 'package:baby/log_in/languge.dart';

class Login_Page extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  Login_Page({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login_Page> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _rememberMe = false;
  List<String> _availableLanguages = ['en', 'fr', 'ar'];
  String _currentLanguage = 'en';
  late Future<void> _initializeLanguageFuture;

  @override
  void initState() {
    super.initState();
    _initializeLanguageFuture = _initializeLanguage();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeLanguage() async {
    try {
      final languageDoc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('language')
          .get();
      if (languageDoc.exists) {
        final languageCode = languageDoc.data()?['code'] as String?;
        if (languageCode != null) {
          setState(() {
            _currentLanguage = languageCode;
          });
          widget.onLocaleChange(Locale(languageCode));
        }
      }
    } catch (e) {
      print('Error initializing language: $e');
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        // Navigate to home page on successful login
        Navigator.pushReplacementNamed(context, '/homme');
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _refreshLanguage() async {
    await _initializeLanguage();
    setState(() {
      _initializeLanguageFuture = _initializeLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder(
          future: _initializeLanguageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileTypeScreen()),
                        );
                      },
                    ),
                    actions: [
                      _buildLanguageButton(),
                    ],
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 20),
                            _buildTitle(),
                            const SizedBox(height: 30),
                            _buildLoginForm(),
                            const SizedBox(height: 20),
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLanguageButton() {
    return PopupMenuButton<String>(
      icon: SvgPicture.asset(
        'image/svg/lang.svg',
        color: AppColors.primary,
        width: 24,
        height: 24,
      ),
      onSelected: (String result) async {
        if (_currentLanguage != result) {
          setState(() {
            _currentLanguage = result;
          });
          widget.onLocaleChange(Locale(result));
          await _saveLanguagePreference(result);
          await _refreshLanguage();
        }
      },
      itemBuilder: (BuildContext context) => _availableLanguages
          .map((lang) => PopupMenuItem<String>(
                value: lang,
                child: _buildLanguageMenuItem(lang),
              ))
          .toList(),
    );
  }

  Widget _buildLanguageMenuItem(String langCode) {
    switch (langCode) {
      case 'ar':
        return Row(
          children: [
            Text('عربي', style: TextStyle(fontFamily: 'Arabic')),
            SizedBox(width: 8),
            Text('Arabic'),
          ],
        );
      case 'fr':
        return Text('Français');
      case 'en':
        return Text('English');
      default:
        return Text(langCode);
    }
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('language')
          .set({
        'code': languageCode,
      });
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'logo',
      child: Image.asset('image/aa.png', height: 120),
    );
  }

  Widget _buildTitle() {
    return Text(
      AppLocalizations.of(context)?.translate('welcome') ?? 'Welcome',
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: emailController,
            labelText:
                AppLocalizations.of(context)?.translate('email') ?? 'Email',
            prefixIcon: Icons.email,
            validator: (value) {
              if (value!.isEmpty) return 'Email cannot be empty';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: passwordController,
            labelText: AppLocalizations.of(context)?.translate('password') ??
                'Password',
            prefixIcon: Icons.lock,
            obscureText: !_passwordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.secondaryText,
              ),
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
            validator: (value) {
              if (value!.isEmpty) return 'Password cannot be empty';
              if (value.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildRememberMeAndForgotPassword(),
          const SizedBox(height: 30),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value),
              activeColor: AppColors.primary,
            ),
            Flexible(
              child: Text(
                AppLocalizations.of(context)?.translate('remember_me') ??
                    'Remember me',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Navigate to forgot password page
          },
          child: Text(
            AppLocalizations.of(context)?.translate('forgot_password') ??
                'Forgot password?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          AppLocalizations.of(context)?.translate('login_now') ?? 'Login Now',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)?.translate('dont_have_account') ??
              'Don\'t have an account?',
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/regisster'),
          child: Text(
            AppLocalizations.of(context)?.translate('register_now') ??
                'Register Now',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
