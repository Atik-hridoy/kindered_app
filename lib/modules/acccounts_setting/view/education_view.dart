import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/education_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/input_box.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class EducationView extends GetView<EducationController> {
  final EducationController controller = Get.put(EducationController());

  @override
  Widget build(BuildContext context) {
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(35.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: CustomProgressBar(
              value: 1.0, // 100% progress
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'What is your Education Level And job status?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Please share with us your education level or what you do for living",
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Education Level Input
            Text(
              'Education Level',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: controller.educationController,
              hintText: 'e.g., High School, Bachelor\'s Degree, etc.',
              onChanged: (_) => controller.validateInputs(),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            
            // Job Status Input
            Text(
              'Job Status',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: controller.jobStatusController,
              hintText: 'e.g., Employed, Student, Self-employed, etc.',
              onChanged: (_) => controller.validateInputs(),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            
            // Income Input
            Text(
              'Annual Income',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: controller.incomeController,
              hintText: r'e.g., $50,000',
              keyboardType: TextInputType.number,
              onChanged: (_) => controller.validateInputs(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 50.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomGradientButton(
          text: 'Next',
          onPressed: controller.isButtonEnabled.value ? () {
            // Navigate to inspire view
            Get.toNamed(AppRoutes.inspireView);
          } : null,
          enabled: controller.isButtonEnabled.value,
        ),
      )),
    );
  }
}
