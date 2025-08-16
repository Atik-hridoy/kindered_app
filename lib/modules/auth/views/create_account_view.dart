import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/auth/controllers/create_account_view_controller.dart';
import 'package:kindered_app/modules/auth/widget_button.dart';

class CreateAccountView extends GetView<CreateAccountViewController> {
  const CreateAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image with overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/au1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: const Color(0xFF2E3A59).withOpacity(0.7),
            ),
          ),

          // Content
          LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = isSmallScreen 
                  ? Size(206 * 0.8, 40 * 0.8) 
                  : const Size(206, 40);
                  
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.1),
                          
                          // Kindred Logo
                          Center(
                            child: Container(
                              width: logoSize.width,
                              height: logoSize.height,
                              margin: EdgeInsets.only(
                                bottom: isSmallScreen ? 30.0 : 40.0,
                              ),
                              child: SvgPicture.asset(
                                'assets/svg/Kindred.svg',
                                width: logoSize.width,
                                height: logoSize.height,
                              ),
                            ),
                          ),

                          // Title
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Can we get your phone number,\n',
                                ),
                                TextSpan(
                                  text: 'Please?',
                                ),
                              ],
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600, // Semi-bold
                              fontFamily: 'PlayfairDisplay',
                              height: 28/20, // line-height / font-size
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Phone Input
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB27438).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFB27438).withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                // Country Code Dropdown
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.countryCode.value,
                                    dropdownColor: const Color(0xFF2E3A59),
                                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFB27438), size: 28),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.countryCode.value = value;
                                      }
                                    },
                                    items: <String>['+880', '+1', '+44', '+91', '+49']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Vertical Divider
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Colors.white.withOpacity(0.3),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                // Phone Number Field
                                Expanded(
                                  child: TextField(
                                    controller: controller.phoneController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                      letterSpacing: 0.5,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter phone number',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFB0B5C0),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'We never share your personal information with anyone',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          
                          const Spacer(),

                          // Next Button
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                                minWidth: isSmallScreen ? 280 : 335,
                              ),
                              child: AuthCtaButton(
                                text: 'Next',
                                onPressed: controller.onNextPressed,
                                style: AuthButtonStyle.filled,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Terms and Privacy Text
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(text: 'By signing up, you agree to our '),
                                  TextSpan(
                                    text: 'Terms',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                    // TODO: Add onTap handler for Terms
                                    // onTap: () => _launchTermsUrl(),
                                  ),
                                  const TextSpan(text: '. See how we use your data in our '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                    // TODO: Add onTap handler for Privacy Policy
                                    // onTap: () => _launchPrivacyPolicyUrl(),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}