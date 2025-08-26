import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sprung/sprung.dart';

/// A highly customizable slide-to-confirm button widget with smooth animations.
///
/// This widget provides an intuitive slide-to-confirm interaction where users
/// must drag a thumb from left to right to complete an action. The button
/// includes visual feedback through progress filling, text transitions, and
/// optional shimmer animations.
///
/// The widget is performance-optimized using [ValueNotifier] and separated
/// render objects to minimize unnecessary rebuilds during drag operations.
///
/// Example usage:
/// ```dart
/// ConfirmSlideButton(
///   onConfirmed: () => print('Action confirmed!'),
///   initialText: 'Slide to confirm',
///   confirmingText: 'Keep sliding...',
///   completedText: 'Confirmed!',
/// )
/// ```
class ConfirmSlideButton extends StatefulWidget {
  // === Core Functionality ===

  /// Callback function executed when the slide action is completed.
  ///
  /// This function is called when the user successfully slides the thumb
  /// to the end of the track and releases it. It can be asynchronous
  /// and the button will show a loading indicator while waiting.
  final Future<void> Function() onConfirmed;

  // === Text Configuration ===

  /// Text displayed when the button is in its initial state.
  ///
  /// This text appears before the user starts interacting with the button
  /// and typically contains instructions like "Slide to confirm".
  final String initialText;

  /// Text displayed while the user is actively sliding the thumb.
  ///
  /// This text provides feedback during the sliding action and might
  /// encourage continuation like "Keep sliding..." or "Release to confirm".
  final String confirmingText;

  /// Text displayed after the action has been successfully confirmed.
  ///
  /// This text appears in the completed state and typically indicates
  /// success like "Confirmed!" or "Done!".
  final String completedText;

  /// Text style for the initial state text.
  ///
  /// If null, a default style will be applied. This style affects
  /// the appearance of [initialText].
  final TextStyle? initialTextStyle;

  /// Text style for the confirming state text.
  ///
  /// If null, a default style will be applied. This style affects
  /// the appearance of [confirmingText] during the sliding action.
  final TextStyle? confirmingTextStyle;

  /// Text style for the completed state text.
  ///
  /// If null, a default style will be applied. This style affects
  /// the appearance of [completedText] after confirmation.
  final TextStyle? completedTextStyle;

  // === Layout & Sizing ===

  /// Total height of the slide button track.
  ///
  /// This defines the overall height of the button. Must be greater than
  /// or equal to [thumbDiameter]. The difference creates vertical padding
  /// around the thumb.
  ///
  /// Defaults to 60.0.
  final double trackHeight;

  /// Diameter of the circular draggable thumb.
  ///
  /// This determines the size of the circular element that users drag
  /// across the track. Must be less than or equal to [trackHeight].
  ///
  /// Defaults to 50.0.
  final double thumbDiameter;

  /// External margin applied around the entire button.
  ///
  /// This controls spacing around the slide button. Horizontal margins
  /// affect the button's interactive width, while vertical margins only
  /// add spacing above and below.
  ///
  /// Defaults to EdgeInsets.symmetric(horizontal: 20.0).
  final EdgeInsets margin;

  /// Horizontal border width between the thumb and track edges.
  ///
  /// This creates visual spacing between the thumb and the track boundary,
  /// preventing the thumb from touching the edges. Must be non-negative.
  ///
  /// Defaults to 4.0.
  final double horizontalPadding;

  // === Colors & Appearance ===

  /// Background color of the slide track in its initial state.
  ///
  /// This is the base color of the button before any interaction.
  /// Defaults to Color(0xff2f2c32) (dark gray).
  final Color trackBackgroundColor;

  /// Color of the progress fill that follows the thumb.
  ///
  /// As the user drags the thumb, this color fills the track behind it,
  /// providing visual feedback of progress.
  /// Defaults to Colors.greenAccent.
  final Color progressFillColor;

  /// Background color of the draggable thumb.
  ///
  /// This is the base color of the circular thumb element.
  /// Defaults to Colors.black.
  final Color thumbBackgroundColor;

  // === Animation & Effects ===

  /// Whether to enable shimmer animation on the initial text.
  ///
  /// When true, the [initialText] displays a subtle shimmer effect
  /// to attract user attention. When false, static text is shown.
  ///
  /// Defaults to true.
  final bool enableShimmerAnimation;

  /// Base color for the shimmer animation effect.
  ///
  /// This is the primary color used in the shimmer gradient.
  /// Only applies when [enableShimmerAnimation] is true.
  /// Defaults to Colors.grey.
  final Color shimmerBaseColor;

  /// Highlight color for the shimmer animation effect.
  ///
  /// This creates the moving highlight in the shimmer gradient.
  /// Only applies when [enableShimmerAnimation] is true.
  /// Defaults to Colors.white.
  final Color shimmerHighlightColor;

  /// Factor by which the track height shrinks after confirmation.
  ///
  /// This creates a satisfying shrink animation when the action is completed.
  /// Must be between 0.0 and 1.0, where 1.0 means no shrinking.
  ///
  /// Defaults to 0.8 (20% height reduction).
  final double completedHeightFactor;

  /// Factor by which the button width shrinks after confirmation.
  ///
  /// This creates a horizontal shrink animation alongside the height reduction.
  /// Must be between 0.0 and 1.0, where 1.0 means no shrinking.
  ///
  /// Defaults to 0.6 (40% width reduction).
  final double completedWidthFactor;

  /// Factor by which the thumb size shrinks after confirmation.
  ///
  /// This creates a size reduction animation for the completed thumb.
  /// Must be between 0.0 and 1.0, where 1.0 means no shrinking.
  ///
  /// Defaults to 0.5 (50% size reduction).
  final double completedThumbSizeFactor;

  // === Thumb Icons/Widgets ===

  /// Widget displayed inside the thumb in its initial state.
  ///
  /// This typically shows an arrow or similar icon indicating the slide direction.
  /// The widget should be appropriately sized for the thumb diameter.
  ///
  /// Defaults to a forward arrow icon.
  final Widget initialThumbChild;

  /// Widget displayed inside the thumb after confirmation.
  ///
  /// This typically shows a checkmark or similar success indicator.
  /// The transition between [initialThumbChild] and this widget is animated.
  ///
  /// Defaults to a checkmark icon.
  final Widget completedThumbChild;

  /// Widget displayed while the action is loading.
  ///
  /// This widget is shown when the [onConfirmed] callback is called.
  /// After the [onConfirmed] is done, the [completedText] is shown.
  /// Defaults to a circular progress indicator.
  final Widget loadingIndicator;

  /// Creates a slide-to-confirm button widget.
  ///
  /// The [onConfirmed] callback is required and will be called when the user
  /// successfully completes the slide gesture. The [initialText], [confirmingText],
  /// and [completedText] parameters define the text shown in different states.
  const ConfirmSlideButton({
    super.key,
    // Core functionality (required)
    required this.onConfirmed,
    // Text content
    this.initialText = 'Slide to confirm',
    this.confirmingText = 'Confirming...',
    this.completedText = 'Confirmed!',
    // Text styling
    this.initialTextStyle,
    this.confirmingTextStyle,
    this.completedTextStyle,
    // Layout & sizing
    this.trackHeight = 60.0,
    this.thumbDiameter = 50.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 20.0),
    this.horizontalPadding = 4.0,
    // Colors & appearance
    this.trackBackgroundColor = const Color(0xff2f2c32),
    this.progressFillColor = Colors.greenAccent,
    this.thumbBackgroundColor = Colors.black,
    // Animation & effects
    this.enableShimmerAnimation = true,
    this.shimmerBaseColor = Colors.grey,
    this.shimmerHighlightColor = Colors.white,
    this.completedHeightFactor = 0.8,
    this.completedWidthFactor = 0.6,
    this.completedThumbSizeFactor = 0.5,
    // Thumb content
    this.initialThumbChild = const Icon(
      Icons.arrow_forward_ios_rounded,
      color: Colors.white,
      size: 20,
    ),
    this.completedThumbChild = const Icon(
      Icons.check_rounded,
      color: Colors.white,
      size: 24,
    ),
    this.loadingIndicator = const CircularProgressIndicator(),
  })  : assert(
          completedHeightFactor > 0 && completedHeightFactor <= 1,
          'completedHeightFactor must be between 0.0 and 1.0',
        ),
        assert(
          completedWidthFactor > 0 && completedWidthFactor <= 1,
          'completedWidthFactor must be between 0.0 and 1.0',
        ),
        assert(
          completedThumbSizeFactor > 0 && completedThumbSizeFactor <= 1,
          'completedThumbSizeFactor must be between 0.0 and 1.0',
        ),
        assert(
          horizontalPadding >= 0,
          'horizontalPadding must be non-negative',
        ),
        assert(
          trackHeight >= thumbDiameter,
          'trackHeight must be greater than or equal to thumbDiameter',
        );

  @override
  State<ConfirmSlideButton> createState() => _ConfirmSlideButtonState();
}

class _ConfirmSlideButtonState extends State<ConfirmSlideButton>
    with SingleTickerProviderStateMixin {
  /// Notifies listeners of changes to the thumb's horizontal position.
  ///
  /// Value ranges from 0.0 (start position) to [_maxThumbPosition] (end position).
  final ValueNotifier<double> _thumbPositionNotifier = ValueNotifier(0.0);

  /// Whether the slide action has been completed successfully.
  bool _isConfirmed = false;

  /// Whether to start the text transition animation after confirmation.
  bool _shouldAnimateCompletedText = false;

  /// Whether the confirmation callback is currently executing.
  bool _isLoading = false;

  /// Controls the thumb return animation when drag is released early.
  late final AnimationController _thumbReturnController;

  /// Animation for smoothly returning the thumb to start position.
  late Animation<double> _thumbReturnAnimation;

  /// Cached total width available for the button (screen width minus margins).
  late double _availableButtonWidth;

  /// Cached maximum position the thumb can reach (accounts for thumb size and padding).
  late double _maxThumbPosition;

  /// Cached height of the button in its completed/shrunk state.
  late double _completedButtonHeight;

  /// Maximum blur intensity applied to the thumb during mid-slide.
  ///
  /// This creates a dynamic blur effect that's strongest when the thumb
  /// is positioned in the middle of its travel path.
  static const double _maxBlurIntensity = 4.0;

  /// Total horizontal border space (left + right padding).
  double get _totalHorizontalPadding => widget.horizontalPadding * 2;

  @override
  void initState() {
    super.initState();

    // Pre-calculate the completed button height for animation
    _completedButtonHeight = widget.trackHeight * widget.completedHeightFactor;

    // Initialize the thumb return animation controller
    _thumbReturnController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Set up the initial animation (will be reconfigured when needed)
    _thumbReturnAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _thumbReturnController,
      curve: Curves.easeOutCubic,
    ));

    // Connect the animation to the thumb position notifier
    _thumbReturnAnimation.addListener(() {
      _thumbPositionNotifier.value = _thumbReturnAnimation.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Cache expensive layout calculations
    final totalHorizontalMargin = widget.margin.left + widget.margin.right;
    _availableButtonWidth =
        MediaQuery.of(context).size.width - totalHorizontalMargin;
    _maxThumbPosition =
        _availableButtonWidth - widget.thumbDiameter - _totalHorizontalPadding;
  }

  @override
  void dispose() {
    _thumbReturnController.dispose();
    _thumbPositionNotifier.dispose();
    super.dispose();
  }

  /// Smoothly animates the thumb back to its starting position.
  ///
  /// This is called when the user releases the thumb before reaching
  /// the end of the track, providing visual feedback that the action
  /// was not completed.
  void _animateThumbToStart() {
    _thumbReturnAnimation = Tween<double>(
      begin: _thumbPositionNotifier.value,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _thumbReturnController,
      curve: Sprung.criticallyDamped,
    ));

    _thumbReturnController.reset();
    _thumbReturnController.forward();
  }

  /// Handles continuous drag updates from user input.
  ///
  /// [deltaX] represents the horizontal change in position since the last update.
  /// The thumb position is clamped to valid bounds to prevent overflow.
  void _handleDragUpdate(double deltaX) {
    // Stop any ongoing return animation when user starts dragging
    if (_thumbReturnController.isAnimating) {
      _thumbReturnController.stop();
    }

    // Update position within valid bounds
    final newPosition =
        (_thumbPositionNotifier.value + deltaX).clamp(0.0, _maxThumbPosition);
    _thumbPositionNotifier.value = newPosition;
  }

  /// Handles the end of a drag gesture.
  ///
  /// If the thumb has reached the maximum position, the confirmation is triggered.
  /// Otherwise, the thumb animates back to the start position.
  Future<void> _handleDragEnd() async {
    if (_thumbPositionNotifier.value >= _maxThumbPosition) {
      // Set loading state
      setState(() {
        _isLoading = true;
      });

      // Execute the confirmation callback
      try {
        await widget.onConfirmed();
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isConfirmed = true;
            _shouldAnimateCompletedText = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _animateThumbToStart();
        }
      }
    } else {
      // Return thumb to start position
      _animateThumbToStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.trackHeight,
      margin: widget.margin,
      child: Stack(
        children: [
          // Layer 1: Background track with completion animation
          _TrackBackground(
            isConfirmed: _isConfirmed,
            availableWidth: _availableButtonWidth,
            completedHeight: _completedButtonHeight,
            trackHeight: widget.trackHeight,
            thumbDiameter: widget.thumbDiameter,
            progressFillColor: widget.progressFillColor,
            trackBackgroundColor: widget.trackBackgroundColor,
            thumbBackgroundColor: widget.thumbBackgroundColor,
            completedThumbChild: widget.completedThumbChild,
            completedWidthFactor: widget.completedWidthFactor,
            completedThumbSizeFactor: widget.completedThumbSizeFactor,
          ),

          // Layer 2: Progress fill that follows the thumb
          if (!_isConfirmed)
            _ProgressFillIndicator(
              thumbPositionNotifier: _thumbPositionNotifier,
              thumbDiameter: widget.thumbDiameter,
              progressFillColor: widget.progressFillColor,
              totalPadding: _totalHorizontalPadding,
            ),

          // Layer 3: Text overlay with state transitions
          _TextOverlay(
            availableWidth: _availableButtonWidth,
            thumbPositionNotifier: _thumbPositionNotifier,
            isConfirmed: _isConfirmed,
            shouldAnimateCompletedText: _shouldAnimateCompletedText,
            isLoading: _isLoading,
            trackHeight: widget.trackHeight,
            thumbDiameter: widget.thumbDiameter,
            totalPadding: _totalHorizontalPadding,
            paddingOffset: widget.horizontalPadding,
            initialText: widget.initialText,
            confirmingText: widget.confirmingText,
            completedText: widget.completedText,
            initialTextStyle: widget.initialTextStyle,
            confirmingTextStyle: widget.confirmingTextStyle,
            completedTextStyle: widget.completedTextStyle,
            enableShimmerAnimation: widget.enableShimmerAnimation,
            shimmerBaseColor: widget.shimmerBaseColor,
            shimmerHighlightColor: widget.shimmerHighlightColor,
            loadingIndicator: widget.loadingIndicator,
          ),

          // Layer 4: Interactive draggable thumb
          if (!_isConfirmed)
            _DraggableThumb(
              thumbPositionNotifier: _thumbPositionNotifier,
              maxThumbPosition: _maxThumbPosition,
              onDragUpdate: _handleDragUpdate,
              onDragEnd: _handleDragEnd,
              trackHeight: widget.trackHeight,
              thumbDiameter: widget.thumbDiameter,
              horizontalPadding: widget.horizontalPadding,
              thumbBackgroundColor: widget.thumbBackgroundColor,
              initialThumbChild: widget.initialThumbChild,
              completedThumbChild: widget.completedThumbChild,
            ),
        ],
      ),
    );
  }
}

/// Renders the draggable thumb with gesture handling and visual effects.
///
/// This widget is separated for performance optimization, rebuilding only
/// when the thumb position changes during drag operations.
class _DraggableThumb extends StatelessWidget {
  /// Notifies of changes to the thumb's horizontal position.
  final ValueNotifier<double> thumbPositionNotifier;

  /// Maximum horizontal position the thumb can reach.
  final double maxThumbPosition;

  /// Callback for handling drag update events.
  final Function(double) onDragUpdate;

  /// Callback for handling drag end events.
  final VoidCallback onDragEnd;

  /// Total height of the track container.
  final double trackHeight;

  /// Diameter of the circular thumb.
  final double thumbDiameter;

  /// Horizontal padding from track edges.
  final double horizontalPadding;

  /// Background color of the thumb circle.
  final Color thumbBackgroundColor;

  /// Widget displayed inside the thumb initially.
  final Widget initialThumbChild;

  /// Widget displayed inside the thumb when nearly complete.
  final Widget completedThumbChild;

  const _DraggableThumb({
    required this.thumbPositionNotifier,
    required this.maxThumbPosition,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.trackHeight,
    required this.thumbDiameter,
    required this.horizontalPadding,
    required this.thumbBackgroundColor,
    required this.initialThumbChild,
    required this.completedThumbChild,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: thumbPositionNotifier,
      builder: (context, thumbPosition, child) {
        // Calculate progress ratio (0.0 to 1.0)
        final double progressRatio =
            (thumbPosition / maxThumbPosition).clamp(0.0, 1.0);

        // Apply quadratic blur effect (strongest in middle of travel)
        final double blurIntensity =
            _ConfirmSlideButtonState._maxBlurIntensity *
                (4 * (progressRatio - (progressRatio * progressRatio)));

        return Positioned(
          left: thumbPosition + horizontalPadding,
          top: (trackHeight - thumbDiameter) / 2,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
            onHorizontalDragEnd: (_) => onDragEnd(),
            child: Container(
              width: thumbDiameter,
              height: thumbDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: thumbBackgroundColor,
              ),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurIntensity,
                  sigmaY: blurIntensity,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: progressRatio < 0.5
                      ? SizedBox(
                          key: const ValueKey('initial-thumb'),
                          child: initialThumbChild)
                      : SizedBox(
                          key: const ValueKey('completed-thumb'),
                          child: completedThumbChild),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Renders the background track with completion state animations.
///
/// This widget handles the visual transformation that occurs when the
/// slide action is completed, including size changes and color transitions.
class _TrackBackground extends StatelessWidget {
  /// Whether the slide action has been completed.
  final bool isConfirmed;

  /// Total available width for the button.
  final double availableWidth;

  /// Height of the track in its completed state.
  final double completedHeight;

  /// Height of the track in its normal state.
  final double trackHeight;

  /// Diameter of the thumb element.
  final double thumbDiameter;

  /// Color for the progress fill and completed background.
  final Color progressFillColor;

  /// Background color of the track in its initial state.
  final Color trackBackgroundColor;

  /// Background color of the thumb container.
  final Color thumbBackgroundColor;

  /// Widget to display inside the completed thumb.
  final Widget completedThumbChild;

  /// Factor by which width shrinks after completion.
  final double completedWidthFactor;

  /// Factor by which thumb size shrinks after completion.
  final double completedThumbSizeFactor;

  const _TrackBackground({
    required this.isConfirmed,
    required this.availableWidth,
    required this.completedHeight,
    required this.trackHeight,
    required this.thumbDiameter,
    required this.progressFillColor,
    required this.trackBackgroundColor,
    required this.completedThumbChild,
    required this.completedWidthFactor,
    required this.completedThumbSizeFactor,
    required this.thumbBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        height: isConfirmed ? completedHeight : trackHeight,
        width: isConfirmed
            ? availableWidth * completedWidthFactor
            : availableWidth,
        child: Container(
          decoration: BoxDecoration(
            color: isConfirmed ? progressFillColor : trackBackgroundColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Opacity(
            opacity: isConfirmed ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                margin: EdgeInsets.symmetric(horizontal: isConfirmed ? 10 : 0),
                duration: const Duration(milliseconds: 600),
                width: isConfirmed
                    ? thumbDiameter * completedThumbSizeFactor
                    : thumbDiameter,
                height: isConfirmed
                    ? thumbDiameter * completedThumbSizeFactor
                    : thumbDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: thumbBackgroundColor,
                ),
                child: Center(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 600),
                    scale: isConfirmed ? completedThumbSizeFactor : 1.0,
                    child: completedThumbChild,
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

/// Renders the progress fill that follows the thumb during drag operations.
///
/// This provides immediate visual feedback showing how much of the slide
/// action has been completed.
class _ProgressFillIndicator extends StatelessWidget {
  /// Notifies of changes to the thumb position.
  final ValueNotifier<double> thumbPositionNotifier;

  /// Diameter of the thumb element.
  final double thumbDiameter;

  /// Color of the progress fill.
  final Color progressFillColor;

  /// Total horizontal padding (left + right).
  final double totalPadding;

  const _ProgressFillIndicator({
    required this.thumbPositionNotifier,
    required this.thumbDiameter,
    required this.progressFillColor,
    required this.totalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: thumbPositionNotifier,
      builder: (context, thumbPosition, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: thumbPosition + thumbDiameter + totalPadding,
            color: progressFillColor,
          ),
        );
      },
    );
  }
}

/// Manages the text overlay with state-based content and animations.
///
/// This widget handles the complex text rendering logic, including
/// clipping regions, shimmer effects, and state transitions.
class _TextOverlay extends StatelessWidget {
  /// Total available width for text rendering.
  final double availableWidth;

  /// Notifies of thumb position changes.
  final ValueNotifier<double> thumbPositionNotifier;

  /// Whether the action has been confirmed.
  final bool isConfirmed;

  /// Whether the confirmation action is currently loading.
  final bool isLoading;

  /// Whether to show the completed text animation.
  final bool shouldAnimateCompletedText;

  /// Height of the track container.
  final double trackHeight;

  /// Diameter of the thumb element.
  final double thumbDiameter;

  /// Total horizontal padding applied.
  final double totalPadding;

  /// Single-side padding offset for positioning.
  final double paddingOffset;

  // Text content
  final String initialText;
  final String confirmingText;
  final String completedText;
  final Widget loadingIndicator;

  // Text styling
  final TextStyle? initialTextStyle;
  final TextStyle? confirmingTextStyle;
  final TextStyle? completedTextStyle;

  // Shimmer configuration
  final bool enableShimmerAnimation;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  const _TextOverlay({
    required this.availableWidth,
    required this.thumbPositionNotifier,
    required this.isConfirmed,
    required this.shouldAnimateCompletedText,
    required this.isLoading,
    required this.trackHeight,
    required this.thumbDiameter,
    required this.totalPadding,
    required this.paddingOffset,
    required this.initialText,
    required this.confirmingText,
    required this.completedText,
    required this.loadingIndicator,
    required this.initialTextStyle,
    required this.confirmingTextStyle,
    required this.completedTextStyle,
    required this.enableShimmerAnimation,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: availableWidth,
      height: trackHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Shimmer text in unfilled region (right side)
          ValueListenableBuilder<double>(
            valueListenable: thumbPositionNotifier,
            builder: (context, thumbPosition, child) {
              return ClipRect(
                clipper: _HorizontalRegionClipper(
                  leftBound: thumbPosition + thumbDiameter + totalPadding,
                  rightBound: availableWidth,
                ),
                child: RepaintBoundary(
                  child: Center(
                    child: enableShimmerAnimation
                        ? Shimmer(
                            period: const Duration(seconds: 3),
                            gradient: LinearGradient(
                              colors: [
                                shimmerBaseColor,
                                shimmerHighlightColor,
                                shimmerBaseColor,
                              ],
                              stops: const [0.45, 0.50, 0.55],
                            ),
                            child: Text(
                              initialText,
                              style: initialTextStyle,
                            ),
                          )
                        : Text(
                            initialText,
                            style: initialTextStyle,
                          ),
                  ),
                ),
              );
            },
          ),

          // Text in filled region (left side)
          ValueListenableBuilder<double>(
            valueListenable: thumbPositionNotifier,
            builder: (context, thumbPosition, child) {
              final double fillWidth = thumbPosition + paddingOffset;

              return ClipRect(
                clipper: _HorizontalRegionClipper(
                  leftBound: 0,
                  rightBound: fillWidth,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? loadingIndicator
                        : shouldAnimateCompletedText
                            ? Text(
                                completedText,
                                key: const ValueKey("completed-text"),
                                style: completedTextStyle,
                              )
                            : Text(
                                confirmingText,
                                key: const ValueKey("confirming-text"),
                                style: confirmingTextStyle,
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

/// Custom clipper for creating horizontal text clipping regions.
///
/// This clipper is used to create the effect where different text appears
/// in the filled vs unfilled portions of the slide button.
class _HorizontalRegionClipper extends CustomClipper<Rect> {
  /// Left boundary of the clipping region.
  final double leftBound;

  /// Right boundary of the clipping region.
  final double rightBound;

  const _HorizontalRegionClipper({
    required this.leftBound,
    required this.rightBound,
  });

  @override
  Rect getClip(Size size) {
    final left = leftBound.clamp(0.0, size.width);
    final right = rightBound.clamp(0.0, size.width);
    return Rect.fromLTRB(left, 0, right, size.height);
  }

  @override
  bool shouldReclip(covariant _HorizontalRegionClipper oldClipper) {
    return leftBound != oldClipper.leftBound ||
        rightBound != oldClipper.rightBound;
  }
}
