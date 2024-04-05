import 'package:flutter/material.dart';
import 'package:ruitoque/Screens/Estadisticas/Components/custom_arc_painter.dart';

class ArcIndicator extends StatelessWidget {
  final double score;
  final double maxScore;

  const ArcIndicator({Key? key, required this.score, required this.maxScore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double topPadding = 0;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: CustomPaint(
        painter: CustomArcPainter(score: score, maxScore: maxScore),
        size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2), // La altura es la mitad de la pantalla
      ),
    );
  }
}