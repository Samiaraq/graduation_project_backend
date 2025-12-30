import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_4.dart';

class Question3 extends StatelessWidget {
  const Question3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 3,
      totalQuestions: 9,
      questionText: 'صعوبة في النوم أو الاستيقاظ في وقت مبكر',
      imagePath: 'assets/images/q3.jpeg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question4()),
        );
      },
    );
  }
}