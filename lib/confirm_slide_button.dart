import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A performance-optimized custom slide-to-confirm button widget.
///
/// The user slides a thumb from left to right to confirm an action.
/// While sliding, the track fills with [fillColor] behind the thumb.
/// When the thumb reaches the end, [onConfirmed] is triggered.
class ConfirmSlideButton extends StatefulWidget {
  /// Callback executed when the slide is completed.
  final VoidCallback onConfirmed;

  /// Total height of the track (background area).
  /// Must be greater than or equal to [thumbSize].
  /// The differnce between [trackHeight] and [thumbSize] determines the vertical border space.
  ///
  /// Defaults to 60.
  final double trackHeight;

  /// Factor to shrink the track height when the user confirms.
  /// Must be between 0 and 1.
  ///
  /// Defaults to 0.8.
  final double shrinkedTrackHeightFactor;

  /// Size (diameter) of the draggable thumb circle.
  ///
  /// Defaults to 50.
  final double thumbSize;

  /// Color of the draggable thumb.
  final Color thumbColor;

  /// Color of the progress fill.
  final Color fillColor;

  /// Margin around the entire button.
  ///
  /// This controls the spacing around the slide button.
  /// Only horizontal margins (left/right) affect the button's interactive width.
  /// Vertical margins only add spacing above/below the button.
  ///
  /// Defaults to EdgeInsets.symmetric(horizontal: 20).
  final EdgeInsets margin;

  /// Horizontal border width between the thumb and the progress fill.
  ///
  /// Defaults to 4.0.
  final double thumbHorizontalBorderWidth;

  /// Text displayed before confirmation (when the user hasn't started sliding).
  final String beforeConfirmText;

  /// Text displayed during confirmation (when the user is sliding).
  final String duringConfirmText;

  /// Text displayed after confirmation (when the user has confirmed).
  final String afterConfirmText;

  final TextStyle? beforeConfirmTextStyle;
  final TextStyle? duringConfirmTextStyle;
  final TextStyle? afterConfirmTextStyle;

  final Color baseShimmerColor;
  final Color highlightShimmerColor;

  final bool hasShimmerAnimation;

  final Color thumbContainerColor;

  final Color trackBackgroundColor;

  final double buttonWidthShrinkageFactor;
  final double thumbSizeShrinkageFactor;

  /// Optional widgets to display inside the thumb before and after confirmation.
  /// If not provided, default icons will be used.
  ///
  /// The transition between the widgets will be animated.
  final Widget startThumbWidget;
  final Widget endThumbWidget;

  const ConfirmSlideButton({
    super.key,
    required this.onConfirmed,
    required this.beforeConfirmText,
    required this.duringConfirmText,
    required this.afterConfirmText,
    this.beforeConfirmTextStyle,
    this.duringConfirmTextStyle,
    this.afterConfirmTextStyle,
    this.trackHeight = 60,
    this.shrinkedTrackHeightFactor = 0.8,
    this.thumbSize = 50,
    this.fillColor = Colors.greenAccent,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.thumbHorizontalBorderWidth = 4.0,
    this.baseShimmerColor = Colors.grey,
    this.highlightShimmerColor = Colors.white,
    this.hasShimmerAnimation = true,
    this.thumbContainerColor = Colors.black,
    this.trackBackgroundColor = const Color(0xff2f2c32),
    this.startThumbWidget = const Icon(Icons.arrow_forward_ios_rounded,
        color: Colors.white, size: 20),
    this.endThumbWidget =
        const Icon(Icons.check_rounded, color: Colors.white, size: 24),
    this.thumbColor = Colors.black,
    this.buttonWidthShrinkageFactor = 0.6,
    this.thumbSizeShrinkageFactor = 0.5,
  })  : assert(shrinkedTrackHeightFactor > 0 && shrinkedTrackHeightFactor <= 1,
            'shrinkedTrackHeightFactor must be between 0 and 1'),
        assert(thumbHorizontalBorderWidth >= 0,
            'borderSpace must be non-negative'),
        assert(trackHeight >= thumbSize,
            'trackHeight must be greater than or equal to thumbSize'),
        assert(
            buttonWidthShrinkageFactor >= 0 && buttonWidthShrinkageFactor <= 1,
            'buttonWidthShrinkageFactor must be between 0 and 1'),
        assert(thumbSizeShrinkageFactor >= 0 && thumbSizeShrinkageFactor <= 1,
            'thumbSizeShrinkageFactor must be between 0 and 1');

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
  late final AnimationController _returnAnimationController;
  late Animation<double> _returnAnimation;

  // Cached layout values
  late final double _buttonWidth;
  late final double _maxThumbPosition;
  late final double confirmedButtonHeight;

  /// Maximum blur intensity applied when the thumb is in the middle.
  static const double maxBlurSigma = 4.0;

  /// For left and right thumb border width
  double get thumbBorderWidthDoubled => widget.thumbHorizontalBorderWidth * 2;

  @override
  void initState() {
    super.initState();

    confirmedButtonHeight =
        widget.trackHeight * widget.shrinkedTrackHeightFactor;
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
    // Cache expensive calculations - use the actual horizontal margin from EdgeInsets
    final horizontalMargin = widget.margin.left + widget.margin.right;
    _buttonWidth = MediaQuery.of(context).size.width - horizontalMargin;
    _maxThumbPosition =
        _buttonWidth - widget.thumbSize - thumbBorderWidthDoubled;
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
      height: widget.trackHeight,
      margin: widget.margin, // Use the customizable margin
      child: Stack(
        children: [
          // === Layer 1: Background track (static gray bar behind everything) ===
          _BackgroundTrack(
            confirmed: _confirmed,
            buttonWidth: _buttonWidth,
            confirmedButtonHeight: confirmedButtonHeight,
            trackHeight: widget.trackHeight,
            thumbSize: widget.thumbSize,
            fillColor: widget.fillColor,
            thumbContainerColor: widget.thumbContainerColor,
            trackBackgroundColor: widget.trackBackgroundColor,
            endThumbWidget: widget.endThumbWidget,
            buttonWidthShrinkageFactor: widget.buttonWidthShrinkageFactor,
            thumbSizeShrinkageFactor: widget.thumbSizeShrinkageFactor,
          ),

          // === Layer 2: Progress fill (dynamic progress area that grows as the thumb moves) ===
          if (!_confirmed)
            _ProgressFill(
              dragPositionNotifier: _dragPositionNotifier,
              thumbSize: widget.thumbSize,
              fillColor: widget.fillColor,
              thumbSpacing: thumbBorderWidthDoubled,
            ),

          // === Layer 3: Center text (shimmer animation to draw user attention) ===
          _CenterText(
            buttonWidth: _buttonWidth,
            dragPositionNotifier: _dragPositionNotifier,
            confirmed: _confirmed,
            startTextAnimation: _startTextAnimation,
            trackHeight: widget.trackHeight,
            thumbSize: widget.thumbSize,
            thumbSpacing: thumbBorderWidthDoubled,
            thumbLeadingOffset: widget.thumbHorizontalBorderWidth,
            beforeConfirmText: widget.beforeConfirmText,
            duringConfirmText: widget.duringConfirmText,
            afterConfirmText: widget.afterConfirmText,
            afterConfirmTextStyle: widget.afterConfirmTextStyle,
            beforeConfirmTextStyle: widget.beforeConfirmTextStyle,
            duringConfirmTextStyle: widget.duringConfirmTextStyle,
            baseShimmerColor: widget.baseShimmerColor,
            highlightShimmerColor: widget.highlightShimmerColor,
            hasShimmerAnimation: widget.hasShimmerAnimation,
          ),

          // === Layer 4: Draggable thumb (user interaction handle) ===
          if (!_confirmed)
            _DraggableThumb(
              dragPositionNotifier: _dragPositionNotifier,
              maxThumbPosition: _maxThumbPosition,
              onDragUpdate: _onDragUpdate,
              onDragEnd: _onDragEnd,
              trackHeight: widget.trackHeight,
              thumbSize: widget.thumbSize,
              thumbBorderWidth: widget.thumbHorizontalBorderWidth,
              endThumbWidget: widget.endThumbWidget,
              startThumbWidget: widget.startThumbWidget,
              thumbColor: widget.thumbColor,
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
  final double trackHeight;
  final double thumbSize;
  final double thumbBorderWidth;
  final Widget startThumbWidget;
  final Widget endThumbWidget;
  final Color thumbColor;

  const _DraggableThumb({
    required this.dragPositionNotifier,
    required this.maxThumbPosition,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.trackHeight,
    required this.thumbSize,
    required this.thumbBorderWidth,
    required this.startThumbWidget,
    required this.endThumbWidget,
    required this.thumbColor,
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
          left: dragPosition + thumbBorderWidth,
          top: (trackHeight - thumbSize) / 2,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
            onHorizontalDragEnd: (_) => onDragEnd(),
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: thumbColor,
              ),
              child: ImageFiltered(
                imageFilter:
                    ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: progress < 0.5 ? startThumbWidget : endThumbWidget,
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
  final double confirmedButtonHeight;
  final double trackHeight;
  final double thumbSize;
  final Color fillColor;
  final Color thumbContainerColor;
  final Color trackBackgroundColor;
  final Widget endThumbWidget;
  final double buttonWidthShrinkageFactor;
  final double thumbSizeShrinkageFactor;

  const _BackgroundTrack({
    required this.confirmed,
    required this.buttonWidth,
    required this.confirmedButtonHeight,
    required this.trackHeight,
    required this.thumbSize,
    required this.fillColor,
    required this.thumbContainerColor,
    required this.trackBackgroundColor,
    required this.endThumbWidget,
    required this.buttonWidthShrinkageFactor,
    required this.thumbSizeShrinkageFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        height: confirmed ? confirmedButtonHeight : trackHeight,
        width:
            confirmed ? buttonWidth * buttonWidthShrinkageFactor : buttonWidth,
        child: Container(
          decoration: BoxDecoration(
            color: confirmed ? fillColor : trackBackgroundColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child:
              // Another thumb container which will be animated to shrink
              // when the user confirms the action.
              Opacity(
            opacity: !confirmed ? 0.0 : 1.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                margin: EdgeInsets.symmetric(horizontal: confirmed ? 10 : 0),
                duration: const Duration(milliseconds: 600),
                width: confirmed
                    ? thumbSize * thumbSizeShrinkageFactor
                    : thumbSize,
                height: confirmed
                    ? thumbSize * thumbSizeShrinkageFactor
                    : thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: thumbContainerColor,
                ),
                child: Center(
                  child: AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      scale: confirmed ? thumbSizeShrinkageFactor : 1.0,
                      child: endThumbWidget),
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
class _ProgressFill extends StatelessWidget {
  final ValueNotifier<double> dragPositionNotifier;
  final double thumbSize;
  final Color fillColor;
  final double thumbSpacing;

  const _ProgressFill({
    required this.dragPositionNotifier,
    required this.thumbSize,
    required this.fillColor,
    required this.thumbSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: dragPositionNotifier,
      builder: (context, dragPosition, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: dragPosition + thumbSize + thumbSpacing,
            color: fillColor,
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
  final double trackHeight;
  final double thumbSize;
  final double thumbSpacing;
  final double thumbLeadingOffset;
  final String beforeConfirmText;
  final String duringConfirmText;
  final String afterConfirmText;
  final TextStyle? beforeConfirmTextStyle;
  final TextStyle? duringConfirmTextStyle;
  final TextStyle? afterConfirmTextStyle;
  final Color baseShimmerColor;
  final Color highlightShimmerColor;
  final bool hasShimmerAnimation;

  const _CenterText({
    required this.buttonWidth,
    required this.dragPositionNotifier,
    required this.confirmed,
    required this.startTextAnimation,
    required this.trackHeight,
    required this.thumbSize,
    required this.thumbSpacing,
    required this.thumbLeadingOffset,
    required this.beforeConfirmText,
    required this.duringConfirmText,
    required this.afterConfirmText,
    required this.beforeConfirmTextStyle,
    required this.duringConfirmTextStyle,
    required this.afterConfirmTextStyle,
    required this.baseShimmerColor,
    required this.highlightShimmerColor,
    required this.hasShimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: trackHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gray shimmer text (right side only) - wrapped in RepaintBoundary for performance
          ValueListenableBuilder<double>(
            valueListenable: dragPositionNotifier,
            builder: (context, dragPosition, child) {
              return ClipRect(
                clipper: _HorizontalClipper(
                  left: dragPosition + thumbSize + thumbSpacing,
                  right: buttonWidth,
                ),
                child: RepaintBoundary(
                  child: Center(
                    child: hasShimmerAnimation
                        ? Shimmer(
                            period: const Duration(seconds: 3),
                            gradient: LinearGradient(
                              colors: [
                                baseShimmerColor,
                                highlightShimmerColor,
                                baseShimmerColor,
                              ],
                              stops: [0.45, 0.50, 0.55],
                            ),
                            child: Text(
                              beforeConfirmText,
                              style: beforeConfirmTextStyle,
                            ),
                          )
                        : Text(
                            beforeConfirmText,
                            style: beforeConfirmTextStyle,
                          ),
                  ),
                ),
              );
            },
          ),

          // Text in the fill area (left side only)
          ValueListenableBuilder<double>(
            valueListenable: dragPositionNotifier,
            builder: (context, dragPosition, child) {
              final double fillWidth = dragPosition + thumbLeadingOffset;

              return ClipRect(
                clipper: _HorizontalClipper(
                  left: 0,
                  right: fillWidth,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: startTextAnimation
                        ? Text(
                            afterConfirmText,
                            key: ValueKey("after-confirm"),
                            style: afterConfirmTextStyle,
                          )
                        : Text(
                            duringConfirmText,
                            key: ValueKey("during-confirm"),
                            style: duringConfirmTextStyle,
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
