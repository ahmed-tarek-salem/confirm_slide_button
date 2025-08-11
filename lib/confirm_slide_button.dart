import 'package:flutter/material.dart';

class ConfirmSlideButton extends StatelessWidget {
  final VoidCallback onConfirmed;

  const ConfirmSlideButton({super.key, required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onConfirmed, // temporary for testing
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xff2f2c32),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: const Text(
            "Slide to Confirm",
            style: TextStyle(color: Color(0xff666369)),
          ),
        ),
      ),
    );
  }
}
