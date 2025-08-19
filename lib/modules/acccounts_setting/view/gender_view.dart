import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/gender_view_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class GenderView extends GetView<GenderViewController> {
  final _formKey = GlobalKey<FormState>();
  final GenderViewController controller = Get.put(GenderViewController());

  GenderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomProgressBar(value: 0.5),
                const SizedBox(height: 20),
                Text(
                  AppStrings.whatsYourGender,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGenderSelection(),
              const SizedBox(height: 40),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectYourGender,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        _buildGenderCheckbox(AppStrings.male, 'male'),
        const SizedBox(height: 12),
        _buildGenderCheckbox(AppStrings.female, 'female'),
        const SizedBox(height: 12),
        _buildGenderCheckbox(AppStrings.other, 'other'),
      ],
    );
  }

  Widget _buildGenderCheckbox(String label, String value) {
    return Obx(
      () => CustomCheckbox(
        value: controller.selectedGender.value == value,
        onChanged: (_) => controller.selectedGender.value = value,
        label: label,
        labelStyle: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return CustomGradientButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          controller.updateProfile();
        }
      },
      text: AppStrings.continueText,
      textStyle: GoogleFonts.playfairDisplay(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      height: 56,
      borderRadius: 12,
    );
  }
}
