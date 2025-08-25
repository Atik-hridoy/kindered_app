import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import '../controllers/login_controller.dart';
import '../widget_button.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  // Responsive padding based on screen size
  EdgeInsetsGeometry _getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return EdgeInsets.symmetric(horizontal: width * 0.2);
    }
    return const EdgeInsets.symmetric(horizontal: 20.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
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
                color: const Color(0xFF2E3A59).withValues(alpha: 0.7), // #2E3A59 with 70% opacity
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
                        padding: _getPadding(context),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.2),
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
                            
                            const Spacer(),

                            // Primary CTA
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 400,
                                  minWidth: isSmallScreen ? 280 : 335,
                                ),
                                child: AuthCtaButton(
                                  text: AppStrings.createAccount,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.getCreateAccountRoute());
                                  },
                                  style: AuthButtonStyle.filled,
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 24),

                            // Secondary CTA
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 400,
                                  minWidth: isSmallScreen ? 280 : 335,
                                ),
                                child: AuthCtaButton(
                                  text: AppStrings.haveAccount,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.getExtendedLoginRoute());
                                  },
                                  style: AuthButtonStyle.outline,
                                ),
                              ),
                            ),

                            // Terms and Privacy Text
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(text: '${AppStrings.bySigningUp} '),
                                    TextSpan(
                                      text: AppStrings.terms,
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      // onTap: () => _launchTermsUrl(),
                                    ),
                                    TextSpan(text: ' ${AppStrings.seeHowWeUse} '),
                                    TextSpan(
                                      text: AppStrings.privacyPolicy,
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      // onTap: () => _launchPrivacyPolicyUrl(),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: size.height * 0.05),
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
      ),
    );
  }
}
