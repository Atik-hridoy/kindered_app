import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/accounts_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/input_box.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class HeightWeightView extends GetView<AccountsController> {
  HeightWeightView({super.key});

  @override
  final AccountsController controller = Get.find<AccountsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is your height and weight?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Please enter your height and weight",
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            // Height Input
            Text('Height', style: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            CustomInputField(
              controller: controller.heightController,
              hintText: 'Enter your height',
              onChanged: (_) => controller.validateHeightWeightInputs(),
            ),
            const SizedBox(height: 20),
            // Weight Input
            Text('Weight', style: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            CustomInputField(
              controller: controller.weightController,
              hintText: 'Enter your weight',
              onChanged: (_) => controller.validateHeightWeightInputs(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: CustomGradientButton(
            text: 'Next',
            enabled: controller.areHeightWeightValid,
            onPressed: controller.areHeightWeightValid
                ? () => Get.toNamed(AppRoutes.educationView)
                : null,
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
          child: CustomProgressBar(value: 0.42),
        ),
      ),
    );
  }
}
