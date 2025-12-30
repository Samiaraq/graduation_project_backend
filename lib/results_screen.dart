// lib/results_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import 'api_service.dart';
import 'app_colors.dart';
import 'app_data_provider.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _finalResultText; // سيحتوي على النص الإنجليزي من الـ API
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _triggerAnalysis());
  }

  Future<void> _triggerAnalysis() async {
    final appData = context.read<AppData>();

    if (appData.userId == null || appData.faceImageBase64 == null || appData.textInput.isEmpty) {
      setState(() {
        _errorMessage = 'بيانات غير مكتملة. يرجى التأكد من تسجيل الدخول، التقاط صورة، وكتابة نص.';
        _isLoading = false;
      });
      return;
    }

    try {
      final int userId = appData.userId!;
      final String imageBase64 = appData.faceImageBase64!;
      final String textInput = appData.textInput;
      final int score = appData.questionnaireAnswers.values.fold(0, (prev, curr) => prev + curr);

      final result = await _apiService.submitCompleteAnalysis(
        userId: userId,
        imageBase64: imageBase64,
        textInput: textInput,
        phqAnswersScore: score,
      );

      setState(() {
        // نحفظ النتيجة الإنجليزية الأصلية من الـ API
        _finalResultText = result['prediction'] ?? 'لم يتم تحديد النتيجة من الخادم';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء التواصل مع الخادم: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('النتيجة النهائية', style: TextStyle(fontFamily: 'Beiruti', color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // لمنع زر الرجوع التلقائي
      ),
      body: Stack(
        children: [
          _buildDecorativeCircles(MediaQuery.of(context).size),
          _isLoading
              ? _buildLoadingIndicator()
              : _errorMessage.isNotEmpty
                  ? _buildErrorDisplay()
                  : _buildResultsDisplay(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text('نقوم بتحليل بياناتك الآن...', style: TextStyle(fontFamily: 'Beiruti', color: AppColors.primaryText, fontSize: 18)),
          Text('قد تستغرق هذه العملية بضع لحظات', style: TextStyle(fontFamily: 'Beiruti', color: AppColors.secondaryText, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: const TextStyle(fontFamily: 'Beiruti', color: AppColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Beiruti', color: AppColors.secondaryText, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // --- دالة عرض النتائج (تم تعديلها لتشمل الترجمة) ---
  Widget _buildResultsDisplay() {
    // --- 1. قاموس الترجمة ---
    String getArabicTranslation(String? englishResult) {
      switch (englishResult) {
        case 'Severe Depression':
          return 'اكتئاب شديد';
        case 'Moderate Depression':
          return 'اكتئاب متوسط';
        case 'Mild Depression':
          return 'اكتئاب خفيف';
        case 'Not Depressed':
          return 'غير مكتئب';
        default:
          // في حال جاء نص غير متوقع من الـ API
          return englishResult ?? 'نتيجة غير محددة';
      }
    }

    // --- 2. الحصول على النص المترجم ---
    final String arabicResult = getArabicTranslation(_finalResultText);

    // --- 3. بناء النصوص بناءً على النتيجة المترجمة ---
    String title = 'تحليلك الشخصي';
    String body;

    if (_finalResultText == 'Not Depressed') {
      body = 'بناءً على تحليل بياناتك، لا تظهر حالياً مؤشرات واضحة للاكتئاب. تذكر أن هذه مجرد أداة مساعدة، وننصحك دائماً بالاهتمام بصحتك النفسية.';
    } else {
      body = 'بناءً على تحليل بياناتك، تظهر المؤشرات أن حالتك قد تكون: "$arabicResult".';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Beiruti', fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  const SizedBox(height: 20),
                  Text(body, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Beiruti', fontSize: 18, color: AppColors.secondaryText, height: 1.5)),
                ],
              ),
            ),
            const Spacer(),
            const Text('هذا التحليل ليس تشخيصاً طبياً، بل هو أداة لمساعدتك على فهم نفسك بشكل أفضل. نوصي بشدة بالتواصل مع مختص.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Beiruti', fontSize: 14, color: AppColors.secondaryText)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchWhatsApp,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBackground, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('تواصل مع مختص الآن', style: TextStyle(fontFamily: 'Beiruti', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- دالة فتح واتساب (تم تحديثها بالرقم الحقيقي) ---
  Future<void> _launchWhatsApp() async {
    const String phoneNumber = '+962790343070';
    const String message = 'مرحباً، لقد استخدمت تطبيق "Depresence" وأود الاستفسار عن إمكانية حجز جلسة استشارية.';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message )}',
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تطبيق واتساب غير مثبت على جهازك.')),
          );
        }
      }
    } catch (e) {
      print('Could not launch WhatsApp: $e');
    }
  }

  Widget _buildDecorativeCircles(Size screenSize) {
    return Stack(
      children: [
        Positioned(
            top: -screenSize.width * 0.3,
            right: -screenSize.width * 0.4,
            child: Container(
                width: screenSize.width * 0.9,
                height: screenSize.width * 0.9,
                decoration: const BoxDecoration(
                    color: AppColors.decorativeCircle,
                    shape: BoxShape.circle))),
        Positioned(
            bottom: -screenSize.width * 0.5,
            left: -screenSize.width * 0.3,
            child: Container(
                width: screenSize.width * 1.2,
                height: screenSize.width * 1.2,
                decoration: const BoxDecoration(
                    color: AppColors.decorativeCircle,
                    shape: BoxShape.circle))),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
            child: Container(color: Colors.transparent)),
      ],
    );
  }
}