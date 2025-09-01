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
            isSuccess ? "Success!" : "Waiting for the confirmation...",
            style: TextStyle(color: Colors.white),
          )),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConfirmSlideButton(
                // Text content (required parameters)
                initialText: "Slide to Confirm",
                confirmingText: "Confirming...",
                completedText: "Success!",
                loadingIndicator: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xff2f2c32))),
                ),

                // Text styling
                initialTextStyle: const TextStyle(color: Colors.white),
                confirmingTextStyle:
                    const TextStyle(fontSize: 12, color: Colors.white),
                completedTextStyle:
                    const TextStyle(fontSize: 12, color: Colors.white),

                // Colors
                progressFillColor: const Color(0xff4ddf69),
                trackBackgroundColor: Color(0xff2f2c32), // Uncomment if needed

                // Shimmer animation
                enableShimmerAnimation: true,
                shimmerBaseColor: Colors.grey,
                shimmerHighlightColor: Colors.white,

                // Layout & dimensions
                margin: const EdgeInsets.symmetric(horizontal: 20),
                trackHeight: 60,
                thumbDiameter: 50,
                horizontalPadding: 4,

                // Callback
                onConfirmed: () async {
                  await Future.delayed(const Duration(seconds: 2));
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
