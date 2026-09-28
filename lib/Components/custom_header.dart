import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onRefresh;
  final bool isCreator;

  const CustomHeader({
    Key? key,
    required this.title,
    required this.onBack,
    required this.onSave,
    required this.onRefresh,
    required this.isCreator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EncabezadoMarca(
        title: title,
        leading: BotonBarra(icono: Icons.arrow_back_rounded, onTap: onBack, tooltip: 'Atrás'),
        actions: [
          isCreator
              ? BotonBarra(icono: Icons.save_rounded, onTap: onSave, tooltip: 'Guardar ronda')
              : BotonBarra(icono: Icons.refresh_rounded, onTap: onRefresh, tooltip: 'Actualizar'),
        ],
    );
  }
}
