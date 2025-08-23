import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/interest_view_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';

class InterestView extends GetView<InterestViewController> {
  final List<String> interestOptions = [
    'Travel',
    'Music',
    'Sports',
    'Food',
    'Art',
    'Technology',
    'Fashion',
    'Reading',
    'Gaming',
    'Photography',
  ];

  final RxList<String> selectedInterests = <String>[].obs;

  @override
  final InterestViewController controller = Get.put(InterestViewController());

  InterestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(35.0),
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: CustomProgressBar(
              value: 0.8, // 80% progress
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 1.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Get.back();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32.0),
              Text(
                'What are your interests?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Select a few things you\'re interested in',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16.0,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: interestOptions.map((interest) => Obx(
                  () => FilterChip(
                    label: Text(interest),
                    selected: selectedInterests.contains(interest),
                    onSelected: (selected) {
                      if (selected) {
                        selectedInterests.add(interest);
                      } else {
                        selectedInterests.remove(interest);
                      }
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: const Color(0xFFD4A373),
                    labelStyle: GoogleFonts.inter(
                      color: selectedInterests.contains(interest) 
                          ? Colors.white 
                          : Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 70.0),
              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedInterests.isNotEmpty
                        ? () {
                            // Navigate to next screen
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A373),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
