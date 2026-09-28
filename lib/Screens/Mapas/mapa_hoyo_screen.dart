import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Mapas/Components/golf_map_style_type.dart';
import 'package:ruitoque/Screens/Mapas/Components/mapa_hoyo_provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/trazo_golpe.dart';
import 'package:ruitoque/constans.dart';

/// Mapa de un hoyo para cualquier par (3, 4 o 5).
class MapaHoyoScreen extends StatelessWidget {
  final EstadisticaHoyo hoyo;
  final String teeSalida;
  final Function(int, Shot) onAgregarShot;
  final Function(int, Shot) onDeleteShot;

  const MapaHoyoScreen({
    super.key,
    required this.hoyo,
    required this.teeSalida,
    required this.onAgregarShot,
    required this.onDeleteShot,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey('mapa_hoyo_${hoyo.id}'),
      create: (_) => MapaHoyoProvider(
        hoyo: hoyo,
        teeSalida: teeSalida,
        onAgregarShot: onAgregarShot,
        onDeleteShot: onDeleteShot,
      ),
      builder: (context, _) {
        final provider = context.watch<MapaHoyoProvider>();
        if (provider.ruta == null) return _DatosIncompletos(hoyo: hoyo);

        return Scaffold(
          body: Stack(
            children: [
              // Tocar el mapa detiene el recorrido aéreo. Listener no compite con los
              // gestos del mapa, así que el toque igual lo mueve.
              Listener(
                onPointerDown: (_) => provider.cancelarVuelo(),
                child: GoogleMap(
                  // Recrear el mapa al cambiar de estilo garantiza que se aplique.
                  key: ValueKey(provider.currentStyle),
                  mapType: MapType.satellite,
                  style: provider.estiloMapa,
                  buildingsEnabled: false,
                  trafficEnabled: false,
                  compassEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  // Mi posición la dibuja el provider (punto con pulso y precisión).
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: provider.camaraInicial,
                  polylines: provider.polylines,
                  markers: provider.markers,
                  circles: provider.circles,
                  onMapCreated: provider.setMapController,
                ),
              ),
              const _DistanciasGreen(),
              _Encabezado(hoyo: hoyo),
              const _BotonRefrescar(),
              const _BotonEstilo(),
              const _BotonMiUbicacion(),
              _BotonSaltarVuelo(visible: provider.volando),
              if (provider.showLoader) const MyLoader(text: 'Actualizando...', opacity: 0.8),
            ],
          ),
          floatingActionButton: const _BotonGrabarGolpe(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}

class _BotonSaltarVuelo extends StatelessWidget {
  final bool visible;

  const _BotonSaltarVuelo({required this.visible});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 16,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !visible,
            child: Material(
              color: Colors.black.withOpacity(0.6),
              shape: const StadiumBorder(side: BorderSide(color: Colors.white24)),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => context.read<MapaHoyoProvider>().cancelarVuelo(irAVistaGeneral: true),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Saltar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.skip_next, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DatosIncompletos extends StatelessWidget {
  final EstadisticaHoyo hoyo;

  const _DatosIncompletos({required this.hoyo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(title: hoyo.hoyo.nombre),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Este hoyo no tiene configuradas las coordenadas del tee seleccionado o del green.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final EstadisticaHoyo hoyo;

  const _Encabezado({required this.hoyo});

  @override
  Widget build(BuildContext context) {
    final dHoyo = context.select<MapaHoyoProvider, int?>((p) => p.dHoyo);
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
          child: Row(
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
                      BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, size: 22, color: Colors.black),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(
                      '${hoyo.hoyo.nombre} | Par ${hoyo.hoyo.par} | ${dHoyo ?? '--'}y',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Distancias desde mi posición al frente, centro y fondo del green. Abajo a la
/// izquierda para no tapar el hoyo, con fondo oscuro para leerse a pleno sol.
class _DistanciasGreen extends StatelessWidget {
  const _DistanciasGreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapaHoyoProvider>();

    // Por encima de la fila del botón GG, que en pantallas angostas quedaría al lado.
    return Positioned(
      left: 12,
      bottom: 84,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: provider.lejosDelGreen
              ? const _LejosDelGreen()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilaDistancia(etiqueta: 'FONDO', yardas: provider.dFondo),
                    _FilaDistancia(etiqueta: 'CENTRO', yardas: provider.dCentro, destacada: true),
                    if (provider.juegaCentro != null)
                      _JuegaComo(yardas: provider.juegaCentro!, desnivel: provider.desnivelCentro!),
                    _FilaDistancia(etiqueta: 'FRENTE', yardas: provider.dFrente),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FilaDistancia extends StatelessWidget {
  final String etiqueta;
  final int? yardas;
  final bool destacada;

  const _FilaDistancia({required this.etiqueta, required this.yardas, this.destacada = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Text(
          yardas == null ? '--' : '$yardas',
          style: TextStyle(
            fontFamily: 'RobotoCondensed',
            fontWeight: FontWeight.w700,
            fontSize: destacada ? 40 : 22,
            height: 1.1,
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          'y',
          style: TextStyle(color: Colors.white70, fontSize: destacada ? 16 : 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _LejosDelGreen extends StatelessWidget {
  const _LejosDelGreen();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_outlined, color: Colors.white70, size: 18),
        SizedBox(width: 6),
        Text(
          'Lejos del hoyo',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// "↑ juega 162y · +11 m": la distancia ajustada por el desnivel hasta el green.
class _JuegaComo extends StatelessWidget {
  final int yardas;
  final double desnivel;

  const _JuegaComo({required this.yardas, required this.desnivel});

  @override
  Widget build(BuildContext context) {
    final sube = desnivel > 0;
    const estilo = TextStyle(color: colorGolpes, fontWeight: FontWeight.bold, fontSize: 14);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(sube ? Icons.arrow_upward : Icons.arrow_downward, color: colorGolpes, size: 16),
        Text('juega ${yardas}y', style: estilo),
        Text(
          '  ${sube ? '+' : '−'}${desnivel.abs().round()} m',
          style: estilo.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ],
    );
  }
}

class _BotonRefrescar extends StatelessWidget {
  const _BotonRefrescar();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MapaHoyoProvider>();
    return Positioned(
      top: 12,
      right: 12,
      child: SafeArea(
        bottom: false,
        child: FloatingActionButton.small(
          heroTag: 'MapaRefrescar',
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 6,
          onPressed: provider.calcularDistanciasGreen,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}

class _BotonMiUbicacion extends StatelessWidget {
  const _BotonMiUbicacion();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MapaHoyoProvider>();
    return Positioned(
      top: 128,
      right: 12,
      child: SafeArea(
        bottom: false,
        child: FloatingActionButton.small(
          heroTag: 'MapaMiUbicacion',
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 6,
          onPressed: provider.centrarEnMi,
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
    );
  }
}

class _BotonGrabarGolpe extends StatelessWidget {
  const _BotonGrabarGolpe();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MapaHoyoProvider>();
    return GestureDetector(
      onLongPress: () => provider.mostrarGolpes(context),
      child: FloatingActionButton(
        heroTag: 'MapaGrabarGolpe',
        onPressed: provider.grabarGolpe,
        backgroundColor: kPcontrastMoradoColor,
        elevation: 8,
        child: const Text(
          'GG',
          style: TextStyle(
            fontFamily: 'RobotoCondensed',
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BotonEstilo extends StatelessWidget {
  const _BotonEstilo();

  static const _opciones = [
    (GolfMapStyleType.minimalist, '🎯', 'Minimalista', 'Vista limpia, solo lo esencial'),
    (GolfMapStyleType.ultraClean, '✨', 'Ultra Limpio', 'Solo césped y agua'),
    (GolfMapStyleType.professional, '🏌️', 'Profesional', 'Con caminos de golf cart'),
    (GolfMapStyleType.night, '🌙', 'Modo Nocturno', 'Para rondas al atardecer'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MapaHoyoProvider>();
    return Positioned(
      top: 70,
      right: 12,
      child: SafeArea(
        bottom: false,
        child: FloatingActionButton.small(
          heroTag: 'MapaEstilo',
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 6,
          onPressed: () => _mostrarSelector(context, provider),
          child: const Icon(Icons.layers, color: Colors.white),
        ),
      ),
    );
  }

  void _mostrarSelector(BuildContext context, MapaHoyoProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Estilo del Mapa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            for (final (estilo, icono, titulo, subtitulo) in _opciones) ...[
              _OpcionEstilo(
                icono: icono,
                titulo: titulo,
                subtitulo: subtitulo,
                seleccionado: provider.currentStyle == estilo,
                onTap: () {
                  provider.cambiarEstilo(estilo);
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OpcionEstilo extends StatelessWidget {
  final String icono;
  final String titulo;
  final String subtitulo;
  final bool seleccionado;
  final VoidCallback onTap;

  const _OpcionEstilo({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.green.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? Colors.green : Colors.grey[300]!,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icono, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: seleccionado ? Colors.green[700] : Colors.black87,
                    ),
                  ),
                  Text(subtitulo, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            if (seleccionado) Icon(Icons.check_circle, color: Colors.green[600], size: 24),
          ],
        ),
      ),
    );
  }
}
