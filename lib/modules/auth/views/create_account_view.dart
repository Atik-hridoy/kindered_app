import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:kindered_app/modules/auth/controllers/create_account_view_controller.dart';
import 'package:kindered_app/modules/auth/widget_button.dart';

class CreateAccountView extends GetView<CreateAccountViewController> {
  const CreateAccountView({super.key});

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
    final size = MediaQuery.of(context).size;

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
                        const SizedBox(height: 24),
                        _buildPhoneInputLabel(),
                        _buildPhoneInput(),
                        const Spacer(),
                        _buildPrivacyText(),
                        _buildNextButton(isSmallScreen),
                        _buildTermsAndPrivacyText(),
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
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${AppStrings.phoneNumberTitle}\n'),
          TextSpan(text: AppStrings.please),
        ],
      ),
      style: const TextStyle(
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
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        AppStrings.phoneNumber,
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
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4A373),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A373).withValues(alpha: 0.5),
            offset: const Offset(0, 2),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCountryCodeDropdown(),
          const SizedBox(width: 8),
          _buildVerticalDivider(),
          _buildPhoneNumberField(),
        ],
      ),
    );
  }

  Widget _buildCountryCodeDropdown() {
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
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildPhoneNumberField() {
    return Expanded(
      child: TextField(
        controller: controller.phoneController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.enterPhoneNumber,
          hintStyle: TextStyle(
            color: Color(0xFFB0B5C0),
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        keyboardType: TextInputType.phone,
      ),
    );
  }

  Widget _buildPrivacyText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE98675),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE98675).withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const Text(
            'We never share your personal information with anyone',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isSmallScreen) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          minWidth: isSmallScreen ? 280 : 335,
        ),
        child: AuthCtaButton(
          text: AppStrings.continueText,
          onPressed: () {
            // TODO: Implement continue action
            Get.toNamed('/otp-verification');
          },
          style: AuthButtonStyle.filled,
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacyText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
          
        ),
      ),
    );
  }
}
