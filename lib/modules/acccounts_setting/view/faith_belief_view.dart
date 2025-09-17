import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/accounts_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';

class FaithBeliefView extends GetView<AccountsController> {
  const FaithBeliefView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            onPressed: () => Get.back(),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomProgressBar(value: 0.672),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which faith or belief system do you identify with?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This information will show on your profile helps you find people and vice versa.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 12.5,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'What is your religion?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: controller.religions.asMap().entries.map((entry) {
                    int index = entry.key;
                    String text = entry.value;
                    final isSelected = controller.selectedReligionIndex.value == index;

                    return _buildOptionButton(text, isSelected, () => controller.toggleReligion(index));
                  }).toList(),
                )),
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
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: controller.zodiacSigns.asMap().entries.map((entry) {
                    int index = entry.key;
                    String text = entry.value;
                    final isSelected = controller.selectedZodiacIndex.value == index;

                    return _buildOptionButton(text, isSelected, () => controller.toggleZodiac(index));
                  }).toList(),
                )),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: CustomGradientButton(
              text: 'Next',
              enabled: controller.isFaithCompleted,
              onPressed: controller.isFaithCompleted
                  ? () => Get.toNamed(AppRoutes.lifestyleView)
                  : null,
            ),
          )),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E3A59)
                : const Color(0xFFD4A373).withOpacity(0.5),
            width: isSelected ? 1.2 : 0.8,
          ),
          color: isSelected
              ? const Color(0xFFD4A373).withOpacity(0.8)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2E3A59) : const Color(0xFFD4A373),
                  width: 1.0,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2E3A59),
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
