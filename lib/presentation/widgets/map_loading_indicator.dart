import 'package:flutter/material.dart';

class MapLoadingIndicator extends StatelessWidget {
  const MapLoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.amberAccent,
          backgroundColor: Colors.amber,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
        ),
      ),
    );
  }
}
