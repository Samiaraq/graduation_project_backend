// lib/welcome_screen.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'app_colors.dart';
import 'login_screen.dart';    // <--- تأكدي من وجود هذا السطر
import 'signup_screen.dart';   // <--- تأكدي من وجود هذا السطر

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildDecorativeCircles(screenSize),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const Text('ابدأ رحلتك في التعافي', textAlign: TextAlign.center, style: TextStyle(fontFamily: '', fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  const SizedBox(height: 12),
                  const Text('خطوة واحدة هي كل ما تحتاجه', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.secondaryText)),
                  const SizedBox(height: 60),

                  // --- زر تسجيل الدخول (هنا التغيير الأول) ---
                  _buildAuthButton(
                    text: 'تسجيل الدخول',
                    onPressed: () {
                      // هذا الكود ينقل المستخدم إلى صفحة تسجيل الدخول
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- زر إنشاء حساب (هنا التغيير الثاني) ---
                  _buildAuthButton(
                    text: 'إنشاء حساب',
                    onPressed: () {
                      // هذا الكود ينقل المستخدم إلى صفحة إنشاء الحساب
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // باقي الدوال المساعدة لم تتغير
  Widget _buildAuthButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.primaryText)),
    );
  }

  Widget _buildDecorativeCircles(Size screenSize) {
    return Stack(
      children: [
        Positioned(top: -screenSize.width * 0.3, right: -screenSize.width * 0.4, child: Container(width: screenSize.width * 0.9, height: screenSize.width * 0.9, decoration: const BoxDecoration(color: AppColors.decorativeCircle, shape: BoxShape.circle))),
        Positioned(bottom: -screenSize.width * 0.5, left: -screenSize.width * 0.3, child: Container(width: screenSize.width * 1.2, height: screenSize.width * 1.2, decoration: const BoxDecoration(color: AppColors.decorativeCircle, shape: BoxShape.circle))),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0), child: Container(color: Colors.transparent)),
      ],
    );
  }
}
