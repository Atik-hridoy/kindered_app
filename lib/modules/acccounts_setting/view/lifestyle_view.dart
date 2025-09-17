import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/lifestyle_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';
import '../widget/custom_pill_checkbox.dart';

class LifestyleView extends GetView<LifestyleController> {
  const LifestyleView({super.key});

  Widget _buildQuestion(String text) {
    return Text(
      text,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      ),
    );
  }

  Widget _buildOptions(List<String> options, Rxn<int> selectedIndex, Function(int) onTap) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 10,
          children: options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex.value == idx;
            return CustomPillCheckbox(
              text: option,
              isSelected: isSelected,
              onChanged: (_) => onTap(idx),
              selectedColor: const Color(0xFF2E3A59),
              unselectedColor: const Color(0xFFD4A373),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white,
              ),
              selectedOpacity: 0.8,
            );
          }).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LifestyleController());

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
            child: CustomProgressBar(value: 0.756),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about your lifestyle?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Share as much about your lifestyle as you're comfortable with.",
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            _buildQuestion('Are you more of a morning or night person?'),
            const SizedBox(height: 10),
            _buildOptions(controller.dayPreferences, controller.selectedDayPreference, controller.toggleDayPreference),
            const SizedBox(height: 24),

            _buildQuestion('How do you accept love?'),
            const SizedBox(height: 10),
            _buildOptions(controller.loveLanguages, controller.selectedLoveLanguage, controller.toggleLoveLanguage),
            const SizedBox(height: 24),

            _buildQuestion('How do you prefer to spend your weekends?'),
            const SizedBox(height: 10),
            _buildOptions(controller.weekendActivities, controller.selectedWeekendActivity, controller.toggleWeekendActivity),
            const SizedBox(height: 24),

            _buildQuestion('Do you enjoy traveling?'),
            const SizedBox(height: 10),
            _buildOptions(controller.travelPreferences, controller.selectedTravelPreference, controller.toggleTravelPreference),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => CustomGradientButton(
              text: 'Next',
              enabled: controller.isCompleted,
              onPressed: controller.isCompleted
                  ? () => Get.toNamed(AppRoutes.habitView)
                  : null,
            )),
      ),
    );
  }
}
