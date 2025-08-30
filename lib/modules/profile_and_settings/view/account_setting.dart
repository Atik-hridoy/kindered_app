import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/account_setting_controller.dart';

class AccountSettingView extends GetView<AccountSettingController> {
  const AccountSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Get.toNamed(AppRoutes.profileView),
  ),
  title: const Text(
    'Account Settings',
    style: TextStyle(
      color: Colors.white,
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
            title: 'Update Phone Number',
            iconPath: 'assets/svg/profile/phone.svg',
            onTap: () {
              Get.toNamed(AppRoutes.updatePhonNumberView);
            },
          ),
          _buildListTile(
            context,
            title: 'Update Email',
            iconPath: 'assets/svg/profile/mail.svg',
            onTap: () {},
          ),
          _buildListTile(
            context,
            title: 'Delete Account',
            iconPath: 'assets/svg/profile/delete.svg',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 2),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24, right: 16, top: 0, bottom: 2),
                child: Divider(height: 1, color: Color(0xFF755A3F)),
              ),
            ],
          ),
        ),
        // No extra space needed
      ],
    );
  }
}