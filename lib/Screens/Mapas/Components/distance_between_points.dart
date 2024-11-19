// distance_between_points_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';



class DistanceBetweenPointsWidget extends StatelessWidget {
  const DistanceBetweenPointsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaProvider>(context);
    return Stack(
      children: [
        // First circle (distance between salida and medio or green)
        Positioned(
          left: provider.offsetAMedio.dx - 20,
          top: provider.offsetAMedio.dy - 20,
          child: ClipOval(
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(9.0),
              color: Colors.white,
              child: Text(
                provider.dSalidaMedio?.toString() ?? '',
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // Second circle (distance between medio and green)
        provider.isEnterScreen && provider.offsetMedioB != Offset.zero
            ? Positioned(
                left: provider.offsetMedioB.dx - 20,
                top: provider.offsetMedioB.dy - 20,
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(9.0),
                    color: Colors.white,
                    child: Text(
                      provider.dMedioGreen?.toString() ?? '',
                      style: const TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
