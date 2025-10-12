import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/about_us_controller.dart';

class AboutUsView extends GetView<AboutUsController> {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2332),
              Color(0xFF0F1419),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'About Us',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PerifareDisplay',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dynamic Content
              Expanded(
                child: Obx(() {
                  if (controller.isCurrentLoading) {
                    return const _LoadingState();
                  }
                  
                  if (controller.hasCurrentError) {
                    return _ErrorState(
                      errorMessage: controller.currentErrorMessage,
                      onRetry: controller.retry,
                    );
                  }
                  
                  return _ContentState(
                    content: controller.aboutUsContent,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A373)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading content...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'PerifareDisplay',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A373),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentState extends StatelessWidget {
  final String content;

  const _ContentState({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2332),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4A373).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFFD4A373),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'About Us',
                      style: TextStyle(
                        color: Color(0xFFD4A373),
                        fontSize: 18,
                        fontFamily: 'PerifareDisplay',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2332),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4A373).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildHtmlContent(content),
            ),
          ],
        ),
      ),
    );
  }

  /// Build HTML content by stripping tags and displaying as formatted text
  Widget _buildHtmlContent(String htmlContent) {
    final cleanText = _stripHtmlTags(htmlContent);
    final lines = cleanText.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) {
          return const SizedBox(height: 8);
        }
        
        // Check if it is a heading (all caps or starts with common heading patterns)
        final isHeading = _isHeadingLine(trimmedLine);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            trimmedLine,
            style: TextStyle(
              color: isHeading ? const Color(0xFFD4A373) : const Color(0xFF8B9CAD),
              fontSize: isHeading ? 16 : 15,
              fontWeight: isHeading ? FontWeight.bold : FontWeight.w400,
              fontFamily: 'PerifareDisplay',
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Strip HTML tags from content
  String _stripHtmlTags(String htmlText) {
    // Remove common HTML tags
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove all HTML tags
        .replaceAll('&nbsp;', ' ') // Replace non-breaking spaces
        .replaceAll('&lt;', '<') // Replace HTML entities
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim();
  }

  /// Check if a line is a heading
  bool _isHeadingLine(String line) {
    // Check for common heading patterns
    final headingPatterns = [
      RegExp(r'^[A-Z][A-Z\s]+$'), // ALL CAPS
      RegExp(r'^\d+\.\s+[A-Z]'), // Numbered list items
      RegExp(r'^[IVX]+\.\s+[A-Z]'), // Roman numerals
      RegExp(r'^[A-Z][a-z\s]+:$'), // Ends with colon
    ];
    
    return headingPatterns.any((pattern) => pattern.hasMatch(line));
  }
}