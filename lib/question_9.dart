// lib/question_9.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_service.dart'; // <-- 1. استيراد خدمة الـ API
import 'app_data_provider.dart'; // <-- 2. استيراد البروفايدر
import 'question_screen.dart';
import 'results_screen.dart';

class Question9 extends StatelessWidget {
  const Question9({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- 3. إنشاء نسخة من الخدمات التي نحتاجها ---
    final ApiService apiService = ApiService();
    final AppData appData = context.read<AppData>();

    return QuestionScreen(
      questionNumber: 9,
      totalQuestions: 9,
      questionText: 'الأفكار بأنك ستكون أفضل حالاً لو فارقت الحياة، أو بإيذاء نفسك بطريقة ما.',
      imagePath: 'assets/images/q9.jpeg',
      onPrevious: () => Navigator.pop(context),
      isLast: true,

      // --- 4. تعديل onShowResults لتصبح async ---
      onShowResults: (int selectedAnswer) async {
        // الخطوة أ: حفظ الإجابة الأخيرة في البروفايدر (كما ناقشنا سابقاً)
        appData.setAnswer(9, selectedAnswer);

        // --- 5. التحسين الجديد: حفظ النتيجة الأولية في الخلفية ---
        // نتأكد أولاً أن لدينا user_id
        if (appData.userId != null) {
          // حساب المجموع الكلي من البروفايدر
          final int totalScore = appData.questionnaireAnswers.values.fold(0, (prev, curr) => prev + curr);
          
          // استدعاء الـ API لحفظ النتيجة (لا ننتظر الرد ولن يوقف التطبيق)
          // هذه العملية تحدث في الخلفية
          apiService.submitPhqScore(
            userId: appData.userId!,
            score: totalScore,
          );
        }

        // الخطوة ب: الانتقال إلى صفحة النتائج فوراً (لا ننتظر الخطوة السابقة)
        // نستخدم mounted check للتأكد من أن الـ widget لا يزال في الشجرة
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