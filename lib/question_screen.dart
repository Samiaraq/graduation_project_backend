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

  // ✅ تعديل 1: onNext صار يستقبل int
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

    final selectedOption =
        context.watch<AppData>().getAnswer(widget.questionNumber);

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
                          Image.asset(
                            widget.imagePath,
                            height: size.height * 0.25,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.questionNumber}/${widget.totalQuestions}',
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    widget.questionText,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: List.generate(4, (index) {
                               // final isSelected = selectedOption == index;

                                return ElevatedButton(
                                  onPressed: () {
                                    context.read<AppData>().setAnswer(
                                        widget.questionNumber, index);
                                  },
                                  child: Text(_getOptionText(index)),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.hasPrevious)
                        ElevatedButton(
                          onPressed: widget.onPrevious,
                          child: const Text('السابق'),
                        )
                      else
                        const SizedBox(width: 120),

                      ElevatedButton(
                        onPressed: selectedOption == null
                            ? null
                            : () {
                                if (widget.isLast) {
                                  widget.onShowResults?.call(selectedOption);
                                } else {
                                  // ✅ تعديل 2: تمرير selectedOption
                                  widget.onNext?.call(selectedOption);
                                }
                              },
                        child:
                            Text(widget.isLast ? 'عرض النتائج' : 'التالي'),
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

  Widget _buildDecorativeCircles(Size size) => Container();
}
