import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_3.dart';

class Question2 extends StatelessWidget {
  const Question2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 2,
      totalQuestions: 9,
      questionText: 'الشعور بالحزن أو الاكتئاب',
      imagePath: 'assets/images/q2.jpeg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question3()),
        );
      },
    );
  }
}