import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/view/habit_view.dart';
import '../controller/lifestyle_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';
import '../widget/custom_pill_checkbox.dart';

class LifestyleView extends StatefulWidget {
  const LifestyleView({Key? key}) : super(key: key);

  @override
  State<LifestyleView> createState() => _LifestyleViewState();
}

class _LifestyleViewState extends State<LifestyleView> {
  final LifestyleController controller = Get.put(LifestyleController());
  final ScrollController _scrollController = ScrollController();

  void _onNextPressed() {
    if (controller.isCompleted) {
      Get.toNamed(AppRoutes.habitView);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildQuestion(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        question,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18.0, // Increased from 15.0
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildOptions(List<String> options, int? selectedIndex, Function(int) onTap) {
    return Wrap(
      spacing: 12, // Increased from 10
      runSpacing: 16, // Increased from 14
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedIndex == index;
        
        return _buildOptionButton(
          text: option,
          isSelected: isSelected,
          onChanged: (value) => onTap(index),
        );
      }).toList(),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return CustomPillCheckbox(
      text: text,
      isSelected: isSelected,
      onChanged: onChanged,
      selectedColor: const Color(0xFF2E3A59),
      unselectedColor: const Color(0xFFD4A373),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Increased padding
      textStyle: GoogleFonts.playfairDisplay(
        color: Colors.white,
        fontSize: 16, // Increased from 14
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      // Increase the opacity of the selected state
      selectedOpacity: 0.8, // Increased from default 0.2 to make it more visible
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            onPressed: () => Get.back(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomProgressBar(
                  value: 1.0,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: GetBuilder<LifestyleController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 308,
                        child: Text(
                          'Tell us about your lifestyle?',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22.0, // Increased from 17.0
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Share as much about your lifestyle as you're comfortable with the most.",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15.0, // Increased from 12.5
                          color: Colors.white70,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24), // Increased from 20
                      
                      // Question 1: Morning/Night Person
                      _buildQuestion('Are you more of a morning or night person?'),
                      const SizedBox(height: 10),
                      Obx(() => _buildOptions(
                        controller.dayPreferences,
                        controller.selectedDayPreference.value,
                        controller.toggleDayPreference,
                      )),
                      const SizedBox(height: 24), // Increased from 20
                      
                      // Question 2: Love Language
                      _buildQuestion('How do you accept love?'),
                      const SizedBox(height: 10),
                      Obx(() => _buildOptions(
                        controller.loveLanguages,
                        controller.selectedLoveLanguage.value,
                        controller.toggleLoveLanguage,
                      )),
                      const SizedBox(height: 24), // Increased from 20
                      
                      // Question 3: Weekend Preferences
                      _buildQuestion('How do you prefer to spend your weekends?'),
                      const SizedBox(height: 10),
                      Obx(() => _buildOptions(
                        controller.weekendActivities,
                        controller.selectedWeekendActivity.value,
                        controller.toggleWeekendActivity,
                      )),
                      const SizedBox(height: 24), // Increased from 20
                      
                      // Question 4: Travel Preference
                      _buildQuestion('Do you enjoy traveling?'),
                      const SizedBox(height: 10),
                      Obx(() => _buildOptions(
                        controller.travelPreferences,
                        controller.selectedTravelPreference.value,
                        controller.toggleTravelPreference,
                      )),
                      const SizedBox(height: 24), // Increased from 20
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 50.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Obx(() => CustomGradientButton(
          text: 'Next',
          onPressed: controller.isCompleted ? _onNextPressed : null,
          width: double.infinity,
          height: 48,
          borderRadius: 12,
          gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        )),
      ),
    );
  }
}
