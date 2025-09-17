import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/like_to_do_view_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';
import '../widget/custom_pill_checkbox.dart';

class LikeToDoView extends GetView<LikeToDoController> {
  const LikeToDoView({super.key});

  Widget _buildQuestionSection(String question, String category) {
    final controller = Get.find<LikeToDoController>();
    return Obx(() => Container(
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
              Text(
                question,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 12,
                children: controller.options[category]!.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final option = entry.value;
                  final isSelected = controller.selectedOptions[category]!.contains(idx);

                  return CustomPillCheckbox(
                    text: option,
                    isSelected: isSelected,
                    onChanged: (_) => controller.toggleOption(category, idx),
                    selectedOpacity: 0.8,
                    textStyle: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LikeToDoController());

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
            child: CustomProgressBar(value: 0.924),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us what you really like to do!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose the activities that interest you the most to help match with like-minded people.",
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _buildQuestionSection('Creativity', 'creativity'),
            _buildQuestionSection('Activities', 'activities'),
            _buildQuestionSection('Sports and Fitness', 'sportsFitness'),
            _buildQuestionSection('TV and Movies', 'tvMovies'),
            _buildQuestionSection('Free Time', 'freeTime'),
            _buildQuestionSection('Music', 'music'),
            _buildQuestionSection('Wellness and Lifestyle', 'wellnessLifestyle'),
            _buildQuestionSection('Books and Content', 'booksContent'),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => CustomGradientButton(
              text: 'Next',
              enabled: controller.isCompleted,
              onPressed: controller.isCompleted ? () => Get.toNamed(AppRoutes.visualStoryView) : null,
            )),
      ),
    );
  }
}
