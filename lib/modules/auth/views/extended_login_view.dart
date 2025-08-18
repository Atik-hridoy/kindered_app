import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kindered_app/modules/auth/controllers/extended_login_view_controller.dart';
import '../widget_button.dart';

class ExtendedLoginView extends GetView<ExtendedLoginViewController> {
  const ExtendedLoginView({super.key});

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
                color: const Color(0xFF2E3A59).withOpacity(0.7), // #2E3A59 with 70% opacity
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
                                child: Container(
                                  width: double.infinity,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD47A6A), // Google button color
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement Google sign in
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/svg/google.svg',
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            color: Color(0xFF2E3A59),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                child: Container(
                                  width: double.infinity,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background for phone button
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF2E3A59), width: 1.2),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement phone sign in
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/svg/phone.svg',
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Continue with phone',
                                          style: TextStyle(
                                            color: Color(0xFF2E3A59),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Terms and Privacy Text
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(text: 'By signing in, you agree to our '),
                                    TextSpan(
                                      text: 'Terms.',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' See how we use your data in our '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
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