import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_5.dart';
import 'app_data_provider.dart';
import 'package:provider/provider.dart';

class Question4 extends StatelessWidget {
  const Question4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 4,
      totalQuestions: 9,
      questionText: 'الشعور بالتعب أو فقدان الطاقة',
      imagePath: 'assets/image/q4.jpg',
      onPrevious: () {
        Navigator.pop(context);
      },
    onNext: (int selectedAnswer) {
        // حفظ الإجابة في البروفايدر
        final appData = context.read<AppData>();
        appData.setAnswer(4, selectedAnswer);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question5()),
        );
      },
    );
  }
}