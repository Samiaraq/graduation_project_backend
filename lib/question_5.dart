import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_6.dart';

class Question5 extends StatelessWidget {
  const Question5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 5,
      totalQuestions: 9,
      questionText: 'قلة الشهية أو الإفراط في الأكل',
      imagePath: 'assets/images/q5.jpeg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question6()),
        );
      },
    );
  }
}