import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_7.dart';

class Question6 extends StatelessWidget {
  const Question6({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 6,
      totalQuestions: 9,
      questionText: 'الشعور بأنك فاشل أو أنك شخص لا قيمة له',
      imagePath: 'assets/images/q6.jpeg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question7()),
        );
      },
    );
  }
}