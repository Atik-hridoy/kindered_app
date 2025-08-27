import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/height_weight_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/input_box.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class HeightWeightView extends GetView<HeightWeightController> {
  final HeightWeightController controller = Get.put(HeightWeightController());

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
              value: 0.8, // 80% progress
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 80.0), // Add bottom padding for the button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'What is your height and weight?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "We are glad that you're here, please pick the gender which describes you the best",                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16.0,
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Height Input
                Text(
                  'Height (cm)',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                CustomInputField(
                  controller: controller.heightController,
                  hintText: 'Enter your height',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => controller.validateInputs(),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                // Weight Input
                Text(
                  'Weight (kg)',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                CustomInputField(
                  controller: controller.weightController,
                  hintText: 'Enter your weight',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => controller.validateInputs(),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 40), // Extra space before the button
              ],
            ),
          ),
          
          // Fixed bottom button
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: Obx(() => Container(
              width: 335,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomGradientButton(
                text: 'Continue',
                onPressed: controller.areInputsValid ? () {
                  // Handle continue button press
                  // You can add navigation logic here
                } : null,
                enabled: controller.areInputsValid,
              ),
            )),
          ),
        ],
      ),
    );
  }
}
