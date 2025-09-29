import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:kindered_app/modules/auth/controllers/login_email_controller.dart';

import 'package:kindered_app/modules/auth/widget_button.dart';

class LoginWithEmail extends GetView<LoginEmailController> {
  const LoginWithEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: true,
      body: _buildBody(context, isSmallScreen),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isSmallScreen) {
    return Stack(
      children: [
        Container(color: const Color(0xFF2E3A59)),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top + 24),
                        _buildTitle(),
                        const SizedBox(height: 24),
                        _buildEmailInputLabel(),
                        _buildEmailInput(),
                        const Spacer(),
                        _buildPrivacyText(),
                        _buildNextButton(isSmallScreen),
                        _buildTermsAndPrivacyText(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Obx(() => controller.isLoading.value
            ? Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A373)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Sending OTP...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      AppStrings.verifyYourEmail,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlayfairDisplay',
      ),
    );
  }

  Widget _buildEmailInputLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        AppStrings.email,
        style: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFFB0AEAC),
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4A373), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A373).withValues(alpha: 0.5),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => TextField(
            controller: controller.emailController,
            enabled: !controller.isLoading.value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: AppStrings.email,
              hintStyle: const TextStyle(color: Color(0xFFB0B5C0), fontSize: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            keyboardType: TextInputType.emailAddress,
          )),
    );
  }

  Widget _buildPrivacyText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE98675),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE98675).withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const Expanded(
            child: Text(
              'We never share your personal information with anyone',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isSmallScreen) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          minWidth: isSmallScreen ? 280 : 335,
        ),
        child: Obx(() => AuthCtaButton(
              text: controller.isLoading.value ? 'Logging in...' : AppStrings.continueText,
              onPressed: controller.isLoading.value ? () {} : () => controller.login(),
              style: AuthButtonStyle.filled,
            )
            ),
      ),
    );
  }

  Widget _buildTermsAndPrivacyText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          children: [
            TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
