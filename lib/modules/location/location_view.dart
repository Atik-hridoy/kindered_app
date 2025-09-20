import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59), // Updated background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              // Top spacer
              const Spacer(flex: 2),
              
              // Location Icon
              SvgPicture.asset(
                'assets/svg/location.svg',
                width: 100,
                height: 100,
                colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
              ),
              
              const SizedBox(height: 48),
              
              // Title
              Text(
                'Can we get your location,\nPlease?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Text(
                'Allow location so that we can show you all the nearby people or far away',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              // Bottom spacer
              const Spacer(flex: 3),
              
              // Location Setting Button
              Obx(() {
                // Show error message if there's an error
                if (controller.errorMessage.value.isNotEmpty) {
                  return Column(
                    children: [
                      CustomGradientButton(
                        text: controller.isLoading.value 
                            ? 'Updating Location...' 
                            : 'Location Setting',
                        onPressed: () async {
                          await controller.updateUserLocation();
                        },
                        width: double.infinity,
                        height: 48,
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Error message display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Retry button
                      TextButton(
                        onPressed: () async {
                          await controller.retryLocationUpdate();
                        },
                        child: Text(
                          'Retry',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                
                // Show normal button if no error
                return CustomGradientButton(
                  text: controller.isLoading.value 
                      ? 'Updating Location...' 
                      : 'Location Setting',
                  onPressed: () async {
                    await controller.updateUserLocation();
                  },
                  width: double.infinity,
                  height: 48,
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}