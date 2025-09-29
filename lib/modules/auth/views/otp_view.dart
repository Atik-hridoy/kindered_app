import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/auth/controllers/otp_controller.dart';
import 'package:kindered_app/modules/auth/widget_button.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: const Color(0xFF2E3A59),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 20.0),
            Text(
              AppStrings.verifyYourEmail,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFFB0AEAC),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PlayfairDisplay',
                ),
                children: [
                  TextSpan(text: '${AppStrings.enterOtp}\n'),
                  TextSpan(
                    text: controller.target.value,
                    style: const TextStyle(fontFamily: 'Inter'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // OTP input fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 60,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4A373), width: 2.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4A373), width: 2.0),
                      ),
                      contentPadding: EdgeInsets.only(bottom: 8),
                    ),
                    onChanged: (value) {
                      try {
                        if (controller.otpDigits.isNotEmpty && index < controller.otpDigits.length) {
                          controller.otpDigits[index].value = value;
                        }
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      } catch (e) {
                        AppLogger.error('❌ OTP input error: $e');
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Resend code
            Row(
              children: [
                Text(
                  AppStrings.resendCodePrompt,
                  style: const TextStyle(color: Color(0xFFB0AEAC), fontSize: 14),
                ),
                GestureDetector(
                  onTap: controller.isLoading.value
                      ? null
                      : () {
                          controller.resendOtp();
                        } as VoidCallback,
                  child: Text(
                    AppStrings.resend,
                    style: const TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Verify button
            AuthCtaButton(
              text: controller.isLoading.value ? 'Verifying...' : AppStrings.verify,
              onPressed: controller.isLoading.value ? () {} : controller.verifyOtp,
              style: AuthButtonStyle.filled,
            ),
          ],
        )),
      ),
    );
  }
}