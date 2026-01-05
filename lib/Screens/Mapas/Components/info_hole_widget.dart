import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';

class InfoHoleWidget extends StatelessWidget {
  const InfoHoleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaProvider>(context);
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${provider.hoyo.hoyo.nombre} | Par ${provider.hoyo.hoyo.par} | ${provider.dHoyo}y',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // balancea el espacio del IconButton izquierdo
            ],
          ),
        ),
      ),
    );
  }
}
