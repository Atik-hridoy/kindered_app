import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/habit_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';
import '../widget/custom_pill_checkbox.dart';

class HabitView extends StatefulWidget {
  const HabitView({Key? key}) : super(key: key);

  @override
  State<HabitView> createState() => _HabitViewState();
}

class _HabitViewState extends State<HabitView> {
  final ScrollController _scrollController = ScrollController();
  
  // State variables
  final RxnInt _selectedCommunicationStyle = RxnInt();
  final RxnInt _selectedExerciseFrequency = RxnInt();
  final RxnInt _selectedFoodPreference = RxnInt();
  final RxnInt _selectedWeekendActivity = RxnInt();
  final RxnInt _selectedTravelPreference = RxnInt();
  final RxnInt _selectedTryNewExperiences = RxnInt();
  
  // Check if all questions are answered
  bool get _isCompleted => 
      _selectedCommunicationStyle.value != null &&
      _selectedExerciseFrequency.value != null &&
      _selectedFoodPreference.value != null &&
      _selectedWeekendActivity.value != null &&
      _selectedTravelPreference.value != null &&
      _selectedTryNewExperiences.value != null;

  // View-specific data
  final List<String> communicationStyles = [
    'Good texter',
    'Bad texter',
    'Video Chatter',
    'Phone caller'
  ];

  final List<String> exerciseFrequencies = [
    'Yes',
    'Several times a week',
    'Rarely',
    'Never'
  ];

  final List<String> foodPreferences = [
    'Healthy and balanced',
    'Whatever I feel like',
    'Specific diet',
    "I don't eat"
  ];

  final List<String> weekendActivities = [
    'Yes',
    'Occafacially',
    'Frequently',
    'Rarely',
    'Never'
  ];

  final List<String> travelPreferences = [
    'Yes',
    'Occasionally',
    'No',
  ];

  final List<String> tryNewExperiences = [
    'Absolutely',
    'Sometimes',
    'Rarely',
    'Never'
  ];


  void _onNextPressed() {
    Get.toNamed(AppRoutes.likeToDoView);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildOptions(List<String> options, String? selectedOption, void Function(String) onTap) {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: options.map((option) {
        return CustomPillCheckbox(
          text: option,
          isSelected: selectedOption == option,
          onChanged: (_) => onTap(option),
          selectedOpacity: 0.8,
          textStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionSection(String question, List<String> options, RxnInt selectedOption, void Function(int) onOptionSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E3A59).withValues(alpha: 0.3),
          width: 1,
        ),
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
          _buildOptions(options, selectedOption.value != null ? options[selectedOption.value!] : null, (option) {
            onOptionSelected(options.indexOf(option));
          }),
        ],
      ),
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
      body: GetBuilder<HabitController>(
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
                          'Tell us about habit?',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22.0, // Increased from 17.0
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Share as much about your habit as you’re comfortable with the most.",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15.0, // Increased from 12.5
                          color: Colors.white70,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 15), // Increased from 20
                      
                      
                      _buildQuestionSection(
                        'What is your communication style?',
                        communicationStyles,
                        _selectedCommunicationStyle,
                        (index) => setState(() => _selectedCommunicationStyle.value = _selectedCommunicationStyle.value == index ? null : index),
                      ),
                      
                      _buildQuestionSection(
                        'Do you exercise regularly?',
                        exerciseFrequencies,
                        _selectedExerciseFrequency,
                        (index) => setState(() => _selectedExerciseFrequency.value = _selectedExerciseFrequency.value == index ? null : index),
                      ),

                      _buildQuestionSection(
                        'What do you usually eat?',
                        foodPreferences,
                        _selectedFoodPreference,
                        (index) => setState(() => _selectedFoodPreference.value = _selectedFoodPreference.value == index ? null : index),
                      ),
                      
                      _buildQuestionSection(
                        'How often do you use social media?',
                        weekendActivities,
                        _selectedWeekendActivity,
                        (index) => setState(() => _selectedWeekendActivity.value = _selectedWeekendActivity.value == index ? null : index),
                      ),
                      
                      _buildQuestionSection(
                        'Do you smoke or drink?',
                        travelPreferences,
                        _selectedTravelPreference,
                        (index) => setState(() => _selectedTravelPreference.value = _selectedTravelPreference.value == index ? null : index),
                      ),

                      _buildQuestionSection(
                        'Do you enjoy trying new experiences?',
                        tryNewExperiences,
                        _selectedTryNewExperiences,
                        (index) => setState(() => _selectedTryNewExperiences.value = _selectedTryNewExperiences.value == index ? null : index),
                      ),

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
        child: CustomGradientButton(
          text: 'Next',
          onPressed: _isCompleted ? _onNextPressed : null,
          width: double.infinity,
          height: 48,
          borderRadius: 12,
          gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
