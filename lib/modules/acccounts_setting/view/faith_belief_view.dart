import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/faith_belief_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';

class FaithBeliefView extends StatefulWidget {
  const FaithBeliefView({Key? key}) : super(key: key);

  @override
  State<FaithBeliefView> createState() => _FaithBeliefViewState();
}

class _FaithBeliefViewState extends State<FaithBeliefView> {
  final FaithBeliefController controller = Get.put(FaithBeliefController());

  void _onNextPressed() {
    // TODO: Add navigation to next screen
    // Get.to(() => NextScreen());
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
                  value: 1.0, // 100% progress
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 308,
                    height: 56,
                    child: Text(
                      'Which faith or belief system do you identify with?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This information will show on your profile helps you to find people and people find you.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 12.5,
                      color: Colors.white70,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'What is your religion?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildReligionOptions(),
                  const SizedBox(height: 16),
                  Text(
                    'What is your zodiac sign?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildZodiacOptions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 50.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _buildBottomButton(),
      ),
    );
  }

  Widget _buildBottomButton() {
    return CustomGradientButton(
      text: 'Next',
      onPressed: _onNextPressed,
      width: double.infinity,
      height: 48,
      borderRadius: 12,
      gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
      textStyle: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildReligionOptions() {
    return GetBuilder<FaithBeliefController>(
      builder: (controller) {
        return Wrap(
          spacing: 8,
          runSpacing: 12,
          children: controller.religions.asMap().entries.map((entry) {
            int index = entry.key;
            String religion = entry.value;
            final isSelected = controller.selectedReligion.value == index;
            
            return _buildOptionButton(
              text: religion,
              isSelected: isSelected,
              onTap: () => controller.toggleReligion(index),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildZodiacOptions() {
    return GetBuilder<FaithBeliefController>(
      builder: (controller) {
        return Wrap(
          spacing: 8,
          runSpacing: 12,
          children: controller.zodiacSigns.asMap().entries.map((entry) {
            int index = entry.key;
            String zodiac = entry.value;
            final isSelected = controller.selectedZodiac.value == index;
            
            return _buildOptionButton(
              text: zodiac,
              isSelected: isSelected,
              onTap: () => controller.toggleZodiac(index),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Reduced from 25 to 12 for less rounded corners
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF2E3A59) // Match background color when selected
              : const Color(0xFFD4A373).withValues(alpha: 0.5),
            width: isSelected ? 1.2 : 0.8,
          ),
          color: isSelected 
            ? const Color(0xFFD4A373).withValues(alpha: 0.8)
            : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2E3A59) : const Color(0xFFD4A373),
                  width: 1.0,
                ),
                color: Colors.transparent,
              ),
              child: isSelected 
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2E3A59), // Changed to red
                      ),
                    ),
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }
}