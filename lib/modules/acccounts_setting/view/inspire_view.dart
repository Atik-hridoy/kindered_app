import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/progress_bar.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/checkbox.dart';
import 'package:kindered_app/modules/acccounts_setting/view/faith_belief_view.dart';

class InspireView extends StatefulWidget {
  const InspireView({Key? key}) : super(key: key);

  @override
  State<InspireView> createState() => _InspireViewState();
}

class _InspireViewState extends State<InspireView> {
  final List<String> traits = [
    'Ambition',
    'Emotional inteligence',
    'Curiosity',
    'Humble',
    'Witty',
    'Loyal',
    'Kind',
    'Humour',
  ];
  
  final Set<int> selectedIndices = {};
  
  bool get isButtonEnabled => selectedIndices.length >= 3;
  
  void toggleTrait(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }

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
          preferredSize: const Size.fromHeight(35.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: CustomProgressBar(
              value: 1.0, // 100% progress
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Which personal traits inspire you the most?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose minimum 3 qualities which speak to your soul and make a connection that much stronger. ',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.0,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Traits selection
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: traits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return CustomCheckbox(
                  label: traits[index],
                  isSelected: selectedIndices.contains(index),
                  onTap: () => toggleTrait(index),
                  titleFontSize: 16.0,
                  descriptionFontSize: 14.0,
                );
              },
            ),
            const SizedBox(height: 24),
            if (selectedIndices.isNotEmpty && selectedIndices.length < 3)
              Text(
                'Select ${3 - selectedIndices.length} more to continue',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.amber[300],
                  fontSize: 14.0,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 50.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomGradientButton(
          text: 'Next',
          onPressed: isButtonEnabled ? () {
            // Navigate to Faith/Belief view
            Get.to(() => const FaithBeliefView());
          } : null,
          enabled: isButtonEnabled,
        ),
      ),
    );
  }
}
