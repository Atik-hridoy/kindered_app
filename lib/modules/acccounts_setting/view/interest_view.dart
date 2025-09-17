import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/accounts_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox_muilti.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';

class InterestView extends GetView<AccountsController> {
  InterestView({super.key});

  @override
  final AccountsController controller = Get.find<AccountsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amazing, what brings you here?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Choose a mode and we\'ll find the best partner for you. '
                'Do you prefer a long-term partner, a casual connection, or friendship?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14.0,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24.0),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.interestOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                itemBuilder: (context, index) {
                  final option = controller.interestOptions[index];
                  return Obx(
                    () => CustomCheckboxMulty(
                      label: '${option['title']!}\n${option['description']!}',
                      isSelected: controller.selectedInterestIndices.contains(index),
                      onTap: () => controller.toggleInterestSelection(index),
                      selectedColor: const Color(0xFFD4A574).withOpacity(0.8),
                      unselectedColor: Colors.transparent,
                      textColor: const Color(0xFFD4A373),
                      height: 70.0,
                      titleFontSize: 14.0,
                      descriptionFontSize: 12.0,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Obx(
            () => CustomGradientButton(
              onPressed: controller.selectedInterestIndices.isNotEmpty
                  ? () {
                      final error = controller.validateInterestSelections();
                      if (error != null) {
                        Get.snackbar(
                          'Error',
                          error,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      Get.toNamed(AppRoutes.heightWeight);
                    }
                  : null,
              text: 'Next',
              textStyle: GoogleFonts.inter(
                color: const Color(0xFF2C3E50),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              height: 56,
              borderRadius: 12,
              gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        preferredSize: Size.fromHeight(35.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomProgressBar(value: 0.336),
        ),
      ),
    );
  }
}
