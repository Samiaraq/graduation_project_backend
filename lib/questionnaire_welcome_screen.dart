// lib/questionnaire_welcome_screen.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'app_colors.dart';
import 'question_1.dart';
 
class QuestionnaireWelcomeScreen extends StatelessWidget {
  const QuestionnaireWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Welcome Page',
          style: TextStyle(color: Colors.white70, fontFamily: 'Beiruti'),
        ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'مرحباً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Beiruti',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'يساعدك هذا التقييم على فهم حالتك العقلية.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Beiruti',
                      fontSize: 20,
                      color: AppColors.primaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'إجاباتك سرية ولن تستغرق سوى بضع دقائق.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Beiruti',
                      fontSize: 20,
                      color: AppColors.primaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'اضغط على ابدأ للانتقال إلى الأسئلة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Beiruti',
                      fontSize: 20,
                      color: AppColors.primaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Question1(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'ابدأ',
                      style: TextStyle(
                        fontFamily: 'Beiruti',
                        fontSize: 18,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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