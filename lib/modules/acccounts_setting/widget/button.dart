import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Add this import

class CustomGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final List<Color> gradientColors;
  final Gradient? customGradient;
  final TextStyle? textStyle;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final Widget? child;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Duration animationDuration;

  const CustomGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = 335.0,
    this.height = 48.0,
    this.borderRadius = 12.0,
    this.gradientColors = const [Color(0xFFD4A373), Color(0xFFB56E29)],
    this.customGradient,
    this.textStyle,
    this.textColor,
    this.padding,
    this.enabled = true,
    this.child,
    this.boxShadow,
    this.border,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomGradientButton> createState() => _CustomGradientButtonState();
}

class _CustomGradientButtonState extends State<CustomGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.enabled && widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || widget.onPressed == null;
    
    final gradient = widget.customGradient ??
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.gradientColors,
        );

    final defaultTextStyle = GoogleFonts.playfairDisplay( // <-- Use Playfair Display
      color: widget.textColor ?? Colors.white,            // <-- Use white color
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedOpacity(
              duration: widget.animationDuration,
              opacity: isDisabled ? 0.6 : 1.0,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: isDisabled
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade400,
                            Colors.grey.shade500,
                          ],
                        )
                      : gradient,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.border,
                  boxShadow: widget.boxShadow ??
                      [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        if (_isPressed)
                          BoxShadow(
                            color: widget.gradientColors.last.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                      ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isDisabled ? null : widget.onPressed,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Container(
                      padding: widget.padding ??
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                      child: Center(
                        child: widget.child ??
                            Text(
                              widget.text,
                              style: widget.textStyle ?? defaultTextStyle,
                              textAlign: TextAlign.center,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}