# ConfirmSlideButton

A highly animated, customizable, and performant slide-to-confirm button widget for Flutter applications.
Perfect for **critical actions** that require user confirmation, such as **payments, deletions, or form submissions**.

[![pub package](https://img.shields.io/pub/v/confirm_slide_button.svg)](https://pub.dev/packages/confirm_slide_button)  
[![GitHub stars](https://img.shields.io/github/stars/ahmed-tarek-salem/confirm_slide_button)](https://github.com/ahmed-tarek-salem/confirm_slide_button)  
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)  

## 🎥 Demo
![demo](https://github.com/user-attachments/assets/fbb9836c-3a5e-48bc-9ba1-ebdcfd0a5f24)

## ✨ Features

* **Smooth Animations** – Fluid drag interactions with spring-based physics
* **Fully Customizable** – Colors, text, sizes, and animations
* **Responsive Design** – Adapts to any screen size
* **Performance Optimized** – Uses `ValueNotifier` & efficient rendering
* **Shimmer Effects** – Optional animated text highlighting
* **States** – Loading, confirming, and completed states
* **Visual Feedback** – Progress fill, blur effects, and size transitions
## 🚀 Quick Start
```dart
ConfirmSlideButton(
  onConfirmed: () async {
    await Future.delayed(Duration(seconds: 1));
    print('Confirmed!');
  },
)
```
## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  confirm_slide_button: ^2.0.0
```

Then run:

```bash
flutter pub get
```

## 💡 Usage Examples

### Basic Example

```dart
ConfirmSlideButton(
  onConfirmed: () async {
    // Perform your action here
    await Future.delayed(Duration(seconds: 2));
    print('Action confirmed!');
  },
)
```

### Slide to Delete

```dart
ConfirmSlideButton(
  onConfirmed: () async => await deleteUserAccount(),
  initialText: 'Slide to delete account',
  confirmingText: 'Deleting...',
  completedText: 'Account deleted',
  trackBackgroundColor: Colors.red.shade100,
  progressFillColor: Colors.red,
  thumbBackgroundColor: Colors.red.shade800,
  completedThumbChild: Icon(Icons.delete_outline_rounded,color: Colors.white, size: 24),
)
```

### Slide to Pay

```dart
ConfirmSlideButton(
  onConfirmed: () async => await processPayment(),
  initialText: 'Slide to pay \$99.99',
  confirmingText: 'Processing...',
  completedText: 'Done!',
  progressFillColor: const Color(0xff4ddf69),
  loadingIndicator: const CircularProgressIndicator(
    color: Colors.white,
    strokeWidth: 1.5,
  ),
  completedTextStyle: TextStyle(color: Colors.white),
)
```

## 📱 Example App

```
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
                onConfirmed: () async {
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() {
                    isSuccess = true;
                  });
                },
                initialText: 'Slide to pay \$99.99',
                confirmingText: 'Confirming...',
                completedText: 'Done!',
                progressFillColor: const Color(0xff4ddf69),
                confirmingTextStyle: TextStyle(color: Colors.white),
                loadingIndicator: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.5,
                ),
                completedTextStyle: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
```
## License
This project is licensed under the MIT License.

