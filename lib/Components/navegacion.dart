import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruitoque/constans.dart';

/// Una sección de la barra inferior.
class DestinoNavegacion {
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;

  const DestinoNavegacion({required this.icono, required this.iconoActivo, required this.etiqueta});
}

/// Colores de la barra inferior (oscura, para que "Jugar" resalte en la muesca).
class ColoresNavegacion {
  ColoresNavegacion._();

  static const barra = Color(0xFF16261F);

  /// Lo que se ve por la muesca alrededor de "Jugar".
  static const fondo = Color(0xFF0B1512);
  static const activo = kPverdeMasClaro;
  static const inactivo = Color(0x99FFFFFF);
}

/// Barra inferior con una muesca redonda en el centro donde encaja [BotonJugar].
/// Recibe 4 destinos: dos a cada lado de la muesca.
class BarraNavegacion extends StatelessWidget {
  final List<DestinoNavegacion> destinos;
  final int indice;
  final ValueChanged<int> onCambiar;

  const BarraNavegacion({
    super.key,
    required this.destinos,
    required this.indice,
    required this.onCambiar,
  }) : assert(destinos.length == 4, 'Dos destinos a cada lado de "Jugar"');

  static const alto = 68.0;

  @override
  Widget build(BuildContext context) {
    Widget item(int i) => Expanded(
          child: _ItemNavegacion(
            destino: destinos[i],
            activo: i == indice,
            onTap: () {
              if (i == indice) return;
              HapticFeedback.selectionClick();
              onCambiar(i);
            },
          ),
        );

    return BottomAppBar(
      height: alto,
      padding: EdgeInsets.zero,
      color: ColoresNavegacion.barra,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      notchMargin: 7,
      clipBehavior: Clip.antiAlias,
      // Esquinas superiores redondeadas, como la barra de arriba, más la muesca.
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        CircleBorder(),
      ),
      child: Row(
        children: [
          item(0),
          item(1),
          const SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 9),
                child: Text(
                  'Jugar',
                  style: TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          item(2),
          item(3),
        ],
      ),
    );
  }
}

class _ItemNavegacion extends StatelessWidget {
  final DestinoNavegacion destino;
  final bool activo;
  final VoidCallback onTap;

  const _ItemNavegacion({required this.destino, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = activo ? ColoresNavegacion.activo : ColoresNavegacion.inactivo;
    return Semantics(
      button: true,
      selected: activo,
      label: destino.etiqueta,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Píldora que se enciende detrás del ícono activo.
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: activo ? 52 : 32,
              height: 30,
              decoration: BoxDecoration(
                color: activo ? ColoresNavegacion.activo.withValues(alpha: 0.18) : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(activo ? destino.iconoActivo : destino.icono, color: color, size: 24),
            ),
            const SizedBox(height: 3),
            Text(
              destino.etiqueta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 12,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón redondo "Jugar" que encaja en la muesca de [BarraNavegacion].
/// Verde con el mismo relieve del botón principal; se hunde al presionar.
class BotonJugar extends StatefulWidget {
  final VoidCallback onPressed;

  const BotonJugar({super.key, required this.onPressed});

  static const diametro = 64.0;

  @override
  State<BotonJugar> createState() => _BotonJugarState();
}

class _BotonJugarState extends State<BotonJugar> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Jugar',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _presionado = true),
        onTapUp: (_) => setState(() => _presionado = false),
        onTapCancel: () => setState(() => _presionado = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onPressed();
        },
        child: AnimatedScale(
          scale: _presionado ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: BotonJugar.diametro,
            height: BotonJugar.diametro,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPprimaryColor,
              boxShadow: [
                BoxShadow(
                  color: kPprimaryColor.withValues(alpha: _presionado ? 0.2 : 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: _presionado ? 0.1 : 0.3),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.55],
              ),
            ),
            child: const Icon(Icons.sports_golf, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
