// lib/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  final String baseUrl = 'https://graduation-project-backend-bx8k.onrender.com';

  // --- 1. دالة إنشاء حساب جديد (تمت إعادة username إليها ) ---
  Future<Map<String, dynamic>> registerUser({
    required String username, // <-- تمت إعادته
    required String email,
    required String password,
    required String gender,
    required DateTime dateOfBirth,
  }) async {
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register' ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username, // <-- تمت إعادته
        'email': email,
        'password': password,
        'gender': gender,
        'dob': DateFormat('yyyy-MM-dd').format(dateOfBirth),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('Error Body: ${response.body}');
      throw Exception('فشل إنشاء الحساب. الرمز: ${response.statusCode}');
    }
  }

  // --- باقي الدوال تبقى كما هي بدون تغيير ---
  
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login' ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error Body: ${response.body}');
      throw Exception('فشل تسجيل الدخول. الرمز: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> submitCompleteAnalysis({
    required int userId,
    required String imageBase64,
    required String textInput,
    required int phqAnswersScore,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/assessments' ));
    request.fields['user_id'] = userId.toString();
    request.fields['text_input'] = textInput;
    request.fields['phq_answers'] = phqAnswersScore.toString();
    request.files.add(http.MultipartFile.fromBytes('image', base64Decode(imageBase64 ), filename: 'analysis_image.jpg'));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('Error Body: ${response.body}');
      throw Exception('فشل إرسال التحليل الكامل. الرمز: ${response.statusCode}');
    }
  }

  Future<void> submitPhqScore({
    required int userId,
    required int score,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/phq/submit' ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'score': score}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('PHQ score submitted successfully.');
      } else {
        print('Failed to submit PHQ score. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error submitting PHQ score: $e');
    }
  }
}