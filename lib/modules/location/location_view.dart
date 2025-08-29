import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';

class LocationView extends StatelessWidget {
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
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              // Bottom spacer
              const Spacer(flex: 3),
              
              // Location Setting Button
              CustomGradientButton(
                text: 'Location Setting',
                onPressed: () {
                  Get.toNamed(AppRoutes.homeSuggestionView);
                },
                width: double.infinity,
                height: 48,
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}