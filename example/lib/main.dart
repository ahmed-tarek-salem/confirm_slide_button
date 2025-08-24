import 'package:flutter/material.dart';
import 'package:confirm_slide_button/confirm_slide_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSuccess = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
      home: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(title: const Text('Slide to Confirm Demo')),
          backgroundColor: Colors.black,
          body: Center(
              child: Text(
            isSuccess ? "Success!" : "Wiating for the confirmation...",
            style: TextStyle(color: Colors.white),
          )),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConfirmSlideButton(
                // Callback
                onConfirmed: () {
                  setState(() {
                    isSuccess = true;
                  });
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
