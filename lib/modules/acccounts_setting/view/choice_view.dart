import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/accounts_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class ChoiceView extends GetView<AccountsController> {
  final List<String> genderOptions = [
    'Men',
    'Women',
    'Trans woman',
    'Trans man',
    'Nonbinary',
  ];

  ChoiceView({super.key});

  @override
  final AccountsController controller = Get.find<AccountsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
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

              /// 🔸 Gender Selection Checkboxes
              ...genderOptions.map(
                (gender) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Obx(
                    () => CustomCheckbox(
                      label: gender,
                      isSelected: controller.isGenderSelectedInList(gender),
                      onTap: () => controller.toggleGender(gender),
                      titleFontSize: 12.0,
                      descriptionFontSize: 10.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70.0),

              /// 🔸 Continue Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomGradientButton(
                    text: "Next",
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () {
                      final error = controller.validateGenderSelections();
                      if (error != null) {
                        Get.snackbar('Error', error,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(35.0),
        child: Padding(
          padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
          child: CustomProgressBar(value: 0.252),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 1.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => Get.offAllNamed(AppRoutes.gender),
        ),
      ),
    );
  }
}
