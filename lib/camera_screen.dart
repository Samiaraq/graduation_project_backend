// lib/camera_screen.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'app_colors.dart';
import 'app_data_provider.dart';
import 'text_space_screen.dart'; // للانتقال للصفحة التالية

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = -1;
  bool _isFlashing = false;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  // --- 1. تهيئة الكاميرات (لا تغيير هنا) ---
  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    int frontCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    _selectedCameraIndex = (frontCameraIndex != -1) ? frontCameraIndex : 0;
    _initializeCameraController();
  }

  // --- 2. تهيئة متحكم الكاميرا (لا تغيير هنا) ---
  Future<void> _initializeCameraController() async {
    if (_selectedCameraIndex == -1) return;
    // التأكد من التخلص من المتحكم القديم قبل إنشاء واحد جديد
    await _controller?.dispose();
    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  // --- 3. تبديل الكاميرا (لا تغيير هنا) ---
  void _switchCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _initializeCameraController();
  }

  // --- 4. دالة التقاط الصورة (تم تبسيطها بشكل كبير) ---
  void _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // الخطوة أ: التقاط الصورة
      final XFile image = await _controller!.takePicture();
      
      // الخطوة ج: حفظ سلسلة Base64 في الـ Provider
      // استخدام listen: false هنا لأننا داخل دالة ولا نريد إعادة بناء الواجهة
         context.read<AppData>().setFaceImage(image);
      // الخطوة د: تأثير الفلاش (لتحسين تجربة المستخدم)
      if (mounted) {
        setState(() => _isFlashing = true);
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) setState(() => _isFlashing = false);
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // --- 5. بناء الواجهة (تم تبسيط زر "التالي") ---
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // مراقبة حالة الصورة لتفعيل/تعطيل زر "التالي"
    final bool isPictureTaken = context.watch<AppData>().hasImage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('صورة للوجه', style: TextStyle(color: Colors.white54, fontFamily: 'Beiruti', fontWeight: FontWeight.w300)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          _buildDecorativeCircles(screenSize),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text('الخطوة 1 من 3', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Beiruti', fontSize: 16, color: AppColors.secondaryText)),
                const SizedBox(height: 10),
                const Text('تحليل تعابير الوجه', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Beiruti', fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                const Spacer(),
                _buildCameraPreview(),
                const Spacer(),
                _buildControls(),
                const SizedBox(height: 20),
                _buildNextButton(isPictureTaken), // تمرير حالة الصورة للزر
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Text('لن يتم حفظ هذه الصورة، تستخدم فقط للتحليل', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Beiruti', fontSize: 14, color: Color.fromARGB(255, 219, 227, 233))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. الويدجتس المساعدة (لا تغيير هنا إلا في زر "التالي") ---

Widget _buildCameraPreview() {
    return Center(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_controller != null && _controller!.value.isInitialized)
                CameraPreview(_controller!)
              else
                const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
              Center(
                child: Container(
                  width: 220,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(110),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                ),
              ),
              if (_isFlashing)
                Container(
                  color: Colors.white.withOpacity(0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 64),
        GestureDetector(
          onTap: _takePicture,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                  color: AppColors.buttonBackground.withOpacity(0.8), width: 4),
            ),
          ),
        ),
        const SizedBox(width: 15),
        IconButton(
          icon: const Icon(Icons.flip_camera_ios_outlined,
              color: Colors.white, size: 28),
          onPressed: _switchCamera,
        ),
      ],
    );
  }

  Widget _buildNextButton(bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TextSpaceScreen()));
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? AppColors.buttonBackground : Colors.grey.shade600,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: enabled ? 5 : 0,
        ),
        child: const Text('التالي',
            style: TextStyle(
                fontFamily: 'Beiruti',
                fontSize: 18,
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold)),
      ),
    );
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