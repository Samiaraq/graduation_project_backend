import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_8.dart';
import 'app_data_provider.dart';
import 'package:provider/provider.dart';

class Question7 extends StatelessWidget {
  const Question7({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 7,
      totalQuestions: 9,
      questionText: 'صعوبة في التركيز أو اتخاذ القرارات',
      imagePath: 'assets/image/q7.jpg',
      onPrevious: () {
        Navigator.pop(context);
      },
 onNext: (int selectedAnswer) {
        // حفظ الإجابة في البروفايدر
        final appData = context.read<AppData>();
        appData.setAnswer(7, selectedAnswer);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question8()),
        );
      },
    );
  }
}