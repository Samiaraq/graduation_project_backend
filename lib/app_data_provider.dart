import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  /// صورة الوجه (XFile من الكاميرا)
  XFile? _faceImageFile;

  /// النص المكتوب أو المسجّل صوتيًا
  String textInput = '';

  /// إجابات الاستبيان (رقم السؤال : رقم الاختيار)
  Map<int, int> questionnaireAnswers = {};

  /// بيانات المستخدم الأساسية
  String? name;
  String? email;
  String? password;
  String? gender;
  int? userId;
  DateTime? dateOfBirth;

  /// نتيجة التحليل من الـ API
  Map<String, dynamic>? analysisResult;

  // ================== UserId ==================
  void setUserId(int id) {
    userId = id;
    notifyListeners();
  }

  // ================== IMAGE ==================
  void setFaceImage(XFile imageFile) {
    _faceImageFile = imageFile;
    notifyListeners();
  }

  // ✅ getter جديد واضح الاسم
  XFile? get faceImageFile => _faceImageFile;

  bool get hasImage => _faceImageFile != null;

  // ================== TEXT ==================
  void setText(String text) {
    textInput = text;
    notifyListeners();
  }

  bool get hasText => textInput.trim().isNotEmpty;

  // ================== QUESTIONNAIRE ==================
  void setAnswer(int questionNumber, int selectedOption) {
    questionnaireAnswers[questionNumber] = selectedOption;
    notifyListeners();
  }

  int? getAnswer(int questionNumber) {
    return questionnaireAnswers[questionNumber];
  }

  bool get isQuestionnaireComplete => questionnaireAnswers.length == 9;

  // ================== USER DATA ==================
  void setUserData({
    required String name,
    required String email,
    required String password,
    required String gender,
    required DateTime dateOfBirth,
  }) {
    this.name = name;
    this.email = email;
    this.password = password;
    this.gender = gender;
    this.dateOfBirth = dateOfBirth;
    notifyListeners();
  }

  // ================== ANALYSIS RESULT ==================
  void setAnalysisResult(Map<String, dynamic> result) {
    analysisResult = result;
    notifyListeners();
  }

  // ================== RESET ==================
  void clearAll() {
    _faceImageFile = null;
    textInput = '';
    questionnaireAnswers.clear();
    name = null;
    email = null;
    password = null;
    gender = null;
    dateOfBirth = null;
    analysisResult = null;
    notifyListeners();
  }
}
