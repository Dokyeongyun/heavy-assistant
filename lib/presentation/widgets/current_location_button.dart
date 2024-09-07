import 'package:flutter/material.dart';

class CurrentLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CurrentLocationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(242, 255, 255, 255),
        foregroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
      ),
      child: const Icon(Icons.my_location, size: 24),
    );
  }
}
