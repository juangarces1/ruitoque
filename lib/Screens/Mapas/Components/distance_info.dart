import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';

class DistanceInfoWidget extends StatelessWidget {
  const DistanceInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaProvider>(context);
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 80,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distancia al Fondo
          const Text(
            'Fondo',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${provider.dAtras.toString()}y',
            style: const TextStyle(
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          // Distancia al Centro
          const Text(
            'Centro',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${provider.dCentro.toString()}y',
            style: const TextStyle(
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          // Distancia al Frente
          const Text(
            'Frente',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${provider.dfrente.toString()}y',
            style: const TextStyle(
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}