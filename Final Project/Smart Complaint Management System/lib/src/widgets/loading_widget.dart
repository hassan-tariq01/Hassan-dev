import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
}

enum LoadingSize {
  small,
  medium,
  large,
}

class LoadingWidget extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final String? message;
  final Color? color;
  final bool isFullScreen;
  final Widget? child;

  const LoadingWidget({
    Key? key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.message,
    this.color,
    this.isFullScreen = false,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return _buildFullScreenLoading();
    }

    return _buildInlineLoading();
  }

  Widget _buildFullScreenLoading() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoadingIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            style: TextStyle(
              fontSize: _getMessageFontSize(),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    switch (type) {
      case LoadingType.circular:
        return CircularProgressIndicator(
          strokeWidth: _getStrokeWidth(),
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? const Color(AppConstants.primaryColor),
          ),
        );
      case LoadingType.linear:
        return SizedBox(
          width: _getLinearWidth(),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? const Color(AppConstants.primaryColor),
            ),
          ),
        );
      case LoadingType.dots:
        return _buildDotsAnimation();
      case LoadingType.pulse:
        return _buildPulseAnimation();
    }
  }

  Widget _buildDotsAnimation() {
    return SizedBox(
      width: _getDotsWidth(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 200)),
            builder: (context, value, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: _getDotSize(),
                height: _getDotSize(),
                decoration: BoxDecoration(
                  color: (color ?? const Color(AppConstants.primaryColor))
                      .withOpacity(value),
                  shape: BoxShape.circle,
                ),
              );
            },
            onEnd: () {
              // Restart animation
            },
          );
        }),
      ),
    );
  }

  Widget _buildPulseAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: _getPulseSize(),
            height: _getPulseSize(),
            decoration: BoxDecoration(
              color: (color ?? const Color(AppConstants.primaryColor))
                  .withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: _getPulseSize() * 0.6,
                height: _getPulseSize() * 0.6,
                decoration: BoxDecoration(
                  color: color ?? const Color(AppConstants.primaryColor),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }

  double _getLinearWidth() {
    switch (size) {
      case LoadingSize.small:
        return 100;
      case LoadingSize.medium:
        return 150;
      case LoadingSize.large:
        return 200;
    }
  }

  double _getDotsWidth() {
    switch (size) {
      case LoadingSize.small:
        return 40;
      case LoadingSize.medium:
        return 60;
      case LoadingSize.large:
        return 80;
    }
  }

  double _getDotSize() {
    switch (size) {
      case LoadingSize.small:
        return 6;
      case LoadingSize.medium:
        return 8;
      case LoadingSize.large:
        return 10;
    }
  }

  double _getPulseSize() {
    switch (size) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 30;
      case LoadingSize.large:
        return 40;
    }
  }

  double _getMessageFontSize() {
    switch (size) {
      case LoadingSize.small:
        return 12;
      case LoadingSize.medium:
        return 14;
      case LoadingSize.large:
        return 16;
    }
  }
}

// Convenience widgets for common loading scenarios
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final LoadingType type;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.type = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      type: type,
      size: LoadingSize.large,
      message: message,
      isFullScreen: true,
    );
  }
}

class SmallLoading extends StatelessWidget {
  final String? message;
  final LoadingType type;

  const SmallLoading({
    Key? key,
    this.message,
    this.type = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      type: type,
      size: LoadingSize.small,
      message: message,
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          FullScreenLoading(
            message: loadingMessage,
          ),
      ],
    );
  }
} 