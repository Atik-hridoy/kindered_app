import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/accounts_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';
import 'package:kindered_app/config/app_routes.dart';

class GenderView extends GetView<AccountsController> {
  final _formKey = GlobalKey<FormState>();

  GenderView({super.key});

  @override
  final AccountsController controller = Get.find<AccountsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Form(
                key: _formKey,
                child: _buildGenderSelection(),
              ),
            ),
          ),
          _buildContinueSection(),
        ],
      ),
    );
  }

  /// 🔸 AppBar with title and description
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 1.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => Get.offAllNamed(AppRoutes.intro),
        ),
      ),
      toolbarHeight: 80,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0).copyWith(top: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomProgressBar(value: 0.168),
              const SizedBox(height: 16),
              Text(
                AppStrings.thatsGreatAlex,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
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
    );
  }

  /// 🔸 Gender Selection List
  Widget _buildGenderSelection() {
    final genders = ['Woman', 'Man', 'Nonbinary', "I'm Trans"];
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
        ...genders.map((gender) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Obx(
                () => CustomCheckbox(
                  label: gender,
                  isSelected: controller.selectedGender.value == gender,
                  onTap: () => controller.selectGender(gender),
                  titleFontSize: 12.0,
                  descriptionFontSize: 12.0,
                ),
              ),
            )),
      ],
    );
  }

  /// 🔸 Continue Button Section
  Widget _buildContinueSection() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 50.0, top: 20.0),
      child: Obx(() {
        return CustomGradientButton(
          onPressed: () {
            final error = controller.validateGender();
            if (error != null) {
              Get.snackbar('Error', error,
                  snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
              return;
            }
            controller.updateProfile();
            Get.offAllNamed(AppRoutes.choice);
          },
          text: controller.isLoading.value ? 'Loading...' : 'Next',
          textStyle: GoogleFonts.inter(
            color: const Color(0xFF2C3E50),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          height: 56,
          borderRadius: 12,
          gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
        );
      }),
    );
  }
}
