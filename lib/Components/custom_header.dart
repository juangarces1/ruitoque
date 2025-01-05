import 'package:flutter/material.dart';
import 'package:ruitoque/constans.dart';

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
    return SafeArea(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondoHome.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Botón de Regresar
            CircleAvatar(
              backgroundColor: kPcontrastMoradoColor,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack,
                iconSize: 20,
              ),
            ),
            const SizedBox(width: 10),
            // Título Expandido
            Expanded(
              child: Text(
                title,
                style: kTextStyleNegroRobotoSize20.copyWith(
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 10),
            // Botón Save o Refresh
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                icon: isCreator
                    ? const Icon(Icons.save, color: kPcontrastMoradoColor)
                    : const Icon(Icons.refresh, color: kPcontrastMoradoColor),
                onPressed: isCreator ? onSave : onRefresh,
                iconSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
