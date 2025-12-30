// lib/login_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import 'api_service.dart'; // <-- 1. استيراد خدمة الـ API
import 'app_colors.dart';
import 'signup_screen.dart';
import 'camera_screen.dart';
import 'app_data_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // <-- 2. متغير حالة لعرض مؤشر التحميل
  final ApiService _apiService = ApiService(); // <-- 3. إنشاء نسخة من خدمة الـ API

  // --- 4. تعديل دالة إرسال النموذج ---
  void _submitForm() async { // تحويل الدالة إلى async
    if (_formKey.currentState!.validate()) {
      // عرض مؤشر التحميل
      setState(() { _isLoading = true; });

      try {
        // استدعاء الـ API لتسجيل الدخول
        final response = await _apiService.loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // نفترض أن الـ API يعيد 'user_id' و 'access_token'
        if (response.containsKey('user_id') && response.containsKey('access_token')) {
          final int userId = response['user_id'];
          // final String accessToken = response['access_token']; // يمكنك حفظه إذا احتجت إليه

          // --- الخطوة الأهم: حفظ معرّف المستخدم في البروفايدر ---
          context.read<AppData>().setUserId(userId);

          // الانتقال إلى الشاشة الرئيسية بعد النجاح
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const CameraScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          throw Exception('الخادم لم يرجع البيانات المطلوبة (user_id, access_token)');
        }

      } catch (e) {
        // في حال حدوث خطأ، إظهار رسالة للمستخدم
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل تسجيل الدخول: ${e.toString()}')),
          );
        }
      } finally {
        // إخفاء مؤشر التحميل في كل الحالات (نجاح أو فشل)
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          _buildDecorativeCircles(screenSize),
          SafeArea(
            child: Center(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'أهلاً بعودتك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Beiruti',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'تسجيل الدخول',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Beiruti',
                          fontSize: 20,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'الإيميل',
                        hint: 'أدخل بريدك الإلكتروني',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'الرجاء إدخال بريد إلكتروني صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        hint: '*********',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {/* TODO: Implement forgot password */},
                          child: const Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                                fontFamily: 'Beiruti',
                                color: AppColors.secondaryText),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                    fontFamily: 'Beiruti',
                                    fontSize: 18,
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 30),
                      _buildSignUpLink(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Beiruti',
                fontSize: 16,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.black87, fontFamily: 'Beiruti'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontFamily: 'Beiruti',
              fontSize: 14,
              color: AppColors.secondaryText),
          children: [
            const TextSpan(text: 'ليس لديك حساب؟ '),
            TextSpan(
              text: 'قم بإنشاء حساب',
              style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()));
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles(Size screenSize) {
    return Stack(
      children: [
        Positioned(
            top: -screenSize.width * 0.3,
            right: -screenSize.width * 0.4,
            child: Container(
                width: screenSize.width * 0.9,
                height: screenSize.width * 0.9,
                decoration: const BoxDecoration(
                    color: AppColors.decorativeCircle,
                    shape: BoxShape.circle))),
        Positioned(
            bottom: -screenSize.width * 0.5,
            left: -screenSize.width * 0.3,
            child: Container(
                width: screenSize.width * 1.2,
                height: screenSize.width * 1.2,
                decoration: const BoxDecoration(
                    color: AppColors.decorativeCircle,
                    shape: BoxShape.circle))),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
            child: Container(color: Colors.transparent)),
      ],
    );
  }
}