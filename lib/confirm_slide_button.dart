import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A custom slide-to-confirm button widget.
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
  double _dragPosition = 0.0;

  /// Whether the user has completed the slide action.
  bool _confirmed = false;
  bool _startTextAnimation = false;

  /// Animation controller for the thumb return animation
  late AnimationController _returnAnimationController;
  late Animation<double> _returnAnimation;

  // === CONFIGURATION CONSTANTS ===

  /// Total height of the track (background area).
  static const double trackHeight = 60;

  /// Size (diameter) of the draggable thumb circle.
  static const double thumbSize = 50;

  /// Horizontal padding between the draggable thumb and the green fill.
  /// Creates visual separation so the thumb appears distinct from the filled area.
  static const double greenFillThumbSpacing = 12;

  /// Leading offset to horizontally center the thumb relative to the green fill.
  /// Typically set to half of [greenFillThumbSpacing] for perfect visual balance.
  static const double thumbLeadingOffset = 6;

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
      setState(() {
        _dragPosition = _returnAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _returnAnimationController.dispose();
    super.dispose();
  }

  /// Animates the thumb back to the start position
  void _animateThumbReturn() {
    _returnAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _returnAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _returnAnimationController.reset();
    _returnAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Total available width for sliding, excluding side margins.
    final double buttonWidth =
        MediaQuery.of(context).size.width - buttonHorizontalMargin;

    // Maximum position the thumb can slide to without overshooting the track.
    final double maxThumbPosition =
        buttonWidth - thumbSize - greenFillThumbSpacing;

    final double progress = (_dragPosition / maxThumbPosition).clamp(0.0, 1.0);

    // Calculate blur that peaks at 50% progress and is 0 at the start/end.
    // The formula 4 * (x - x^2) creates a parabolic curve that is 0 at x=0 and x=1, and 1 at x=0.5.
    final double blurValue =
        maxBlurSigma * (4 * (progress - (progress * progress)));

    final double greenWidth = _dragPosition + thumbLeadingOffset;

    return Container(
      key: ValueKey('not-confirmed'),
      height: trackHeight,
      margin:
          const EdgeInsets.symmetric(horizontal: buttonHorizontalMargin / 2),
      child: Stack(
        children: [
          // === Layer 1: Background track (static gray bar behind everything) ===
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600), // Animate size only
              height: _confirmed ? confirmedButtonHeight : trackHeight,
              width: _confirmed ? buttonWidth * .6 : buttonWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: _confirmed
                      ? const Color(0xff4ddf69)
                      : const Color(0xff2f2c32),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Opacity(
                  opacity: !_confirmed ? 0.0 : 1.0, // Fade out when confirmed
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedContainer(
                        margin: EdgeInsets.symmetric(
                            horizontal: _confirmed ? 10 : 0),
                        duration: const Duration(milliseconds: 600),
                        width: _confirmed ? thumbSize * .5 : thumbSize,
                        height: _confirmed ? thumbSize * .5 : thumbSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff0b070a),
                        ),
                        child: Center(
                            child: AnimatedScale(
                          duration: Duration(milliseconds: 600),
                          scale: _confirmed ? 0.67 : 1.0,
                          child: Icon(
                            Icons.check_rounded,
                            key: ValueKey('check'),
                            color: Colors.white,
                            size: 24, // Keep base size constant
                          ),
                        ))),
                  ),
                ),
              ),
            ),
          ),

          // === Layer 2: Green fill (dynamic progress area that grows as the thumb moves) ===
          if (!_confirmed)
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: _dragPosition + thumbSize + greenFillThumbSpacing,
                color: const Color(0xff4ddf69),
              ),
            ),

          // === Layer 3: Center text (shimmer animation to draw user attention) ===
          SizedBox(
            width: buttonWidth,
            height: trackHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gray shimmer text (right side only)
                ClipRect(
                  clipper: _HorizontalClipper(
                    left: _dragPosition + thumbSize + greenFillThumbSpacing,
                    right: buttonWidth,
                  ),
                  child: Center(
                    child: Shimmer(
                      period: const Duration(seconds: 3),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff8f8c91),
                          Colors.white,
                          Color(0xff8f8c91),
                        ],
                        stops: [
                          0.45,
                          0.50,
                          0.55,
                        ],
                      ),
                      child: const Text(
                        "Slide to Confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // Green text (left side only)
                ClipRect(
                  clipper: _HorizontalClipper(
                    left: 0,
                    right: greenWidth,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _startTextAnimation
                          ? const Text(
                              "Success!",
                              key: ValueKey("success"),
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            )
                          : const Text(
                              "Confirm the Process",
                              key: ValueKey("confirm"),
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === Layer 4: Draggable thumb (user interaction handle) ===

          if (!_confirmed)
            Positioned(
              left: _dragPosition + thumbLeadingOffset,
              top: (trackHeight - thumbSize) / 2, // Center vertically
              child: GestureDetector(
                // Handle thumb movement while dragging
                onHorizontalDragUpdate: (details) {
                  // Stop any ongoing return animation when user starts dragging
                  if (_returnAnimationController.isAnimating) {
                    _returnAnimationController.stop();
                  }

                  setState(() {
                    _dragPosition += details.delta.dx;
                    _dragPosition = _dragPosition.clamp(0.0, maxThumbPosition);
                  });
                },

                onHorizontalDragEnd: (_) {
                  // If the thumb has reached the end, trigger the confirmation callback
                  if (_dragPosition >= maxThumbPosition) {
                    setState(() {
                      _confirmed = true;
                      widget.onConfirmed();
                    });
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        _startTextAnimation = true;
                      });
                    });
                  }
                  // Otherwise, animate the thumb back to start position
                  else {
                    _animateThumbReturn();
                  }
                },
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
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
                          : Icon(Icons.check_rounded,
                              key: ValueKey('check'),
                              color: Colors.white,
                              size: 24),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
