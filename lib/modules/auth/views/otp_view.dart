import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/auth/controllers/otp_controller.dart';
import 'package:kindered_app/modules/auth/widget_button.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 20.0),
            
            // Title
            const Text(
              'We need to verify your number',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'PlayfairDisplay',
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            
            // Subtitle
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFFB0AEAC),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PlayfairDisplay',
                ),
                children: const [
                  TextSpan(text: 'Please enter the verification code sent to\n'),
                  TextSpan(
                    text: '+61 2345 5656 69',
                    style: TextStyle(
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {  // Changed from 6 to 4 digits
                return SizedBox(
                  width: 60,  // Slightly wider for better touch target
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4A373), width: 2.0),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4A373), width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 8),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 32),
            
            // Resend Code and Verify Button
            Column(
              children: [
                // Resend Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        color: Color(0xFFB0AEAC),
                        fontSize: 14,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement resend OTP
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: Color(0xFFD4A373),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Verify Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    child: AuthCtaButton(
                      text: 'Verify',
                      onPressed: () {
                        // TODO: Implement OTP verification
                      },
                      style: AuthButtonStyle.filled,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }
}
