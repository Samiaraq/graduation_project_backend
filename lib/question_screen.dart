// lib/question_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import 'app_data_provider.dart';

class QuestionScreen extends StatefulWidget {
  final int questionNumber;
  final int totalQuestions;
  final String questionText;
  final String imagePath;
  final bool hasPrevious;
  final bool isLast;

  // ✅ المنطق الجديد: onNext يستقبل int
  final Function(int)? onNext;

  final VoidCallback? onPrevious;
  final Function(int)? onShowResults;

  const QuestionScreen({
    Key? key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.questionText,
    required this.imagePath,
    this.hasPrevious = true,
    this.isLast = false,
    this.onNext,
    this.onPrevious,
    this.onShowResults,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ✅ المنطق الجديد: قراءة الإجابة من البروفايدر
    final selectedOption =
        context.watch<AppData>().getAnswer(widget.questionNumber);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // --- التصميم القديم: الخلفية مع الدوائر والبلور ---
          _buildDecorativeCircles(size),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- التصميم القديم: الكارد ---
                  Expanded(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- التصميم القديم: الصورة ---
                          Image.asset(
                            widget.imagePath,
                            height: size.height * 0.25,
                            fit: BoxFit.cover,
                          ),
                          // --- التصميم القديم: رقم السؤال والنص ---
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.questionNumber}/${widget.totalQuestions}',
                                  style: const TextStyle(
                                    fontFamily: 'Beiruti',
                                    color: Color.fromARGB(255, 129, 172, 235),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    widget.questionText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Beiruti',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 55, 93, 164),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // --- التصميم القديم: أزرار الاختيارات ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: List.generate(4, (index) {
                                final isSelected = selectedOption == index;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // ✅ المنطق الجديد: تحديث البروفايدر
                                      context.read<AppData>().setAnswer(
                                          widget.questionNumber, index);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? const Color.fromARGB(255, 80, 121, 191)
                                          : const Color.fromARGB(128, 182, 187, 194),
                                      foregroundColor: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      minimumSize: const Size(double.infinity, 50),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    // ✅ المنطق الجديد: استخدام دالة _getOptionText
                                    child: Text(
                                      _getOptionText(index),
                                      style: const TextStyle(
                                        fontFamily: 'Beiruti',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // --- التصميم القديم: أزرار التنقل السفلية ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: widget.hasPrevious ? widget.onPrevious : null,
                        style: _navButtonStyle(isEnabled: widget.hasPrevious),
                        child: const Text('السابق'),
                      ),
                      ElevatedButton(
                        onPressed: selectedOption == null
                            ? null
                            : () {
                                // ✅ المنطق الجديد: استدعاء onNext/onShowResults مع القيمة
                                if (widget.isLast) {
                                  widget.onShowResults?.call(selectedOption);
                                } else {
                                  widget.onNext?.call(selectedOption);
                                }
                              },
                        style: _navButtonStyle(isEnabled: selectedOption != null),
                        child: Text(
                          widget.isLast ? 'عرض النتائج' : 'التالي',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ المنطق الجديد: دالة _getOptionText تبقى كما هي
  String _getOptionText(int index) {
    switch (index) {
      case 0:
        return '0';
      case 1:
        return '1';
      case 2:
        return '2';
      case 3:
        return '3';
      default:
        return '';
    }
  }

  // --- التصميم القديم: دالة بناء أزرار التنقل ---
  ButtonStyle _navButtonStyle({bool isEnabled = true}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isEnabled ? AppColors.buttonBackground : Colors.grey.shade600,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  // --- التصميم القديم: دالة بناء الخلفية ---
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
        Positioned(
          bottom: -size.width * 0.5,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 1.2,
            height: size.width * 1.2,
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
}