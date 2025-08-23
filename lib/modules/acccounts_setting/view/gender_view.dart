import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/gender_view_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';
import 'package:kindered_app/config/app_routes.dart';

class GenderView extends GetView<GenderViewController> {
  final _formKey = GlobalKey<FormState>();
  @override
  final GenderViewController controller = Get.put(GenderViewController());

  GenderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 1.0), // Add top padding to move the arrow down
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Get.offAllNamed(AppRoutes.intro);
            },
          ),
        ),
        toolbarHeight: 80,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140), // Increased height
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0, top: 40.0), // Added top padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomProgressBar(value: 0.4),
                const SizedBox(height: 16),
                Text(
                  AppStrings.thatsGreatAlex,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20), // Increased from 1 to 20
                Text(
                  "We are glad that you're here, please pick the gender which describe you the best",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20), // Add space at the top of the body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Form(
                key: _formKey,
                child: _buildGenderSelection(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 50.0, top: 20.0),
            child: _buildContinueButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.whichGenderDescribeYouTheBest,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        _buildGenderCheckbox('Woman'),
        const SizedBox(height: 12),
        _buildGenderCheckbox('Man'),
        const SizedBox(height: 12),
        _buildGenderCheckbox('Nonbinary'),
        const SizedBox(height: 12),
        _buildGenderCheckbox('I\'m Trans'),
      ],
    );
  }

  Widget _buildGenderCheckbox(String label) {
    return Obx(
      () => CustomCheckbox(
        label: label,
        isSelected: controller.selectedGender.value == label,
        onTap: () => controller.selectedGender.value = label,
      ),
    );
  }

  Widget _buildContinueButton() {
    return CustomGradientButton(
      onPressed: () {
        Get.offAllNamed(AppRoutes.choice);
      },
      text: 'Next',
      textStyle: GoogleFonts.inter(
        color: const Color(0xFF2C3E50),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      height: 56,
      borderRadius: 12,
      gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
    );
  }
}
