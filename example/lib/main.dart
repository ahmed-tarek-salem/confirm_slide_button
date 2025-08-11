import 'package:flutter/material.dart';
import 'package:confirm_slide_button/confirm_slide_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(title: const Text('Slide to Confirm Demo')),
          backgroundColor: Colors.black,
          body: Center(child: Text("Example!")),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConfirmSlideButton(
                onConfirmed: () {
                  print("Confirmed!");
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
