import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_3.dart';
import 'app_data_provider.dart';
import 'package:provider/provider.dart';

class Question2 extends StatelessWidget {
  const Question2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 2,
      totalQuestions: 9,
      questionText: 'الشعور بالحزن أو الاكتئاب',
      imagePath: 'assets/image/q2.jpg',
      onPrevious: () {
        Navigator.pop(context);
      },
         onNext: (int selectedAnswer) {
        // حفظ الإجابة في البروفايدر
        final appData = context.read<AppData>();
        appData.setAnswer(2, selectedAnswer);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question3()),
        );
      },
    );
  }
}