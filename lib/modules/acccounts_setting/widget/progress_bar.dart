import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget implements PreferredSizeWidget {
  final double? value;
  final int? currentStep;
  final int? totalSteps;
  final Color color;
  final Color backgroundColor;
  final double height;
  
  @override
  final Size preferredSize = const Size.fromHeight(6.0); // The height of the progress bar

  const CustomProgressBar({
    super.key,
    this.value,
    this.currentStep,
    this.totalSteps,
    this.color = const Color(0xFFD4A373),
    this.backgroundColor = const Color(0xFF686766),
    this.height = 6.0,
  }) : assert(value == null || (value >= 0.0 && value <= 1.0),
             'Value must be between 0.0 and 1.0 if provided'),
       assert(currentStep == null || totalSteps == null || (currentStep > 0 && currentStep <= totalSteps),
             'Current step must be between 1 and total steps if provided'),
       assert((value != null) != ((currentStep != null && totalSteps != null)),
             'Either provide value OR currentStep and totalSteps, not both');

  /// Calculate progress value automatically from current step and total steps
  double _calculateProgress() {
    if (value != null) {
      return value!;
    }
    
    if (currentStep != null && totalSteps != null && totalSteps! > 0) {
      return currentStep! / totalSteps!;
    }
    
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _calculateProgress();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.5),
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: height,
      ),
    );
  }
}
