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
                beforeConfirmText: "Slide to Confirm",
                duringConfirmText: "Confirming...",
                afterConfirmText: "Success!",
                beforeConfirmTextStyle: TextStyle(color: Colors.white),
                fillColor: const Color(0xff4ddf69),
                duringConfirmTextStyle:
                    TextStyle(fontSize: 12, color: Colors.white),
                afterConfirmTextStyle:
                    TextStyle(fontSize: 12, color: Colors.white),
                baseShimmerColor: Colors.grey,
                highlightShimmerColor: Colors.white,
                hasShimmerAnimation: true,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                trackHeight: 60,
                thumbSize: 50,
                thumbHorizontalBorderWidth: 4,
                thumbContainerColor: Colors.black,
                // trackBackgroundColor: Color(0xff2f2c32),
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
