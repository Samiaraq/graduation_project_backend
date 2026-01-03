// lib/question_9.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data_provider.dart'; // <-- البروفايدر
import 'question_screen.dart';
import 'results_screen.dart';

class Question9 extends StatelessWidget {
  const Question9({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- 3. إنشاء نسخة من البروفايدر فقط ---
    final AppData appData = context.read<AppData>();

    return QuestionScreen(
      questionNumber: 9,
      totalQuestions: 9,
      questionText:
          'الأفكار بأنك ستكون أفضل لو مت أو أن تؤذي نفسك بطريقة أو بأخرى',
      imagePath: 'assets/image/q9.jpg',
      onPrevious: () => Navigator.pop(context),
      isLast: true,

      // --- 4. تعديل onShowResults ---
      onShowResults: (int selectedAnswer) async {
        // تحويل String إلى int

        // حفظ الإجابة الأخيرة في البروفايدر
        appData.setAnswer(9, selectedAnswer);

        // كل الإجابات التسعة موجودة الآن في البروفايدر
        // لا حاجة لاستدعاء API هنا، سيتم استدعاؤه في صفحة النتائج

        // الانتقال مباشرة إلى صفحة النتائج
        if (Navigator.of(context).mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ResultsScreen(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      },
    );
  }
}
