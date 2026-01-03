import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_4.dart';
import 'app_data_provider.dart';
import 'package:provider/provider.dart';

class Question3 extends StatelessWidget {
  const Question3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 3,
      totalQuestions: 9,
      questionText: 'صعوبة في النوم أو الاستيقاظ في وقت مبكر',
      imagePath: 'assets/image/q3.jpg',
      onPrevious: () {
        Navigator.pop(context);
      },
      onNext: (int selectedAnswer) {
        // حفظ الإجابة في البروفايدر
        final appData = context.read<AppData>();
        appData.setAnswer(3, selectedAnswer);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question4()),
        );
      },
    );
  }
}