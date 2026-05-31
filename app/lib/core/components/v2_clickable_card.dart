import 'package:flutter/material.dart';
import '../theme/v2_colors.dart';

class V2ClickableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final bool isSelected;
  final Color? backgroundColor;

  const V2ClickableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.isSelected = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: backgroundColor ?? (isSelected ? V2Colors.primaryBlue.withOpacity(0.05) : V2Colors.cardBackground),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? V2Colors.primaryBlue : V2Colors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: V2Colors.primaryBlue.withOpacity(0.1),
        highlightColor: V2Colors.primaryBlue.withOpacity(0.05),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
