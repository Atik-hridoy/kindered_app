import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DevScreen extends StatelessWidget {
  const DevScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Screen'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDevButton(
            context,
            'Faith & Belief',
            '/faith-belief',
            Icons.psychology,
          ),
          const SizedBox(height: 12),
          _buildDevButton(
            context,
            'Education',
            '/education',
            Icons.school,
          ),
          const SizedBox(height: 12),
          _buildDevButton(
            context,
            'Height & Weight',
            '/height-weight',
            Icons.height,
          ),
          const SizedBox(height: 12),
          _buildDevButton(
            context,
            'Inspire',
            '/inspire',
            Icons.emoji_emotions,
          ),
        ],
      ),
    );
  }

  Widget _buildDevButton(
    BuildContext context,
    String title,
    String route,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      onPressed: () => Get.toNamed(route),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
