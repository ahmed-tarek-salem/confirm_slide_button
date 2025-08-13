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

class _ConfirmSlideButtonState extends State<ConfirmSlideButton> {
  /// Current horizontal position of the draggable thumb (0 = start).
  double _dragPosition = 0.0;

  /// Whether the user has completed the slide action.
  bool _confirmed = false;
  bool _startTextAnimation = false;

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
              width: _confirmed ? buttonWidth * .7 : buttonWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: _confirmed
                      ? const Color(0xff6fe69d)
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
                color: const Color(0xff6fe69d),
              ),
            ),

          // === Layer 3: Center text (shimmer animation to draw user attention) ===
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Text inside the new green background (fade in)
                Opacity(
                  opacity: progress,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child:
                        _startTextAnimation // Change text when nearly complete
                            ? Text("Success!", key: ValueKey("success"))
                            : Text("Confirm the Process",
                                key: ValueKey("confirm")),
                  ),
                ),
                // Original text inside the base gray background (fade out)
                Opacity(
                  opacity: 1 - progress,
                  child: Shimmer(
                    period: const Duration(seconds: 3),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff8f8c91),
                        Colors.white,
                        const Color(0xff8f8c91),
                      ],
                      stops: const [
                        0.45, // start of highlight
                        0.50, // end of highlight → smaller gap = thinner highlight
                        0.55,
                      ],
                    ),
                    child: const Text("Slide to Confirm"),
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
                  setState(() {
                    _dragPosition += details.delta.dx;
                    _dragPosition = _dragPosition.clamp(0.0, maxThumbPosition);
                  });
                },
                // Handle drag end to check if confirmation is reached
                onHorizontalDragEnd: (_) {
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
                  } else {
                    setState(() {
                      _dragPosition = 0.0;
                    });
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
