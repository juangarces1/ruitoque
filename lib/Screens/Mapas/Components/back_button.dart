import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 0,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 30.0, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
