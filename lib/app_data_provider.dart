import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  /// صورة الوجه
  String? _faceImageBase64;

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
  void setFaceImage(String imageBase64) {
    _faceImageBase64 = imageBase64;
    notifyListeners();
  }

  String? get faceImageBase64 => _faceImageBase64;
  bool get hasImage => _faceImageBase64 != null && _faceImageBase64!.isNotEmpty;

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

  // ================== RESET (اختياري) ==================
  void clearAll() {
    _faceImageBase64 = null;
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