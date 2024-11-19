import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final showLoader = Provider.of<MiMapaProvider>(context).showLoader;
    return showLoader
        ? const MyLoader(text: 'Actualizando...', opacity: 0.8)
        : const SizedBox();
  }
}
