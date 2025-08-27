import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/interest_view_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox_muilti.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';

class InterestView extends GetView<InterestViewController> {

  final InterestViewController controller = Get.put(InterestViewController());
  
  final List<Map<String, String>> interestOptions = [
    {
      'title': 'Long-term partner',
      'description': 'Looking for a serious relationship'
    },
    {
      'title': 'Long-term, open to short',
      'description': 'Looking for a serious relationship, but open to short-term fun'
    },
    {
      'title': 'Short-term fun',
      'description': 'Looking for something casual'
    },
    {
      'title': 'Short-term, open to long',
      'description': 'Looking for something casual, but open to a serious relationship'
    },
    {
      'title': 'New friends',
      'description': 'Looking for new friends to hang out with'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            onPressed: () => Get.back(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(35.0),
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: CustomProgressBar(
              value: 0.8, // 80% progress
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amazing, what brings you here?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Choose a mode we\'ll find the best partner for you. What you Long-term partner, Casual connection or friendship?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14.0,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24.0),
              const SizedBox(height: 16.0),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: interestOptions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                itemBuilder: (context, index) => Obx(
                  () => CustomCheckboxMulty(
                    label: '${interestOptions[index]['title']!}\n${interestOptions[index]['description']!}',
                    isSelected: controller.selectedIndices.contains(index),
                    onTap: () => controller.toggleSelection(index),
                    selectedColor: const Color(0xFFD4A574).withValues(alpha: 0.8),
                    unselectedColor: Colors.transparent,
                    textColor: const Color(0xFFD4A373),
                    height: 70.0,
                    titleFontSize: 14.0,
                    descriptionFontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Obx(
            () => CustomGradientButton(
              onPressed: controller.selectedIndices.isNotEmpty
                  ? () {
                      Get.toNamed(AppRoutes.heightWeight);
                    }
                  : null,
              text: 'Next',
              textStyle: GoogleFonts.inter(
                color: const Color(0xFF2C3E50),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              height: 56,
              borderRadius: 12,
              gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
            ),
          ),
        ),
      ),
    );
  }
}
