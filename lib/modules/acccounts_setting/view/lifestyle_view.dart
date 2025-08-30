import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
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

  Widget _buildQuestion(String question, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.025), // 10.0 on 400 width screen
      child: Text(
        question,
        style: GoogleFonts.playfairDisplay(
          fontSize: screenWidth * 0.045, // ~18 on 400 width screen
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildOptions(List<String> options, int? selectedIndex, Function(int) onTap, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Wrap(
      spacing: screenWidth * 0.02, // Reduced from 0.03 (8 on 400 width screen)
      runSpacing: screenWidth * 0.025, // Reduced from 0.04 (10 on 400 width screen)
      alignment: WrapAlignment.start,
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedIndex == index;
        
        return _buildOptionButton(
          text: option,
          isSelected: isSelected,
          onChanged: (value) => onTap(index),
          context: context,
        );
      }).toList(),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return CustomPillCheckbox(
      text: text,
      isSelected: isSelected,
      onChanged: onChanged,
      selectedColor: const Color(0xFF2E3A59),
      unselectedColor: const Color(0xFFD4A373),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035, // Reduced from 0.05 (14 on 400 width screen)
        vertical: screenWidth * 0.02, // Reduced from 0.035 (8 on 400 width screen)
      ),
      textStyle: GoogleFonts.playfairDisplay(
        color: Colors.white,
        fontSize: screenWidth * 0.035, // Reduced from 0.04 (14 on 400 width screen)
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      selectedOpacity: 0.8,
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
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.width * 0.05, // 20 on 400 width screen
            left: MediaQuery.of(context).size.width * 0.05,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            onPressed: () => Get.back(),
            iconSize: MediaQuery.of(context).size.width * 0.07, // 28 on 400 width screen
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.06), // ~45 on 800 height screen
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.0125), // 10 on 800 height screen
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05), // 20 on 400 width screen
                child: const CustomProgressBar(
                  value: 1.0,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.0125), // 10 on 800 height screen
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
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05, // 20 on 400 width screen
                    right: MediaQuery.of(context).size.width * 0.05,
                    top: MediaQuery.of(context).size.height * 0.01, // 8 on 800 height screen
                    bottom: MediaQuery.of(context).size.height * 0.025, // 20 on 800 height screen
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                          'Tell us about your lifestyle?',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: MediaQuery.of(context).size.width * 0.055, // ~22 on 400 width screen
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01), // 8 on 800 height screen
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
                        child: Text(
                          "Share as much about your lifestyle as you're comfortable with the most.",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: MediaQuery.of(context).size.width * 0.0375, // ~15 on 400 width screen
                            color: Colors.white70,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03), // 24 on 800 height screen
                      
                      // Question 1: Morning/Night Person
                      _buildQuestion('Are you more of a morning or night person?', context),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.0125), // 10 on 800 height screen
                      Obx(() => _buildOptions(
                        controller.dayPreferences,
                        controller.selectedDayPreference.value,
                        controller.toggleDayPreference,
                        context,
                      )),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03), // 24 on 800 height screen
                      
                      // Question 2: Love Language
                      _buildQuestion('How do you accept love?', context),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.0125), // 10 on 800 height screen
                      Obx(() => _buildOptions(
                        controller.loveLanguages,
                        controller.selectedLoveLanguage.value,
                        controller.toggleLoveLanguage,
                        context,
                      )),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03), // 24 on 800 height screen
                      
                      // Question 3: Weekend Preferences
                      _buildQuestion('How do you prefer to spend your weekends?', context),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.0125), // 10 on 800 height screen
                      Obx(() => _buildOptions(
                        controller.weekendActivities,
                        controller.selectedWeekendActivity.value,
                        controller.toggleWeekendActivity,
                        context,
                      )),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03), // 24 on 800 height screen
                      
                      // Question 4: Travel Preference
                      _buildQuestion('Do you enjoy traveling?', context),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.0125), // 10 on 800 height screen
                      Obx(() => _buildOptions(
                        controller.travelPreferences,
                        controller.selectedTravelPreference.value,
                        controller.toggleTravelPreference,
                        context,
                      )),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03), // 24 on 800 height screen
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05, // 20 on 400 width screen
          right: MediaQuery.of(context).size.width * 0.05,
          top: MediaQuery.of(context).size.height * 0.01, // 8 on 800 height screen
          bottom: MediaQuery.of(context).size.height * 0.0625, // 50 on 800 height screen
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Obx(() => CustomGradientButton(
          text: 'Next',
          onPressed: controller.isCompleted ? _onNextPressed : null,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.06, // 48 on 800 height screen
          borderRadius: MediaQuery.of(context).size.width * 0.03, // 12 on 400 width screen
          gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: MediaQuery.of(context).size.width * 0.04, // 16 on 400 width screen
            fontWeight: FontWeight.w600,
          ),
        )),
      ),
    );
  }
}
