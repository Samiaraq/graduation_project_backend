// lib/signup_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import 'login_screen.dart';
import 'camera_screen.dart';
import 'api_service.dart';
import 'app_data_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  void _submitForm() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار الجنس')));
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب الموافقة على شروط الخصوصية أولاً')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final result = await _apiService.registerUser(
          username: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          gender: _selectedGender!,
          dateOfBirth: _selectedDate!,
        );

        final int userId = result['user_id'];
        context.read<AppData>().setUserId(userId);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const CameraScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateController.dispose();
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
                        'ابدأ رحلتك في التعافي',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Beiruti', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'إنشاء حساب',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Beiruti', fontSize: 20, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 30),
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'اسم المستخدم',
                        hint: 'أدخل اسم المستخدم الخاص بك',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المستخدم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
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
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        hint: '*********',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          if (value.length < 8) {
                            return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        controller: _confirmPasswordController,
                        label: 'تأكيد كلمة المرور',
                        hint: '*********',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء تأكيد كلمة المرور';
                          }
                          if (value != _passwordController.text) {
                            return 'كلمتا المرور غير متطابقتين';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDateTextField(context),
                      const SizedBox(height: 15),
                      _buildGenderSelection(),
                      const SizedBox(height: 20),
                      _buildTermsCheckbox(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('إنشاء حساب', style: TextStyle(fontFamily: 'Beiruti', fontSize: 18, color: AppColors.primaryText, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      _buildLoginLink(context),
                      const SizedBox(height: 20),
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
        Text(
          label,
          style: const TextStyle(
              fontFamily: 'Beiruti',
              fontSize: 16,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600),
        ),
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

  Widget _buildDateTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تاريخ الميلاد',
          style: TextStyle(
              fontFamily: 'Beiruti',
              fontSize: 16,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
                _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'اختر تاريخ ميلادك',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child:
                  Icon(Icons.calendar_today, color: AppColors.buttonBackground),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء اختيار تاريخ الميلاد';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الجنس',
          style: TextStyle(
              fontFamily: 'Beiruti',
              fontSize: 16,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _genderOption('أنثى')),
            const SizedBox(width: 15),
            Expanded(child: _genderOption('ذكر')),
          ],
        ),
      ],
    );
  }

  Widget _genderOption(String gender) {
    final bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonBackground
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
                fontFamily: 'Beiruti',
                color: isSelected ? AppColors.primaryText : Colors.black54,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (bool? value) => setState(() => _agreedToTerms = value!),
          activeColor: AppColors.buttonBackground,
          checkColor: Colors.white,
        ),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontFamily: 'Beiruti',
                  color: AppColors.secondaryText,
                  fontSize: 14),
              children: [
                const TextSpan(text: 'أوافق على '),
                TextSpan(
                  text: 'أحكام وشروط الخصوصية',
                  style: const TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      print('Show terms and conditions');
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontFamily: 'Beiruti',
              fontSize: 14,
              color: AppColors.secondaryText),
          children: [
            const TextSpan(text: 'هل لديك حساب بالفعل؟ '),
            TextSpan(
              text: 'تسجيل الدخول',
              style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
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
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -screenSize.width * 0.5,
          left: -screenSize.width * 0.3,
          child: Container(
            width: screenSize.width * 1.2,
            height: screenSize.width * 1.2,
            decoration: const BoxDecoration(
              color: AppColors.decorativeCircle,
              shape: BoxShape.circle,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}