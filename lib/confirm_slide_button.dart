import 'package:flutter/material.dart';

class ConfirmSlideButton extends StatefulWidget {
  final VoidCallback onConfirmed;

  const ConfirmSlideButton({super.key, required this.onConfirmed});

  @override
  State<ConfirmSlideButton> createState() => _ConfirmSlideButtonState();
}

class _ConfirmSlideButtonState extends State<ConfirmSlideButton> {
  double _dragPosition = 0.0;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width - 40;
    final double trackHeight = 60; // bigger than the thumb
    final double thumbSize = 46; // smaller circle

    return Container(
      height: trackHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // Background track
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff2f2c32),
              borderRadius: BorderRadius.circular(trackHeight / 2),
            ),
          ),

          // Green fill
          ClipRRect(
            borderRadius: BorderRadius.circular(trackHeight / 2),
            child: Container(
              width: _dragPosition + thumbSize + 12,
              color: Colors.green,
            ),
          ),

          // Center text
          Center(
            child: Text(
              _confirmed ? "Confirmed!" : "Slide to Confirm",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // Draggable thumb
          Positioned(
            left: _dragPosition + 6,
            top: (trackHeight - thumbSize) / 2, // vertically centered
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition += details.delta.dx;
                  _dragPosition = _dragPosition.clamp(
                    0.0,
                    buttonWidth - thumbSize,
                  );
                });
              },
              onHorizontalDragEnd: (_) {
                if (_dragPosition > buttonWidth - thumbSize - 5) {
                  setState(() {
                    _confirmed = true;
                    widget.onConfirmed();
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
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
