// lib/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = 'https://graduation-project-backend-bx8k.onrender.com';

  // =========================
  // AUTH
  // =========================
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String dob,
    required String apiGender,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "dob": dob,
        "gender": apiGender,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل إنشاء الحساب: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل تسجيل الدخول: ${response.body}');
    }
  }

  // =========================
  // PHQ SUBMIT
  // =========================
  Future<Map<String, dynamic>> submitPHQ({
    required int userId,
    required List<int> answers, //[]
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/phq/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'phq_answers': answers,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل إرسال استبيان PHQ: ${response.body}');
    }
  }

  // =========================
  // SENTIMENT PREDICT
  // =========================
  Future<Map<String, dynamic>> submitSentiment({
    required int userId,
    required String text,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sentiment/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل تحليل النص: ${response.body}');
    }
  }

  // =========================
  // IMAGE UPLOAD
  // =========================
  Future<Map<String, dynamic>> uploadImage({
    required int userId,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/image');
    final request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل رفع الصورة: ${response.body}');
    }
  }
}