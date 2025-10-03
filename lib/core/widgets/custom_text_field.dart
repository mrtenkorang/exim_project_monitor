import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final bool readOnly;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;
  final Color? fillColor;
  final bool showCharacterCount;
  final String? helperText;
  final bool isRequired;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.contentPadding,
    this.filled = true,
    this.fillColor,
    this.showCharacterCount = false,
    this.helperText,
    this.isRequired = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label.isNotEmpty) ...[
              _buildLabel(theme, colorScheme),
              const SizedBox(height: 8),
            ],
            _buildTextField(theme, colorScheme),
            if (widget.helperText != null || widget.showCharacterCount) ...[
              const SizedBox(height: 4),
              _buildHelperRow(theme, colorScheme),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLabel(ThemeData theme, ColorScheme colorScheme) {
    return RichText(
      text: TextSpan(
        text: widget.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: _isFocused
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.8),
          fontWeight: FontWeight.w600,
        ),
        children: widget.isRequired
            ? [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
            : null,
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, ColorScheme colorScheme) {
    final borderColor = _hasError
        ? colorScheme.error
        : _isFocused
        ? colorScheme.primary
        : colorScheme.outline.withOpacity(0.5);

    final fillColor = widget.fillColor ??
        (_isFocused
            ? colorScheme.primaryContainer.withOpacity(0.1)
            : colorScheme.surfaceVariant.withOpacity(0.3));

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      validator: (value) {
        final error = widget.validator?.call(value);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = error != null;
            });
          }
        });
        return error;
      },
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: _internalFocusNode,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      maxLength: widget.showCharacterCount ? widget.maxLength : null,
      textCapitalization: widget.textCapitalization,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      inputFormatters: widget.inputFormatters,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: widget.enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withOpacity(0.5),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: widget.prefixIcon != null
            ? AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.prefixIcon,
            color: _isFocused
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
        )
            : null,
        suffixIcon: widget.suffixIcon,
        filled: widget.filled,
        fillColor: fillColor,
        counterText: widget.showCharacterCount ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: borderColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 12 : 16,
              vertical: widget.maxLines == 1 ? 16 : 12,
            ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHelperRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        if (widget.helperText != null)
          Expanded(
            child: Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        if (widget.showCharacterCount && widget.maxLength != null)
          Text(
            '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}

// Extension for common text field configurations
extension CustomTextFieldExtensions on CustomTextField {
  static CustomTextField email({
    Key? key,
    TextEditingController? controller,
    required String label,
    String hint = 'Enter your email',
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isRequired = false,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      textCapitalization: TextCapitalization.none,
      validator: validator ??
              (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Email is required';
            }
            if (value != null &&
                value.isNotEmpty &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }
}