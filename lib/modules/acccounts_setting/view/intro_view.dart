import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/intro_view_controller.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/input_box.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class IntroView extends GetView<IntroViewController> {
  final _formKey = GlobalKey<FormState>();

  IntroView({super.key}) {
    Get.put(IntroViewController());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 24, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameField(),
                          const SizedBox(height: 16),
                          _buildLastNameField(),
                          const SizedBox(height: 16),
                          _buildAgeField(),
                          const SizedBox(height: 24),
                          
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: _buildSaveButton()),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
          onPressed: () => Get.back(),
        ),
        toolbarHeight: 80,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomProgressBar(value: 0.2),
              
              const SizedBox(height: 20),
              Text(
                AppStrings.letsStartWithIntro,
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
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.yourFirstName,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          controller: TextEditingController(text: controller.firstName.value),
          hintText: '',
          borderColor: const Color(0xFFD4A373),
          borderRadius: 12,
          onChanged: (value) => controller.firstName.value = value,
          textStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Name',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          controller: TextEditingController(text: controller.lastName.value),
          hintText: '',
          borderColor: const Color(0xFFD4A373),
          borderRadius: 12,
          onChanged: (value) => controller.lastName.value = value,
          textStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.yourAge,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          controller: TextEditingController(text: controller.age.value),
          hintText: '',
          keyboardType: TextInputType.number,
          borderColor: const Color(0xFFD4A373),
          borderRadius: 12,
          onChanged: (value) => controller.age.value = value,
          textStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }



  Widget _buildSaveButton() {
    return CustomGradientButton(
      text: AppStrings.next,
      width: 335,
      height: 48,
      borderRadius: 12,
      gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
      textStyle: GoogleFonts.inter(
        color: const Color(0xFF1A1A1A),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          Get.offAllNamed(AppRoutes.gender);
        }
      },
    );
  }
}
