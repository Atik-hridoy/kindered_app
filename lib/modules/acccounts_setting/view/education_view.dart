import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/accounts_controller.dart';
//import 'package:kindered_app/modules/acccounts_setting/controller/education_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/input_box.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class EducationView extends GetView<AccountsController> {
  const EducationView({super.key});

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
            child: const CustomProgressBar(value: 0.504),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'What is your Education Level and Job Status?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please share your education level, job status, or annual income.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Education Level Dropdown
            Text('Education Level', style: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF1E2A3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF3A4B5C), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.educationController.text.isEmpty ? null : controller.validEducationLevels.contains(controller.educationController.text) ? controller.educationController.text : null,
                  hint: Text('Select Education Level', 
                    style: GoogleFonts.playfairDisplay(
                      color: Color(0xFF5A6B7D),
                      fontSize: 16,
                    ),
                  ),
                  dropdownColor: Color(0xFF1E2A3A),
                  items: controller.validEducationLevels.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.educationController.text = newValue;
                      controller.validateEducationInputs();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Job Status Input
            Text('Job Status', style: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomInputField(
              controller: controller.jobStatusController,
              hintText: 'e.g., Employed, Student, Self-employed',
              onChanged: (_) => controller.validateEducationInputs(),
            ),
            const SizedBox(height: 20),
            
            // Annual Income Input
            Text('Annual Income', style: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            CustomInputField(
              controller: controller.incomeController,
              hintText: 'e.g., 50000 or 50,000',
              onChanged: (_) => controller.validateEducationInputs(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomGradientButton(
          text: 'Next',
          enabled: controller.isEducationButtonEnabled.value,
          onPressed: controller.isEducationButtonEnabled.value
              ? () => Get.toNamed(AppRoutes.inspireView)
              : null,
        ),
      )),
    );
  }
}
