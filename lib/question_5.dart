import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_6.dart';
import 'app_data_provider.dart';
import 'package:provider/provider.dart';

class Question5 extends StatelessWidget {
  const Question5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 5,
      totalQuestions: 9,
      questionText: 'قلة الشهية أو الإفراط في الأكل',
      imagePath: 'assets/image/q5.jpg',
      onPrevious: () {
        Navigator.pop(context);
      },
 onNext: (int selectedAnswer) {
        // حفظ الإجابة في البروفايدر
        final appData = context.read<AppData>();
        appData.setAnswer(5, selectedAnswer);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question6()),
        );
      },
    );
  }
}