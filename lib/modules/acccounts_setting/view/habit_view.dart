import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/habit_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';
import '../widget/custom_pill_checkbox.dart';

class HabitView extends GetView<HabitController> {
  const HabitView({super.key});

  Widget _buildQuestion(String question) => Text(
        question,
        style: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      );

  Widget _buildOptions(List<String> options, Rxn<int> selectedIndex, void Function(int) onTap) {
    return Obx(() => Wrap(
          spacing: 10,
          runSpacing: 12,
          children: options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex.value == idx;

            return CustomPillCheckbox(
              text: option,
              isSelected: isSelected,
              onChanged: (_) => onTap(idx),
              selectedOpacity: 0.8,
              textStyle: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            );
          }).toList(),
        ));
  }

  Widget _buildQuestionSection(String question, List<String> options, Rxn<int> selectedIndex, void Function(int) onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3A59).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestion(question),
          const SizedBox(height: 12),
          _buildOptions(options, selectedIndex, onTap),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HabitController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
          onPressed: () => Get.back(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomProgressBar(value: 0.84),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about your habits',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Share as much about your habits as you're comfortable with.",
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            _buildQuestionSection('What is your communication style?', controller.communicationStyles, controller.selectedCommunicationStyle, controller.toggleCommunicationStyle),
            _buildQuestionSection('Do you exercise regularly?', controller.exerciseFrequencies, controller.selectedExerciseFrequency, controller.toggleExerciseFrequency),
            _buildQuestionSection('What do you usually eat?', controller.foodPreferences, controller.selectedFoodPreference, controller.toggleFoodPreference),
            _buildQuestionSection('How often do you use social media?', controller.socialMediaUsage, controller.selectedSocialMediaUsage, controller.toggleSocialMediaUsage),
            _buildQuestionSection('Do you smoke or drink?', controller.smokingDrinking, controller.selectedSmokingDrinking, controller.toggleSmokingDrinking),
            _buildQuestionSection('Do you enjoy trying new experiences?', controller.tryNewExperiences, controller.selectedTryNewExperiences, controller.toggleTryNewExperiences),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => CustomGradientButton(
              text: 'Next',
              enabled: controller.isCompleted,
              onPressed: controller.isCompleted ? () => Get.toNamed(AppRoutes.likeToDoView) : null,
            )),
      ),
    );
  }
}
