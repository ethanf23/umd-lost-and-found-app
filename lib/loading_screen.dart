import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use a built-in Flutter icon as a placeholder
            Icon(
              Icons.money, // Replace with another icon if desired
              size: 100,
              color:
                  Theme.of(context).primaryColor, // Optional: Use theme color
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Add a progress indicator
          ],
        ),
      ),
    );
  }
}
