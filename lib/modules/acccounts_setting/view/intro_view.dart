import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/intro_view_controller.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/input_box.dart';
import 'package:kindered_app/modules/acccounts_setting/widget/button.dart';

class IntroView extends GetView<IntroViewController> {
  final _formKey = GlobalKey<FormState>();

  IntroView({super.key}) {
    Get.put(IntroViewController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildProfilePicture(),
                const SizedBox(height: 24),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildUsernameField(),
                const SizedBox(height: 16),
                _buildBioField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: const DecorationImage(
                  image: AssetImage('assets/images/placeholder_avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFD89A58),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return CustomInputField(
      controller: TextEditingController(text: controller.firstName.value),
      hintText: 'Name',
      onChanged: (value) => controller.firstName.value = value,
      fillColor: const Color(0xFFF5F5F5),
      borderColor: const Color(0xFFE0E0E0),
      focusedBorderColor: const Color(0xFFD89A58),
      textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildUsernameField() {
    return CustomInputField(
      controller: TextEditingController(text: '@username'),
      hintText: 'Username',
      fillColor: const Color(0xFFF5F5F5),
      borderColor: const Color(0xFFE0E0E0),
      focusedBorderColor: const Color(0xFFD89A58),
      textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF9E9E9E), size: 20),
    );
  }

  Widget _buildBioField() {
    return CustomInputField(
      controller: TextEditingController(text: 'Add a short bio...'),
      hintText: 'Add a short bio...',
      maxLines: 4,
      fillColor: const Color(0xFFF5F5F5),
      borderColor: const Color(0xFFE0E0E0),
      focusedBorderColor: const Color(0xFFD89A58),
      textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }


  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomGradientButton(
        text: 'Save',
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            controller.updateProfile();
          }
        },
        height: 50,
        borderRadius: 12,
        gradientColors: const [Color(0xFFD89A58), Color(0xFFD47A6A)],
      ),
    );
  }
}
