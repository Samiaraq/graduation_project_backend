import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_9.dart';

class Question8 extends StatelessWidget {
  const Question8({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 8,
      totalQuestions: 9,
      questionText: 'الحركة أو التحدث ببطء أو العكس',
      imagePath: 'assets/images/q8.jpeg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question9()),
        );
      },
    );
  }
}