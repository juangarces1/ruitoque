import 'package:flutter/material.dart';

class DistanceItem extends StatelessWidget {
  final String number;
  final String distance;
  final Color color;
  final bool isCenter;

  const DistanceItem({Key? key, 
  required this.number,
  required this.distance,
  required this.color,
  required this.isCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
       Text(
          number,
          style:  TextStyle(
            color: color,
              fontSize: isCenter ?  35 : 30,
              fontWeight: isCenter ? FontWeight.bold : FontWeight.normal
              ),
        ),
        const SizedBox(width: 8), // Espacio entre el círculo y el texto
        Text(
          distance,
          style:  TextStyle(
            color: color,
              fontSize: isCenter ?  35 : 30,
              fontWeight: isCenter ? FontWeight.bold : FontWeight.normal
              ),
        ),
      ],
    );
  }
}