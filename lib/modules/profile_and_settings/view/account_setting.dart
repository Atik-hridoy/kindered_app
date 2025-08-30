import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/account_setting_controller.dart';

class AccountSettingView extends GetView<AccountSettingController> {
  const AccountSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildListTile(
            context,
            title: 'Edit Profile',
            icon: Icons.person_outline,
            onTap: () {},
          ),
          _buildListTile(
            context,
            title: 'Change Password',
            icon: Icons.lock_outline,
            onTap: () {},
          ),
          _buildListTile(
            context,
            title: 'Privacy Settings',
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white, size: 24),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        const Divider(height: 1, color: Color(0xFF755A3F), indent: 24),
      ],
    );
  }
}