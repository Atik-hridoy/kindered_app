import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  final double borderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const CustomCheckbox({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.height = 56.0,
    this.borderRadius = 28.0,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.hintColor,
    this.iconColor,
    this.borderWidth = 1.0,
    this.contentPadding,
    this.focusNode,
    this.textStyle,
    this.hintStyle,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Default colors matching the image design
    final defaultBackgroundColor = widget.backgroundColor ?? const Color(0xFFFAFAFA);
    final defaultBorderColor = widget.borderColor ?? const Color(0xFFE8E8E8);
    final defaultFocusedBorderColor = widget.focusedBorderColor ?? const Color(0xFFD89A58);
    final defaultTextColor = widget.textColor ?? const Color(0xFF2D3748);
    final defaultHintColor = widget.hintColor ?? const Color(0xFFA0AEC0);
    final defaultIconColor = widget.iconColor ?? const Color(0xFFA0AEC0);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _isFocused ? defaultFocusedBorderColor : defaultBorderColor,
          width: widget.borderWidth,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: defaultFocusedBorderColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        style: widget.textStyle ?? 
               TextStyle(
                 color: defaultTextColor,
                 fontSize: 16,
                 fontWeight: FontWeight.w400,
               ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ?? 
                    TextStyle(
                      color: defaultHintColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: defaultIconColor,
                  size: 20,
                )
              : null,
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixIconTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: defaultIconColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      widget.suffixIcon,
                      color: defaultIconColor,
                      size: 18,
                    ),
                  ),
                )
              : null,
          contentPadding: widget.contentPadding ?? 
                         const EdgeInsets.symmetric(
                           horizontal: 20,
                           vertical: 16,
                         ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}