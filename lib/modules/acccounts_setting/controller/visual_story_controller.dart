import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class VisualStoryController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // List to store selected images for each card
  RxList<XFile?> selectedImages = List<XFile?>.filled(5, null).obs;

  // Pick image for a given index
  Future<void> pickImage(int index) async {
    try {
      // Request permissions first
      var status = await Permission.photos.request();
      if (status.isDenied) {
        // Fallback to storage permission for older Android versions
        status = await Permission.storage.request();
      }
      
      if (status.isGranted) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80, // Compress image to reduce file size
        );
        
        if (image != null) {
          selectedImages[index] = image;
          Get.snackbar(
            'Success',
            'Image selected successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      } else if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        _showPermissionDialog();
      } else {
        Get.snackbar(
          'Permission Denied',
          'Gallery permission is required to select images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
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

  // Check if at least 3 images are selected
  bool get canProceed => selectedImages.where((img) => img != null).length >= 3;
}
