import 'package:flutter/material.dart';
import '../theme/v2_colors.dart';
import '../theme/v2_typography.dart';

enum V2ButtonVariant { primary, secondary, ghost, danger }
enum V2ButtonSize { large, medium, small }

class V2Button extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final V2ButtonVariant variant;
  final V2ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const V2Button({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = V2ButtonVariant.primary,
    this.size = V2ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor = Colors.transparent;

    switch (variant) {
      case V2ButtonVariant.primary:
        backgroundColor = V2Colors.primaryBlue;
        foregroundColor = Colors.white;
        break;
      case V2ButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = V2Colors.primaryText;
        borderColor = V2Colors.border;
        break;
      case V2ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = V2Colors.primaryBlue;
        break;
      case V2ButtonVariant.danger:
        backgroundColor = V2Colors.errorRed;
        foregroundColor = Colors.white;
        break;
    }

    if (onPressed == null) {
      backgroundColor = V2Colors.border;
      foregroundColor = V2Colors.mutedText;
      borderColor = Colors.transparent;
    }

    EdgeInsets padding;
    TextStyle textStyle;
    double iconSize;

    switch (size) {
      case V2ButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        textStyle = V2Typography.labelLg;
        iconSize = 20;
        break;
      case V2ButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        textStyle = V2Typography.labelMd;
        iconSize = 18;
        break;
      case V2ButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        textStyle = V2Typography.labelSm;
        iconSize = 16;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1),
      ),
    );

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor,
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
        ],
        if (!isLoading) Text(label, style: textStyle),
      ],
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: content,
    );
  }
}
