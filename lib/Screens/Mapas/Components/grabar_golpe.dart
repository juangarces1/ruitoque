import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';
import 'package:ruitoque/constans.dart';

class GrabarGolpeButton extends StatelessWidget {
  const GrabarGolpeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaProvider>(context, listen: false);
    return GestureDetector(
       onLongPress: () => provider.mostrarModalDeDistancias(context),
      child: FloatingActionButton(
        heroTag: 'UniqueTag',
        onPressed: provider.grabarGolpe,
        backgroundColor: kPcontrastMoradoColor,
        elevation: 8,
        child: const Center(
          child: Text(
            'GG',
            style: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
