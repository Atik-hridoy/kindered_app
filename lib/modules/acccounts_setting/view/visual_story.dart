

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widget/button.dart';
import '../widget/progress_bar.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/accounts_controller.dart';

class VisualStory extends StatefulWidget {
  const VisualStory({super.key});

  @override
  State<VisualStory> createState() => _VisualStoryState();
}

class _VisualStoryState extends State<VisualStory> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  late final AccountsController _accountsController;
  
  // State variables
  List<XFile?> selectedImages = List<XFile?>.filled(5, null);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _accountsController = Get.find<AccountsController>();
  }

  // Handle image selection
  Future<void> _handleImageSelection(int index) async {
    AppLogger.info('📸 Starting image selection for index: $index');
    
    // Check if plugins are available
    if (!await _checkPluginsAvailable()) {
      _showSnackBar(
        'Plugin Error',
        'Required plugins are not available. Please restart the app.',
        Colors.red,
      );
      return;
    }
    
    try {
      // Try to request permissions first
      bool hasPermission = await _requestPermissions();
      
      if (hasPermission) {
        final XFile? image = await _pickImageWithFallback();
        
        if (image != null) {
          await _processSelectedImage(image, index);
        } else {
          AppLogger.warning('❌ No image selected');
        }
      }
    } catch (e) {
      await _handleImageSelectionError(e);
    }
  }
  
  // Check if required plugins are available
  Future<bool> _checkPluginsAvailable() async {
    bool imagePickerAvailable = false;
    
    // Test image picker
    try {
      ImagePicker();
      AppLogger.info('✅ ImagePicker plugin is available');
      imagePickerAvailable = true;
    } catch (e) {
      AppLogger.warning('❌ ImagePicker plugin not available: $e');
    }
    
    // Test permission handler
    try {
      await Permission.photos.status;
      AppLogger.info('✅ PermissionHandler plugin is available');
    } catch (e) {
      AppLogger.warning('❌ PermissionHandler plugin not available: $e');
      // Don't fail completely if permission handler is not available
      // We can try to proceed without it on some devices
    }
    
    // At minimum, we need image picker
    if (imagePickerAvailable) {
      AppLogger.info('✅ Core functionality available (ImagePicker)');
      return true;
    }
    
    AppLogger.warning('❌ Critical plugins not available');
    return false;
  }
  
  // Request permissions with multiple fallback strategies
  Future<bool> _requestPermissions() async {
    try {
      // Check if permission handler is available
      bool permissionHandlerWorking = false;
      try {
        await Permission.photos.status;
        permissionHandlerWorking = true;
        AppLogger.info('✅ PermissionHandler is working');
      } catch (e) {
        AppLogger.warning('⚠️ PermissionHandler not working: $e');
        AppLogger.info('🔄 Will attempt to proceed without permission checks');
      }
      
      if (!permissionHandlerWorking) {
        // If permission handler is not available, try to proceed anyway
        // Some Android versions work without explicit permission requests
        AppLogger.info('🔄 Proceeding without explicit permission check');
        return true;
      }
      
      // Strategy 1: Try photos permission (Android 13+)
      var status = await Permission.photos.request();
      AppLogger.info('📱 Photos permission status: $status');
      
      if (status.isGranted) {
        AppLogger.info('✅ Photos permission granted');
        return true;
      }
      
      // Strategy 2: Try storage permission (Android 12 and below)
      if (status.isDenied) {
        status = await Permission.storage.request();
        AppLogger.info('📱 Storage permission status: $status');
        
        if (status.isGranted) {
          AppLogger.info('✅ Storage permission granted');
          return true;
        }
      }
      
      // Strategy 3: Try external storage permission
      if (status.isDenied) {
        status = await Permission.manageExternalStorage.request();
        AppLogger.info('📱 Manage external storage permission status: $status');
        
      
        if (status.isGranted) {
        
          return true;
        }
      }
      
      // Handle permanent denial
      if (status.isPermanentlyDenied) {
        AppLogger.warning('⚠️ Permissions permanently denied');
        _showPermissionDialog();
        return false;
      }
      
      // If all strategies failed
      AppLogger.warning('❌ All permission strategies failed');
      _showSnackBar(
        'Permission Denied',
        'Gallery permission is required to select images',
        Colors.red,
      );
      return false;
      
    } catch (permissionError) {
      AppLogger.warning('⚠️ Permission handler error: $permissionError');
      AppLogger.info('🔄 Attempting to proceed without explicit permission check');
      // If permission handler fails, try to proceed anyway
      // Some devices work without explicit permission requests
      return true;
    }
  }
  
  // Pick image with fallback strategies
  Future<XFile?> _pickImageWithFallback() async {
    try {
      AppLogger.info('🔄 Attempting to pick image from gallery');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to reduce file size
      );
      
      if (image != null) {
        AppLogger.info('📷 Image selected: ${image.path}');
        return image;
      }
      
      return null;
    } catch (e) {
      AppLogger.warning('❌ Error picking image from gallery: $e');
      
      // Fallback: Try camera if gallery fails
      try {
        AppLogger.info('🔄 Attempting fallback to camera');
        final XFile? cameraImage = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        
        if (cameraImage != null) {
          AppLogger.info('📷 Camera image selected: ${cameraImage.path}');
          return cameraImage;
        }
      } catch (cameraError) {
        AppLogger.warning('❌ Camera fallback also failed: $cameraError');
      }
      
      return null;
    }
  }
  
  // Process the selected image
  Future<void> _processSelectedImage(XFile image, int index) async {
    try {
      AppLogger.info('📊 Image size: ${await image.length()} bytes');
      
      // Validate image file
      final File imageFile = File(image.path);
      if (!await imageFile.exists()) {
        throw Exception('Selected image file does not exist');
      }
      
      setState(() {
        selectedImages[index] = image;
      });
      
      AppLogger.info('✅ Image stored at index $index');
    } catch (e) {
      AppLogger.warning('❌ Error processing selected image: $e');
      _showSnackBar(
        'Processing Error',
        'Failed to process selected image',
        Colors.red,
      );
    }
  }
  
  // Handle image selection errors
  Future<void> _handleImageSelectionError(dynamic error) async {
    AppLogger.warning('❌ Error picking image: $error');
    
    String errorMessage = 'Failed to pick image';
    String errorDetails = '';
    
    if (error.toString().contains('MissingPluginException')) {
      errorMessage = 'Plugin not available';
      errorDetails = 'Required plugins are not properly initialized. Please restart the app.';
      AppLogger.info('💡 Plugin issue detected - app may need restart');
    } else if (error.toString().contains('permission')) {
      errorMessage = 'Permission denied';
      errorDetails = 'Please check app settings and grant gallery permissions.';
    } else if (error.toString().contains('PlatformException')) {
      errorMessage = 'Platform error';
      errorDetails = 'The device encountered an error. Please try again.';
    } else {
      errorMessage = 'Selection failed';
      errorDetails = 'Failed to pick image: ${error.toString()}';
    }
    
    _showSnackBar(
      errorMessage,
      errorDetails,
      Colors.red,
    );
  }

  // Show permission dialog
  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Please enable gallery permissions in app settings to select images.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Show snack bar with logging
  void _showSnackBar(String title, String message, Color backgroundColor) {
    AppLogger.info('📢 Showing snack bar: $title - $message');
    
    // If message is too long, split it into title and details
    String displayTitle = title;
    String displayMessage = message;
    
    if (message.length > 100) {
      displayTitle = title;
      displayMessage = '${message.substring(0, 100)}...';
    }
    
    Get.snackbar(
      displayTitle,
      displayMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      isDismissible: true,
    );
  }

  // Check if at least 3 images are selected
  bool get canProceed => selectedImages.where((img) => img != null).length >= 3;

  Widget _buildPhotoCard({
    required String label,
    required VoidCallback onTap,
    required int index,
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
                  color: Colors.white.withValues(alpha: 0.6), // Slightly more visible
                  strokeWidth: 1.5,
                  dashLength: 8, // Slightly longer dashes
                  gapLength: 6,  // Slightly longer gaps
                  radius: 12,
                ),
              ),
            ),
            // Content
            Center(
              child: selectedImages[index] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(selectedImages[index]!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12.0), // Reduced from 16.0
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24, // Reduced from 32
                            height: 24, // Reduced from 32
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 16, // Reduced from 18
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Photo Grid with 2 boxes on right and 2 below
                  SizedBox(
                    height: 500, // Reduced from 600
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
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6, bottom: 12),
                                  height: 300, // Reduced height
                                  child: _buildPhotoCard(
                                    label: 'Full Body',
                                    onTap: () => _handleImageSelection(0),
                                    index: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Two stacked boxes on right
                              Expanded(
                                child: Column(
                                  children: [
                                    // Top right box
                                    Container(
                                      height: 140, // Reduced height
                                      margin: const EdgeInsets.only(bottom: 6),
                                      child: _buildPhotoCard(
                                        label: 'Headshot',
                                        onTap: () => _handleImageSelection(1),
                                        index: 1,
                                      ),
                                    ),
                                    // Bottom right box
                                    Container(
                                      height: 140, // Reduced height
                                      margin: const EdgeInsets.only(top: 6),
                                      child: _buildPhotoCard(
                                        label: 'Personality',
                                        onTap: () => _handleImageSelection(2),
                                        index: 2,
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
                          height: 160, // Reduced from 200
                          child: Row(
                            children: [
                              // Bottom left box
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6, top: 12),
                                  child: _buildPhotoCard(
                                    label: 'Add Image',
                                    onTap: () => _handleImageSelection(3),
                                    index: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Bottom right box
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 6, top: 12),
                                  child: _buildPhotoCard(
                                    label: 'Add Image',
                                    onTap: () => _handleImageSelection(4),
                                    index: 4,
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
                        TextSpan(
                          text: 'At least 3 photos required. (${selectedImages.where((img) => img != null).length}/5 added)',
                        ),
                        TextSpan(
                          text: ' Tap + to add photos. Your first photo will be your main profile picture',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
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
          text: 'Submit',
          onPressed: canProceed
              ? () async {
                  final paths = selectedImages
                      .where((img) => img != null)
                      .map((img) => img!.path)
                      .toList();
                  await _accountsController.submitCompleteProfileWithPhotos(paths);
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
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.gap = 5,
  });

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