import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../widget_button.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Optional: simple background color to start with
            Container(color: const Color(0xFF2E3A59)),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in or create an account',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),

                  // Primary CTA
                  Center(
                    child: AuthCtaButton(
                      text: 'Create an account',
                      onPressed: () {
                        // TODO: navigate to sign up
                      },
                      style: AuthButtonStyle.filled,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary CTA
                  Center(
                    child: AuthCtaButton(
                      text: 'I have an account',
                      onPressed: () {
                        // TODO: navigate to sign in form
                      },
                      style: AuthButtonStyle.outline,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
