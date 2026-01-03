// lib/question_1.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'question_screen.dart';
import 'question_2.dart';
import 'app_data_provider.dart';

class Question1 extends StatelessWidget {
  const Question1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 1,
      totalQuestions: 9,
      questionText: 'قلة الاهتمام أو فقدان الاهتمام بالأشياء',
      imagePath: 'assets/image/q1.jpg',
      hasPrevious: false,

      // --- هنا نعدل onNext ليأخذ selectedAnswer ---
      onNext: (int selectedAnswer) {
        // حفظ الإجابة في البروفايدر
        final appData = context.read<AppData>();
        appData.setAnswer(1, selectedAnswer);

        // الانتقال للسؤال التالي
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question2()),
        );
      },
    );
  }
}
