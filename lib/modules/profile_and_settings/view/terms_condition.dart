import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/terms_condition_controller.dart';

class TermsConditionView extends GetView<TermsConditionController> {
  const TermsConditionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF2E3A59),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E3A59),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text(
            'Terms & Privacy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {Get.back();},
          ),
          bottom: TabBar(
            onTap: (index) {
              controller.switchTab(index == 0 ? 'terms' : 'privacy');
            },
            indicatorColor: const Color(0xFFD4A373),
            labelColor: const Color(0xFFD4A373),
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(
                text: 'Terms of Service',
                icon: Icon(Icons.description),
              ),
              Tab(
                text: 'Privacy Policy',
                icon: Icon(Icons.security),
              ),
            ],
          ),
        ),
      body: Obx(() {
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
          content: controller.currentContent,
          currentTab: controller.currentTab.value,
        );
      }),
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
            Text(
              'Oops! Something went wrong',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'PlayfairDisplay',
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
  final String currentTab;

  const _ContentState({
    required this.content,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF21293F),
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
              child: Row(
                children: [
                  Icon(
                    currentTab == 'terms' ? Icons.description : Icons.security,
                    color: const Color(0xFFD4A373),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentTab == 'terms' 
                          ? 'Terms of Service' 
                          : 'Privacy Policy',
                      style: const TextStyle(
                        color: Color(0xFFD4A373),
                        fontSize: 18,
                        fontFamily: 'PlayfairDisplay',
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
                color: const Color(0xFF21293F),
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
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}