import 'package:flutter/material.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({Key? key}) : super(key: key);

  @override
  _HelpSupportViewState createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _opinionController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _opinionFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _opinionController.dispose();
    _emailFocus.dispose();
    _opinionFocus.dispose();
    super.dispose();
  }

  void _sendMessage() {
    // Handle send message functionality
    if (_emailController.text.isNotEmpty && _opinionController.text.isNotEmpty) {
      // Show success message or navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent successfully!'),
          backgroundColor: Color(0xFF4A9EFF),
        ),
      );
      // Clear fields
      _emailController.clear();
      _opinionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1419),
      body: Container(
        decoration: BoxDecoration(
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Help and Support',
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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Need Help? We\'re Here for You!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Description
                      Text(
                        'Welcome to our Help & Support center. Whether you have a question, ran into a problem, or just need some guidance',
                        style: TextStyle(
                          color: Color(0xFF8B9CAD),
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      
                      SizedBox(height: 32),
                      
                      // Email Field
                      Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF8B9CAD),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF3A4B5C),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'PerifareDisplay',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(
                              color: Color(0xFF5A6B7D),
                              fontSize: 15,
                              fontFamily: 'PerifareDisplay',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Your Opinion Field
                      Text(
                        'Your opinion',
                        style: TextStyle(
                          color: Color(0xFF8B9CAD),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF3A4B5C),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _opinionController,
                          focusNode: _opinionFocus,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'PerifareDisplay',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type here',
                            hintStyle: TextStyle(
                              color: Color(0xFF5A6B7D),
                              fontSize: 15,
                              fontFamily: 'PerifareDisplay',
                            ),
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Send Message Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE8945A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Send Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PerifareDisplay',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}