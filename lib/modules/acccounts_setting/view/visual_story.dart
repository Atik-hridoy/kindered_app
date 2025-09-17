import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/visual_story_controller.dart';
import '../widget/button.dart';
import '../widget/progress_bar.dart';

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Draw dashed border
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(rrect.left, rrect.top),
      end: Offset(rrect.right, rrect.top),
    );
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(rrect.right, rrect.top),
      end: Offset(rrect.right, rrect.bottom),
    );
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(rrect.right, rrect.bottom),
      end: Offset(rrect.left, rrect.bottom),
    );
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(rrect.left, rrect.bottom),
      end: Offset(rrect.left, rrect.top),
    );
  }

  void _drawDashedLine({
    required Canvas canvas,
    required Paint paint,
    required Offset start,
    required Offset end,
  }) {
    final distance = (end - start).distance;
    final dashCount = (distance / (dashLength + gapLength)).floor();
    final adjustedDashLength = dashLength;
    final adjustedGapLength = gapLength;

    final direction = (end - start) / (end - start).distance;
    var currentPos = start;

    for (int i = 0; i < dashCount; i++) {
      final dashEnd = currentPos + direction * adjustedDashLength;
      canvas.drawLine(currentPos, dashEnd, paint);
      currentPos = dashEnd + direction * adjustedGapLength;
    }

    // Draw remaining dash if there's space
    if ((currentPos - start).distance < distance) {
      canvas.drawLine(currentPos, end, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashLength != oldDelegate.dashLength ||
      gapLength != oldDelegate.gapLength ||
      radius != oldDelegate.radius;
}

class VisualStory extends StatelessWidget {
  VisualStory({Key? key}) : super(key: key);

  final VisualStoryController controller = Get.put(VisualStoryController());

  Widget _buildPhotoCard({
    required String label,
    required int index,
  }) {
    return Obx(
      () {
        final XFile? image = controller.selectedImages[index];
        final hasImage = image != null;

        return GestureDetector(
          onTap: () => controller.pickImage(index),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                // Dashed border
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DashedBorderPainter(
                      color: Colors.white.withOpacity(0.6),
                      strokeWidth: 1.5,
                      dashLength: 8,
                      gapLength: 6,
                      radius: 12,
                    ),
                  ),
                ),
                // Content
                Center(
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                label,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            onPressed: () => Get.back(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomProgressBar(
                  value: 1.0,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Your visual story',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add at least 3 photos and choose images that reflect your personality, lifestyle, and warmth',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            // Photo grid
            SizedBox(
              height: 500,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6, bottom: 12),
                            child: _buildPhotoCard(label: 'Full Body', index: 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: 140,
                                margin: const EdgeInsets.only(bottom: 6),
                                child: _buildPhotoCard(label: 'Headshot', index: 1),
                              ),
                              Container(
                                height: 140,
                                margin: const EdgeInsets.only(top: 6),
                                child: _buildPhotoCard(label: 'Personality', index: 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 6, top: 12),
                            child: _buildPhotoCard(label: 'Add Image', index: 3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 6, top: 12),
                            child: _buildPhotoCard(label: 'Add Image', index: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              return RichText(
                text: TextSpan(
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    color: const Color(0xFFD4A373),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'At least 3 photos required. (${controller.selectedImages.where((img) => img != null).length}/5 added)',
                    ),
                    TextSpan(
                      text:
                          ' Tap + to add photos. Your first photo will be your main profile picture',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          padding:
              const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 50.0),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: CustomGradientButton(
            text: 'Next',
            onPressed: controller.canProceed
                ? () {
                    Get.toNamed(AppRoutes.locationView);
                  }
                : null,
            width: double.infinity,
            height: 48,
            borderRadius: 12,
            gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
            textStyle: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }
}

// Keep your _DashedBorderPainter class as it is
