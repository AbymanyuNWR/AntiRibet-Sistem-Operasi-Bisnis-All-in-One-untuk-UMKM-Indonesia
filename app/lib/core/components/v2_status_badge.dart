import 'package:flutter/material.dart';
import '../theme/v2_colors.dart';
import '../theme/v2_typography.dart';

enum V2BadgeStatus {
  success, // green
  warning, // amber
  error,   // red
  info,    // blue
  neutral, // gray
}

class V2StatusBadge extends StatelessWidget {
  final String label;
  final V2BadgeStatus status;
  final IconData? icon;

  const V2StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;

    switch (status) {
      case V2BadgeStatus.success:
        backgroundColor = V2Colors.successGreen.withOpacity(0.15);
        foregroundColor = V2Colors.successGreen;
        break;
      case V2BadgeStatus.warning:
        backgroundColor = V2Colors.warningAmber.withOpacity(0.15);
        foregroundColor = V2Colors.warningAmber;
        break;
      case V2BadgeStatus.error:
        backgroundColor = V2Colors.errorRed.withOpacity(0.15);
        foregroundColor = V2Colors.errorRed;
        break;
      case V2BadgeStatus.info:
        backgroundColor = V2Colors.infoBlue.withOpacity(0.15);
        foregroundColor = V2Colors.infoBlue;
        break;
      case V2BadgeStatus.neutral:
        backgroundColor = V2Colors.border;
        foregroundColor = V2Colors.secondaryText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: V2Typography.labelSm.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
