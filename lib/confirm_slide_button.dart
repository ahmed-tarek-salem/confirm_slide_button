import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A performance-optimized custom slide-to-confirm button widget.
///
/// The user slides a thumb from left to right to confirm an action.
/// While sliding, the track fills with green behind the thumb.
/// When the thumb reaches the end, [onConfirmed] is triggered.
class ConfirmSlideButton extends StatefulWidget {
  /// Callback executed when the slide is completed.
  final VoidCallback onConfirmed;

  const ConfirmSlideButton({super.key, required this.onConfirmed});

  @override
  State<ConfirmSlideButton> createState() => _ConfirmSlideButtonState();
}

class _ConfirmSlideButtonState extends State<ConfirmSlideButton>
    with SingleTickerProviderStateMixin {
  /// Current horizontal position of the draggable thumb (0 = start).
  final ValueNotifier<double> _dragPositionNotifier = ValueNotifier(0.0);

  /// Whether the user has completed the slide action.
  bool _confirmed = false;
  bool _startTextAnimation = false;

  /// Animation controller for the thumb return animation
  late AnimationController _returnAnimationController;
  late Animation<double> _returnAnimation;

  // Cached layout values
  late double _buttonWidth;
  late double _maxThumbPosition;

  // === CONFIGURATION CONSTANTS ===

  /// Total height of the track (background area).
  static const double trackHeight = 60;

  /// Size (diameter) of the draggable thumb circle.
  static const double thumbSize = 50;

  /// Horizontal padding between the draggable thumb and the green fill.
  /// Creates visual separation so the thumb appears distinct from the filled area.
  static const double greenFillThumbSpacing = 8;

  /// Leading offset to horizontally center the thumb relative to the green fill.
  /// Typically set to half of [greenFillThumbSpacing] for perfect visual balance.
  static const double thumbLeadingOffset = 4;

  /// Total horizontal margin applied to the entire button.
  /// Split evenly between left and right sides.
  static const double buttonHorizontalMargin = 40;

  /// Maximum blur intensity applied when the thumb is in the middle.
  static const double maxBlurSigma = 4.0;

  static const double confirmedButtonHeight = trackHeight * 0.8;

  @override
  void initState() {
    super.initState();

    _returnAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _returnAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _returnAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _returnAnimation.addListener(() {
      _dragPositionNotifier.value = _returnAnimation.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache expensive calculations
    _buttonWidth = MediaQuery.of(context).size.width - buttonHorizontalMargin;
    _maxThumbPosition = _buttonWidth - thumbSize - greenFillThumbSpacing;
  }

  @override
  void dispose() {
    _returnAnimationController.dispose();
    _dragPositionNotifier.dispose();
    super.dispose();
  }

  /// Animates the thumb back to the start position
  void _animateThumbReturn() {
    _returnAnimation = Tween<double>(
      begin: _dragPositionNotifier.value,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _returnAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _returnAnimationController.reset();
    _returnAnimationController.forward();
  }

  void _onDragUpdate(double deltaX) {
    // Stop any ongoing return animation when user starts dragging
    if (_returnAnimationController.isAnimating) {
      _returnAnimationController.stop();
    }

    final newPosition =
        (_dragPositionNotifier.value + deltaX).clamp(0.0, _maxThumbPosition);
    _dragPositionNotifier.value = newPosition;
  }

  void _onDragEnd() {
    // If the thumb has reached the end, trigger the confirmation callback
    if (_dragPositionNotifier.value >= _maxThumbPosition) {
      setState(() {
        _confirmed = true;
        widget.onConfirmed();
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _startTextAnimation = true;
          });
        }
      });
    }
    // Otherwise, animate the thumb back to start position
    else {
      _animateThumbReturn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('not-confirmed'),
      height: trackHeight,
      margin:
          const EdgeInsets.symmetric(horizontal: buttonHorizontalMargin / 2),
      child: Stack(
        children: [
          // === Layer 1: Background track (static gray bar behind everything) ===
          _BackgroundTrack(
            confirmed: _confirmed,
            buttonWidth: _buttonWidth,
          ),

          // === Layer 2: Green fill (dynamic progress area that grows as the thumb moves) ===
          if (!_confirmed)
            _GreenFill(
              dragPositionNotifier: _dragPositionNotifier,
            ),

          // === Layer 3: Center text (shimmer animation to draw user attention) ===
          _CenterText(
            buttonWidth: _buttonWidth,
            dragPositionNotifier: _dragPositionNotifier,
            confirmed: _confirmed,
            startTextAnimation: _startTextAnimation,
          ),

          // === Layer 4: Draggable thumb (user interaction handle) ===
          if (!_confirmed)
            _DraggableThumb(
              dragPositionNotifier: _dragPositionNotifier,
              maxThumbPosition: _maxThumbPosition,
              onDragUpdate: _onDragUpdate,
              onDragEnd: _onDragEnd,
            ),
        ],
      ),
    );
  }
}

/// Separated draggable thumb widget for performance optimization
class _DraggableThumb extends StatelessWidget {
  final ValueNotifier<double> dragPositionNotifier;
  final double maxThumbPosition;
  final Function(double) onDragUpdate;
  final VoidCallback onDragEnd;

  const _DraggableThumb({
    required this.dragPositionNotifier,
    required this.maxThumbPosition,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: dragPositionNotifier,
      builder: (context, dragPosition, child) {
        final double progress =
            (dragPosition / maxThumbPosition).clamp(0.0, 1.0);

        // Calculate blur value directly using the quadratic formula
        final double blurValue = _ConfirmSlideButtonState.maxBlurSigma *
            (4 * (progress - (progress * progress)));

        return Positioned(
          left: dragPosition + _ConfirmSlideButtonState.thumbLeadingOffset,
          top: (_ConfirmSlideButtonState.trackHeight -
                  _ConfirmSlideButtonState.thumbSize) /
              2,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
            onHorizontalDragEnd: (_) => onDragEnd(),
            child: Container(
              width: _ConfirmSlideButtonState.thumbSize,
              height: _ConfirmSlideButtonState.thumbSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff0b070a),
              ),
              child: ImageFiltered(
                imageFilter:
                    ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: progress < 0.5
                      ? const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 20,
                          key: ValueKey('arrow'),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          key: ValueKey('check'),
                          color: Colors.white,
                          size: 24,
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

/// Background track widget - only rebuilds when confirmation state changes
class _BackgroundTrack extends StatelessWidget {
  final bool confirmed;
  final double buttonWidth;

  const _BackgroundTrack({
    required this.confirmed,
    required this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        height: confirmed
            ? _ConfirmSlideButtonState.confirmedButtonHeight
            : _ConfirmSlideButtonState.trackHeight,
        width: confirmed ? buttonWidth * 0.6 : buttonWidth,
        child: Container(
          decoration: BoxDecoration(
            color:
                confirmed ? const Color(0xff4ddf69) : const Color(0xff2f2c32),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Opacity(
            opacity: !confirmed ? 0.0 : 1.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                margin: EdgeInsets.symmetric(horizontal: confirmed ? 10 : 0),
                duration: const Duration(milliseconds: 600),
                width: confirmed
                    ? _ConfirmSlideButtonState.thumbSize * 0.5
                    : _ConfirmSlideButtonState.thumbSize,
                height: confirmed
                    ? _ConfirmSlideButtonState.thumbSize * 0.5
                    : _ConfirmSlideButtonState.thumbSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff0b070a),
                ),
                child: Center(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 600),
                    scale: confirmed ? 0.67 : 1.0,
                    child: const Icon(
                      Icons.check_rounded,
                      key: ValueKey('check'),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Green fill widget - only rebuilds when drag position changes
class _GreenFill extends StatelessWidget {
  final ValueNotifier<double> dragPositionNotifier;

  const _GreenFill({
    required this.dragPositionNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: dragPositionNotifier,
      builder: (context, dragPosition, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: dragPosition +
                _ConfirmSlideButtonState.thumbSize +
                _ConfirmSlideButtonState.greenFillThumbSpacing,
            color: const Color(0xff4ddf69),
          ),
        );
      },
    );
  }
}

/// Center text widget with optimized rebuilds
class _CenterText extends StatelessWidget {
  final double buttonWidth;
  final ValueNotifier<double> dragPositionNotifier;
  final bool confirmed;
  final bool startTextAnimation;

  const _CenterText({
    required this.buttonWidth,
    required this.dragPositionNotifier,
    required this.confirmed,
    required this.startTextAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: _ConfirmSlideButtonState.trackHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gray shimmer text (right side only) - wrapped in RepaintBoundary for performance
          ValueListenableBuilder<double>(
            valueListenable: dragPositionNotifier,
            builder: (context, dragPosition, child) {
              return ClipRect(
                clipper: _HorizontalClipper(
                  left: dragPosition +
                      _ConfirmSlideButtonState.thumbSize +
                      _ConfirmSlideButtonState.greenFillThumbSpacing,
                  right: buttonWidth,
                ),
                child: RepaintBoundary(
                  child: Center(
                    child: Shimmer(
                      period: const Duration(seconds: 3),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff8f8c91),
                          Colors.white,
                          Color(0xff8f8c91),
                        ],
                        stops: [0.45, 0.50, 0.55],
                      ),
                      child: const Text(
                        "Slide to Confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Green text (left side only)
          ValueListenableBuilder<double>(
            valueListenable: dragPositionNotifier,
            builder: (context, dragPosition, child) {
              final double greenWidth =
                  dragPosition + _ConfirmSlideButtonState.thumbLeadingOffset;

              return ClipRect(
                clipper: _HorizontalClipper(
                  left: 0,
                  right: greenWidth,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: startTextAnimation
                        ? const Text(
                            "Success!",
                            key: ValueKey("success"),
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          )
                        : const Text(
                            "Confirm Process",
                            key: ValueKey("confirm"),
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom clipper for horizontal text clipping
class _HorizontalClipper extends CustomClipper<Rect> {
  final double left;
  final double right;

  const _HorizontalClipper({required this.left, required this.right});

  @override
  Rect getClip(Size size) {
    final l = left.clamp(0.0, size.width);
    final r = right.clamp(0.0, size.width);
    return Rect.fromLTRB(l, 0, r, size.height);
  }

  @override
  bool shouldReclip(covariant _HorizontalClipper oldClipper) {
    return left != oldClipper.left || right != oldClipper.right;
  }
}
