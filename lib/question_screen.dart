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
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  
  // --- 1. التعديل الأول: تغيير نوع الدالة ---
  // بدلاً من VoidCallback، أصبحت دالة تستقبل int
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

    // هذا المتغير يراقب الإجابة المختارة من البروفايدر
    final selectedOption = context.watch<AppData>().getAnswer(widget.questionNumber);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildDecorativeCircles(size),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// الكارد
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
                          /// الصورة
                          Image.asset(
                            widget.imagePath,
                            height: size.height * 0.25,
                            fit: BoxFit.cover,
                          ),

                          /// رقم السؤال + النص
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

                          /// الاختيارات
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: List.generate(4, (index) {
                                final isSelected = selectedOption == index;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // عند الضغط على أي خيار، يتم حفظه في البروفايدر
                                      context.read<AppData>().setAnswer(
                                          widget.questionNumber, index);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? const Color.fromARGB(
                                              255, 80, 121, 191)
                                          : const Color.fromARGB(
                                              128, 182, 187, 194),
                                      foregroundColor: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      // عرض النصوص بدلاً من الأرقام
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

                  /// أزرار التنقل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر السابق
                      if (widget.hasPrevious)
                        ElevatedButton(
                          onPressed: widget.onPrevious,
                          style: _navButtonStyle(),
                          child: const Text('السابق'),
                        )
                      else // لإبقاء المسافة متساوية حتى لو لم يكن هناك زر
                        const SizedBox(width: 120),

                      // --- 2. التعديل الثاني: استدعاء onShowResults مع الإجابة ---
                      ElevatedButton(
                        // يتم تفعيل الزر فقط إذا اختار المستخدم إجابة
                        onPressed: selectedOption == null
                            ? null
                            : () {
                                if (widget.isLast) {
                                  // إذا كانت هذه هي الصفحة الأخيرة
                                  if (widget.onShowResults != null) {
                                    // نقوم باستدعاء onShowResults ونمرر له الإجابة المختارة
                                    widget.onShowResults!(selectedOption);
                                  }
                                } else {
                                  // إذا لم تكن الأخيرة، نستدعي onNext كالمعتاد
                                  if (widget.onNext != null) {
                                    widget.onNext!();
                                  }
                                }
                              },
                        style: _navButtonStyle(),
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

  // دالة مساعدة لعرض نصوص الخيارات بدلاً من الأرقام
  String _getOptionText(int index) {
    switch (index) {
      case 0:
        return 'إطلاقاً';
      case 1:
        return 'عدة أيام';
      case 2:
        return 'أكثر من نصف الأيام';
      case 3:
        return 'كل يوم تقريباً';
      default:
        return '';
    }
  }

  ButtonStyle _navButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonBackground,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
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