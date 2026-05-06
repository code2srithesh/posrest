import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_theme.dart';
import '../constants/app_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double width;
  final Color? backgroundColor;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width = double.infinity,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: width,
          child: ElevatedButton.icon(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        isEnabled ? Colors.white : AppTheme.textLight,
                      ),
                    ),
                  )
                : (icon != null ? Icon(icon) : const SizedBox.shrink()),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppTheme.primaryColor,
              disabledBackgroundColor: AppTheme.textLight,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.forward())
        .fadeIn(duration: AppConstants.shortAnimationDuration);
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double width;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppConstants.shortAnimationDuration);
  }
}

class PosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final bool isSelected;

  const PosCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.height,
    this.width,
    this.backgroundColor,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Card(
            color: backgroundColor ?? AppTheme.cardBg,
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: AppTheme.primaryColor, width: 2)
                  : BorderSide.none,
            ),
            child: Container(
              width: width,
              height: height,
              padding: padding,
              child: child,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: AppConstants.shortAnimationDuration)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: AppConstants.shortAnimationDuration,
        );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final TextStyle? textStyle;

  const StatusBadge({Key? key, required this.status, this.textStyle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'free':
        bgColor = AppTheme.tableFreeBg;
        textColor = AppTheme.tableFreeIcon;
        break;
      case 'occupied':
        bgColor = AppTheme.tableOccupiedBg;
        textColor = AppTheme.tableOccupiedIcon;
        break;
      case 'reserved':
        bgColor = AppTheme.tableReservedBg;
        textColor = AppTheme.tableReservedIcon;
        break;
      case 'open':
        bgColor = AppTheme.infoColor.withOpacity(0.1);
        textColor = AppTheme.infoColor;
        break;
      case 'preparing':
        bgColor = AppTheme.warningColor.withOpacity(0.1);
        textColor = AppTheme.warningColor;
        break;
      case 'served':
        bgColor = AppTheme.successColor.withOpacity(0.1);
        textColor = AppTheme.successColor;
        break;
      case 'paid':
        bgColor = AppTheme.successColor.withOpacity(0.1);
        textColor = AppTheme.successColor;
        break;
      case 'cancelled':
        bgColor = AppTheme.errorColor.withOpacity(0.1);
        textColor = AppTheme.errorColor;
        break;
      default:
        bgColor = AppTheme.borderColor;
        textColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            textStyle ??
            TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? textStyle;
  final bool showDecimals;

  const CurrencyDisplay({
    Key? key,
    required this.amount,
    this.textStyle,
    this.showDecimals = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${AppConstants.currencySymbol}${showDecimals ? amount.toStringAsFixed(2) : amount.toStringAsFixed(0)}',
      style:
          textStyle ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppTheme.textLight),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}
