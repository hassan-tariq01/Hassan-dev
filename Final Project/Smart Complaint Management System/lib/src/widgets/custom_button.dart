import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum ButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  outline,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.addAll([
        Icon(
          icon,
          size: _getIconSize(),
          color: _getTextColor(),
        ),
        SizedBox(width: _getSpacing()),
      ]);
    }

    children.add(
      Text(
        text,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getTextColor(),
      elevation: _getElevation(),
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
        side: _getBorderSide(),
      ),
      disabledBackgroundColor: _getDisabledBackgroundColor(),
      disabledForegroundColor: _getDisabledTextColor(),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return const Color(AppConstants.primaryColor);
      case ButtonType.secondary:
        return const Color(AppConstants.secondaryColor);
      case ButtonType.success:
        return const Color(AppConstants.successColor);
      case ButtonType.danger:
        return const Color(AppConstants.errorColor);
      case ButtonType.warning:
        return const Color(AppConstants.warningColor);
      case ButtonType.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.outline:
        return const Color(AppConstants.primaryColor);
      default:
        return Colors.white;
    }
  }

  Color _getDisabledBackgroundColor() {
    return Colors.grey[300]!;
  }

  Color _getDisabledTextColor() {
    return Colors.grey[600]!;
  }

  double _getElevation() {
    switch (type) {
      case ButtonType.outline:
        return 0;
      default:
        return 2;
    }
  }

  BorderSide _getBorderSide() {
    switch (type) {
      case ButtonType.outline:
        return const BorderSide(
          color: Color(AppConstants.primaryColor),
          width: 1.5,
        );
      default:
        return BorderSide.none;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 4;
      case ButtonSize.medium:
        return 8;
      case ButtonSize.large:
        return 12;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  double _getSpacing() {
    switch (size) {
      case ButtonSize.small:
        return 4;
      case ButtonSize.medium:
        return 6;
      case ButtonSize.large:
        return 8;
    }
  }
}

// Convenience constructors for common button types
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const DangerButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.danger,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const SuccessButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.success,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
} 