import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 40, // Set a fixed width and height to ensure the shape is consistent
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(1), // Background color with some opacity
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero, // Remove additional padding from the IconButton
          ),
        ),
      ),
    );
  }
}
