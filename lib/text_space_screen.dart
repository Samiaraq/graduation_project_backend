// lib/text_space_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'app_colors.dart';
import 'app_data_provider.dart';
import 'questionnaire_welcome_screen.dart'; // للانتقال للصفحة التالية

class TextSpaceScreen extends StatefulWidget {
  const TextSpaceScreen({Key? key}) : super(key: key);

  @override
  State<TextSpaceScreen> createState() => _TextSpaceScreenState();
}

class _TextSpaceScreenState extends State<TextSpaceScreen> {
  late TextEditingController _textController;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // استرجاع أي نص محفوظ مسبقاً من البروفايدر عند فتح الصفحة
    final savedText = context.read<AppData>().textInput;
    _textController = TextEditingController(text: savedText);
  }

  // --- 1. دالة تحويل الكلام إلى نص (لا تغيير هنا) ---
  void _listen() async {
    // طلب إذن استخدام الميكروفون
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // يمكنك إظهار رسالة للمستخدم هنا إذا رفض الإذن
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (error) => print('Error initializing speech: $error'),
        onStatus: (status) => print('Speech status: $status'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              // تحديث النص في الحقل وفي البروفايدر مباشرة
              _textController.text = val.recognizedWords;
              context.read<AppData>().setText(_textController.text);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // --- 2. دالة زر "التالي" (تم تبسيطها بشكل كبير) ---
  void _proceedToNextScreen() {
    // لا حاجة لاستدعاء الـ API هنا
    // فقط نتأكد من أن النص تم حفظه (وهو يحدث تلقائياً مع كل تغيير)
    // ثم ننتقل إلى الشاشة التالية
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionnaireWelcomeScreen()),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    super.dispose();
  }

  // --- 3. بناء الواجهة (تم تبسيط زر "التالي") ---
  @override
  Widget build(BuildContext context) {
    // مراقبة حالة النص لتفعيل/تعطيل زر "التالي"
    final bool hasText = context.watch<AppData>().hasText;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مساحتك الآمنة', style: TextStyle(color: Colors.white70, fontFamily: 'Beiruti')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildDecorativeCircles(screenSize),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('الخطوة 2 من 3', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Beiruti', fontSize: 16, color: AppColors.secondaryText)),
                  const SizedBox(height: 10),
                  const Text('بماذا تشعر الآن؟', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Beiruti', fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  const SizedBox(height: 40),
                  Expanded(child: _buildTextField()),
                  const SizedBox(height: 20),
                  _buildNextButton(hasText), // تمرير حالة النص للزر
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. الويدجتس المساعدة (لا تغيير هنا إلا في زر "التالي") ---

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
            child: TextField(
              controller: _textController,
              maxLines: null,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.right,
              onChanged: (value) {
                // مع كل حرف يكتبه المستخدم، يتم تحديث البروفايدر فوراً
                context.read<AppData>().setText(value);
              },
              decoration: const InputDecoration(
                hintText: 'اكتب هنا أو استخدم الميكروفون...',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.redAccent : AppColors.buttonBackground,
                size: 30,
              ),
              onPressed: _listen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        // يتم تفعيل الزر فقط إذا كان هناك نص (enabled == true)
        onPressed: enabled ? _proceedToNextScreen : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.buttonBackground : Colors.grey.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        // لا حاجة لعرض مؤشر تحميل هنا بعد الآن
        child: const Text('التالي',
            style: TextStyle(
                fontFamily: 'Beiruti',
                fontSize: 18,
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

 
   }
   Widget _buildDecorativeCircles(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.3,
          right: -size.width * 0.4,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: const BoxDecoration(
              color: AppColors.decorativeCircle,
              shape: BoxShape.circle,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }