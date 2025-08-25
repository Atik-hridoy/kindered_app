import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/choice_view_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox.dart';

class ChoiceView extends GetView<ChoiceViewController> {
  final List<String> genderOptions = [
    'Men',
    'Women',
    'Non-binary',
    'Transgender',
    'Prefer not to say',
  ];

  final RxList<String> selectedGenders = <String>[].obs;

  @override
  final ChoiceViewController controller = Get.put(ChoiceViewController());

  ChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(35.0),
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: CustomProgressBar(
              value: 0.67, // 20% progress
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 1.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Get.offAllNamed(AppRoutes.gender);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32.0),
              Text(
                'Whom would you like to meet?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Please pick the gender with whom you would like to meet',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16.0,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48.0),
              Text(
                'Which gender you like to meet?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              // Gender Selection Checkboxes
              ...genderOptions.map((gender) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Obx(() => CustomCheckbox(
                  label: gender,
                  isSelected: selectedGenders.contains(gender),
                  onTap: () {
                    if (selectedGenders.contains(gender)) {
                      selectedGenders.remove(gender);
                    } else {
                      selectedGenders.add(gender);
                    }
                  },
                )),
              )),
              const SizedBox(height: 70.0), // Increased space above button
              // Add the Custom Gradient Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Match horizontal padding of checkboxes
                child: SizedBox(
                  width: double.infinity, // Make button take full width
                  child: CustomGradientButton(
                    text: "Next",
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () {
                      // Navigate to interest selection screen
                      Get.toNamed(AppRoutes.interest);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
