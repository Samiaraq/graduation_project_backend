import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_2.dart';

class Question1 extends StatelessWidget {
  const Question1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 1,
      totalQuestions: 9,
      questionText: 'قلة الاهتمام أو فقدان الاهتمام بالأشياء',
      imagePath: 'assets/images/q1.jpeg',
      hasPrevious: false,
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question2()),
        );
      },
    );
  }
}