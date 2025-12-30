import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_8.dart';

class Question7 extends StatelessWidget {
  const Question7({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 7,
      totalQuestions: 9,
      questionText: 'صعوبة في التركيز أو اتخاذ القرارات',
      imagePath: 'assets/images/q7.jpeg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question8()),
        );
      },
    );
  }
}