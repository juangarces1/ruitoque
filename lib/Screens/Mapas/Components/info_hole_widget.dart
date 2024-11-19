import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';

class InfoHoleWidget extends StatelessWidget {
  const InfoHoleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaProvider>(context);
    return Positioned(
      top: 50,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 30.0, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Text(
              '${provider.hoyo.hoyo.nombre} | Par ${provider.hoyo.hoyo.par} | ${provider.dHoyo}y',
              style: const TextStyle(
                fontFamily: 'RobotoCondensed',
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
