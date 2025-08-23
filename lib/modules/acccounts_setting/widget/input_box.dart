import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? hintColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool enabled;
  final double borderWidth;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool expands;
  final int? maxLength;
  final bool showCounter;

  const CustomInputField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.fillColor = Colors.transparent,
    this.borderColor = const Color(0xFFD4A373),
    this.focusedBorderColor = const Color(0xFFD89A58),
    this.textColor = Colors.white,
    this.hintColor = const Color(0xFF9CA3AF),
    this.textStyle,
    this.hintStyle,
    this.enabled = true,
    this.borderWidth = 1.0,
    this.focusNode,
    this.initialValue,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.expands = false,
    this.maxLength,
    this.showCounter = false,
  });

  // Factory constructor for common input types
  factory CustomInputField.email({
    Key? key,
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
  }) {
    return CustomInputField(
      key: key,
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF9CA3AF)),
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
    );
  }

  // Factory constructor for password fields
  factory CustomInputField.password({
    Key? key,
    required TextEditingController controller,
    String? hintText = 'Enter your password',
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
  }) {
    return _PasswordInputField(
      key: key,
      controller: controller,
      hintText: hintText,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
    );
  }

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _PasswordInputField extends CustomInputField {
  const _PasswordInputField({
    super.key,
    required super.controller,
    super.hintText,
    super.validator,
    super.onChanged,
    super.enabled,
  }) : super(
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF9CA3AF)),
        );
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      expands: widget.expands,
      maxLength: widget.maxLength,
      style: widget.textStyle ?? 
             TextStyle(
               color: widget.textColor,
               fontSize: 16,
               fontWeight: FontWeight.w400,
               decoration: TextDecoration.none,
             ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintStyle: widget.hintStyle ?? 
                  TextStyle(
                    color: widget.hintColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        filled: true,
        fillColor: widget.fillColor,
        contentPadding: widget.contentPadding ?? 
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
        border: _buildBorder(widget.borderColor ?? Colors.white.withValues(alpha: 0.3)),
        enabledBorder: _buildBorder(widget.borderColor ?? Colors.white.withValues(alpha: 0.3)),
        focusedBorder: _buildBorder(widget.focusedBorderColor ?? const Color(0xFFD89A58)),
        errorBorder: _buildBorder(Colors.red.shade400),
        focusedErrorBorder: _buildBorder(Colors.red.shade400, width: widget.borderWidth + 0.5),
        disabledBorder: _buildBorder((widget.borderColor ?? Colors.white.withValues(alpha: 0.3)).withValues(alpha: 0.5)),
        counterText: widget.showCounter ? null : '',
      ),
    );
  }

  InputBorder _buildBorder(Color color, {double? width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: color,
        width: width ?? widget.borderWidth,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: widget.hintColor,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}