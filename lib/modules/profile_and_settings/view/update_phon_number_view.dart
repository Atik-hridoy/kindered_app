import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/update_phon_number_controller.dart';
import 'package:kindered_app/modules/auth/widget_button.dart' show AuthCtaButton, AuthButtonStyle;

class UpdatePhonNumberView extends GetView<UpdatePhonNumberController> {
  const UpdatePhonNumberView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: true,
      body: _buildBody(context, isSmallScreen),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isSmallScreen) {
    return Stack(
      children: [
        Container(color: const Color(0xFF2E3A59)),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top + 24),
                        _buildTitle(),
                        const SizedBox(height: 32),
                        _buildPhoneInputLabel(),
                        _buildPhoneInput(),
                        const Spacer(),
                        _buildUpdateButton(isSmallScreen),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Can we get your number ?'),
          
        ],
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlayfairDisplay',
        height: 28 / 20,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildPhoneInputLabel() {
    return const Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        'PHONE NUMBER',
        style: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 25 / 12,
          letterSpacing: -0.5,
          color: Color(0xFFB0AEAC),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildCountryCodeDropdown(),
            const SizedBox(width: 8),
            _buildVerticalDivider(),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhoneNumberField(),
            ),
          ],
        ),
        Container(
          height: 1.5,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4A373).withValues(alpha: 0.7),
                const Color(0xFFD4A373).withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'We\'ll send you a code to your phone number to verify you.',
            style: TextStyle(
              color: Color(0xFFB0B5C0),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCodeDropdown() {
    return GetBuilder<UpdatePhonNumberController>(
      builder: (controller) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.countryCode.value,
            dropdownColor: const Color(0xFF2E3A59),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFB27438), size: 28),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            onChanged: (value) {
              if (value != null) {
                controller.countryCode.value = value;
                controller.update();
              }
            },
            items: <String>['+880', '+1', '+44', '+91', '+49']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildPhoneNumberField() {
    return GetBuilder<UpdatePhonNumberController>(
      builder: (controller) {
        return TextField(
          controller: controller.phoneController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          decoration: const InputDecoration(
            hintText: 'Enter phone number',
            hintStyle: TextStyle(
              color: Color(0xFFB0B5C0),
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(bottom: 8),
          ),
          keyboardType: TextInputType.phone,
        );
      },
    );
  }

  Widget _buildUpdateButton(bool isSmallScreen) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          minWidth: isSmallScreen ? 280 : 335,
        ),
        child: AuthCtaButton(
          text: 'Next',
          onPressed: () {
            Get.toNamed(AppRoutes.numberVerifyView);
          },
          style: AuthButtonStyle.filled,
        ),
      ),
    );
  }
}