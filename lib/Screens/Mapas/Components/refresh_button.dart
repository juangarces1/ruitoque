import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';

class RefreshButtonWidget extends StatelessWidget {
  const RefreshButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaProvider>(context, listen: false);
    return Positioned(
      top: 50,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: FloatingActionButton(
            onPressed: provider.calculateDistances,
            backgroundColor: Colors.white,
            child: const Icon(Icons.refresh, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
