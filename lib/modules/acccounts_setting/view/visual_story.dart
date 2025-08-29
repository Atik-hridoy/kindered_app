import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widget/button.dart';
import '../widget/progress_bar.dart';
import 'dart:math' as math;

class VisualStory extends StatefulWidget {
  const VisualStory({Key? key}) : super(key: key);

  @override
  State<VisualStory> createState() => _VisualStoryState();
}

class _VisualStoryState extends State<VisualStory> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleImageSelection(int index) {
    // TODO: Implement image selection logic
    print('Selected box at index: $index');
  }

  Widget _buildPhotoCard({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          border: null, // Remove solid border
          boxShadow: [],
        ),
        child: Stack(
          children: [
            // Dashed border for all boxes
            Positioned.fill(
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: Colors.white.withOpacity(0.6), // Slightly more visible
                  strokeWidth: 1.5,
                  dashLength: 8, // Slightly longer dashes
                  gapLength: 6,  // Slightly longer gaps
                  radius: 12,
                ),
              ),
            ),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
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
                        size: 18,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 8.0,
                bottom: 20.0,
              ),
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
                  
                  // Photo Grid with 2 boxes on right and 2 below
                  SizedBox(
                    height: 600, // Adjusted height for the layout
                    child: Column(
                      children: [
                        // First row - Big box on left, 2 stacked boxes on right
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Big box on left
                              Expanded(
                                flex: 2, // Takes more horizontal space
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6, bottom: 12),
                                  child: _buildPhotoCard(
                                    label: 'Full Body',
                                    onTap: () => _handleImageSelection(0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Two stacked boxes on right
                              Expanded(
                                child: Column(
                                  children: [
                                    // Top right box
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: _buildPhotoCard(
                                          label: 'Headshot',
                                          onTap: () => _handleImageSelection(1),
                                        ),
                                      ),
                                    ),
                                    // Bottom right box
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: _buildPhotoCard(
                                          label: 'Personality',
                                          onTap: () => _handleImageSelection(2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Second row - 2 boxes below matching right side boxes
                        SizedBox(
                          height: 200, // Fixed height to match right side boxes
                          child: Row(
                            children: [
                              // Bottom left box
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6, top: 12),
                                  child: _buildPhotoCard(
                                    label: 'Add Image',
                                    onTap: () => _handleImageSelection(3),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Bottom right box
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6, top: 12),
                                  child: _buildPhotoCard(
                                    label: 'Add Image',
                                    onTap: () => _handleImageSelection(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bottom text
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        color: const Color(0xFFD4A373),
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'At least 3 photos required.',
                        ),
                        TextSpan(
                          text: ' Tap + to add photos. Your first photo will be your main profile picture',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 8.0,
          bottom: 50.0,
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomGradientButton(
          text: 'Next',
          onPressed: () {
            // Add your navigation logic here
          },
          width: double.infinity,
          height: 48,
          borderRadius: 12,
          gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Custom Dashed Border Widget
class DashRect extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;

  const DashRect({
    Key? key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.gap = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
      ),
      child: child,
    );
  }
}

class DashRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path topPath = getDashedPath(
      a: const Offset(0, 0),
      b: Offset(x, 0),
      gap: gap,
    );

    Path rightPath = getDashedPath(
      a: Offset(x, 0),
      b: Offset(x, y),
      gap: gap,
    );

    Path bottomPath = getDashedPath(
      a: Offset(x, y),
      b: Offset(0, y),
      gap: gap,
    );

    Path leftPath = getDashedPath(
      a: Offset(0, y),
      b: const Offset(0, 0),
      gap: gap,
    );

    canvas.drawPath(topPath, dashedPaint);
    canvas.drawPath(rightPath, dashedPaint);
    canvas.drawPath(bottomPath, dashedPaint);
    canvas.drawPath(leftPath, dashedPaint);
  }

  Path getDashedPath({
    required Offset a,
    required Offset b,
    required double gap,
  }) {
    Size size = Size(b.dx - a.dx, b.dy - a.dy);
    Path path = Path();
    path.moveTo(a.dx, a.dy);
    bool shouldDraw = true;
    Offset currentPoint = Offset(a.dx, a.dy);

    double radians = math.atan(size.height / size.width);

    double dx = math.cos(radians) * gap < 0
        ? math.cos(radians) * gap * -1
        : math.cos(radians) * gap;

    double dy = math.sin(radians) * gap < 0
        ? math.sin(radians) * gap * -1
        : math.sin(radians) * gap;

    while (currentPoint.dx <= b.dx && currentPoint.dy <= b.dy) {
      shouldDraw
          ? path.lineTo(currentPoint.dx, currentPoint.dy)
          : path.moveTo(currentPoint.dx, currentPoint.dy);
      shouldDraw = !shouldDraw;
      currentPoint = Offset(
        currentPoint.dx + dx,
        currentPoint.dy + dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

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
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final double width = size.width;
    final double height = size.height;
    
    // Draw each side with dashes
    // Top
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(radius, 0),
      end: Offset(width - radius, 0),
    );
    
    // Right
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(width, radius),
      end: Offset(width, height - radius),
    );
    
    // Bottom
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(width - radius, height),
      end: Offset(radius, height),
    );
    
    // Left
    _drawDashedLine(
      canvas: canvas,
      paint: paint,
      start: Offset(0, height - radius),
      end: Offset(0, radius),
    );
    
    // Draw rounded corners
    if (radius > 0) {
      // Top-right corner
      _drawArc(
        canvas: canvas,
        paint: paint,
        center: Offset(width - radius, radius),
        startAngle: -math.pi / 2,
        sweepAngle: math.pi / 2,
      );
      
      // Bottom-right corner
      _drawArc(
        canvas: canvas,
        paint: paint,
        center: Offset(width - radius, height - radius),
        startAngle: 0,
        sweepAngle: math.pi / 2,
      );
      
      // Bottom-left corner
      _drawArc(
        canvas: canvas,
        paint: paint,
        center: Offset(radius, height - radius),
        startAngle: math.pi / 2,
        sweepAngle: math.pi / 2,
      );
      
      // Top-left corner
      _drawArc(
        canvas: canvas,
        paint: paint,
        center: Offset(radius, radius),
        startAngle: math.pi,
        sweepAngle: math.pi / 2,
      );
    }
  }

  void _drawDashedLine({
    required Canvas canvas,
    required Paint paint,
    required Offset start,
    required Offset end,
  }) {
    final bool isHorizontal = start.dy == end.dy;
    double length = isHorizontal 
        ? (end.dx - start.dx).abs() 
        : (end.dy - start.dy).abs();
    
    if (length <= 0) return;
    
    final double step = dashLength + gapLength;
    if (step <= 0) return;
    
    double current = 0;
    while (current < length) {
      final double currentDashLength = (current + dashLength > length) 
          ? length - current 
          : dashLength;
      
      if (currentDashLength > 0) {
        final double startPos = current;
        
        final Offset dashStart = isHorizontal
            ? Offset(
                start.dx + (start.dx < end.dx ? startPos : -startPos),
                start.dy
              )
            : Offset(
                start.dx,
                start.dy + (start.dy < end.dy ? startPos : -startPos)
              );
              
        final Offset dashEnd = isHorizontal
            ? Offset(
                dashStart.dx + (start.dx < end.dx ? currentDashLength : -currentDashLength),
                dashStart.dy
              )
            : Offset(
                dashStart.dx,
                dashStart.dy + (start.dy < end.dy ? currentDashLength : -currentDashLength)
              );
        
        final path = Path()
          ..moveTo(dashStart.dx, dashStart.dy)
          ..lineTo(dashEnd.dx, dashEnd.dy);
        canvas.drawPath(path, paint);
      }
      
      current += step;
    }
  }
  
  void _drawArc({
    required Canvas canvas,
    required Paint paint,
    required Offset center,
    required double startAngle,
    required double sweepAngle,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final path = Path()..addArc(rect, startAngle, sweepAngle);
    
    // Convert arc to dashed segments
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      final double totalLength = metric.length;
      
      while (distance < totalLength) {
        final double remaining = totalLength - distance;
        final double currentDashLength = (dashLength < remaining) 
            ? dashLength 
            : remaining;
            
        if (currentDashLength > 0) {
          final Path dashPath = metric.extractPath(distance, distance + currentDashLength);
          canvas.drawPath(dashPath, paint);
        }
        
        distance += currentDashLength + gapLength;
      }
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
