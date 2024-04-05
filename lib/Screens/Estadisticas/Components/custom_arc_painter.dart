import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomArcPainter extends CustomPainter {
  final double score;
  final double maxScore;

  CustomArcPainter({required this.score, required this.maxScore});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..color = Colors.red; // Puedes ajustar para gradiente o color fijo.

    // El centro está alineado con el borde inferior y en el medio del ancho
    final center = Offset(size.width / 2, size.height * 0.5);
    // El radio es la mitad del ancho para que el arco toque los bordes laterales
    final radius = size.width / 2;
    // Ángulo de inicio desde la izquierda (180 grados convertidos a radianes)
    const startAngle = math.pi;
    // Ángulo de barrido es la mitad de un círculo (180 grados convertidos a radianes)
    const sweepAngle = math.pi;

    // Dibujamos el arco
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), 
      startAngle, 
      sweepAngle, 
      false, 
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}