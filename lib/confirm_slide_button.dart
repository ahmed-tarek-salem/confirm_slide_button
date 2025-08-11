import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ConfirmSlideButton extends StatelessWidget {
  final VoidCallback onConfirmed;

  const ConfirmSlideButton({super.key, required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onConfirmed, // temporary for testing
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xff2f2c32),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Shimmer.fromColors(
            baseColor: const Color(0xff6c696b),
            highlightColor: const Color(0xffb1aeb3),
            period: const Duration(seconds: 2),
            child: const Text(
              "Slide to Confirm",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
