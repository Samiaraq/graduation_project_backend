import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_5.dart';

class Question4 extends StatelessWidget {
  const Question4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 4,
      totalQuestions: 9,
      questionText: 'الشعور بالتعب أو فقدان الطاقة',
      imagePath: 'assets/images/q4.jpeg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question5()),
        );
      },
    );
  }
}