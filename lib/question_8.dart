import 'package:flutter/material.dart';
import 'question_screen.dart';
import 'question_9.dart';
import 'app_data_provider.dart';
import 'package:provider/provider.dart';

class Question8 extends StatelessWidget {
  const Question8({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionScreen(
      questionNumber: 8,
      totalQuestions: 9,
      questionText: 'الحركة أو التحدث ببطء أو العكس',
      imagePath: 'assets/image/q8.jpg',
      onPrevious: () {
        Navigator.pop(context);
      },
 onNext: (int selectedAnswer) {
        // حفظ الإجابة في البروفايدر
        final appData = context.read<AppData>();
        appData.setAnswer(8, selectedAnswer);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Question9()),
        );
      },
    );
  }
}