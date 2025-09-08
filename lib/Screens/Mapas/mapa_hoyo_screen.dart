import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';
import 'package:ruitoque/constans.dart'; // ajusta ruta real

class MapaHoyoScreen extends StatefulWidget {
  final EstadisticaHoyo hoyo;
  final String teeSalida;
  final Function(int, Shot) onAgregarShot;
  final Function(int, Shot) onDeleteShot;

  const MapaHoyoScreen({
    Key? key,
    required this.hoyo,
    required this.teeSalida,
    required this.onAgregarShot,
    required this.onDeleteShot,
  }) : super(key: key);

  @override
  State<MapaHoyoScreen> createState() => _MapaHoyoScreenState();
}

class _MapaHoyoScreenState extends State<MapaHoyoScreen> {
  // para hacer el fit una vez el mapa esté listo
  final Completer<void> _fitDone = Completer<void>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MiMapaProvider(
        hoyo: widget.hoyo,
        teeSalida: widget.teeSalida,
        onAgregarShot: widget.onAgregarShot,
        onDeleteShot: widget.onDeleteShot,
      ),
      child: Consumer<MiMapaProvider>(
        builder: (context, prov, _) {
          // Cámara inicial segura
          final initialTarget = prov.tee == null
              ? const LatLng(0, 0)
              : LatLng(prov.tee!.cordenada.latitud, prov.tee!.cordenada.longitud);

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text('Mapa del hoyo', style: kTextStyleBlancoNuevaFuente20,),
              backgroundColor: Colors.black,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => prov.mostrarModalDeDistancias(context),
              label: const Text('Golpes'),
              icon: const Icon(Icons.golf_course),
            ),
            body: Stack(
              children: [
                // Mapa
                GoogleMap(
                  mapType: MapType.satellite,
                  initialCameraPosition: CameraPosition(target: initialTarget, zoom: 16),
                  onMapCreated: (c) async {
                    prov.setMapController(c);
                    // Auto-fit después de un frame para asegurar que el mapa está render
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      await prov.fitCameraToBounds(padding: 80);
                      if (!_fitDone.isCompleted) _fitDone.complete();
                    });
                  },
                  markers: prov.markers,
                  polylines: prov.polylines,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  buildingsEnabled: false,
                  onCameraIdle: () => prov.onCameraIdle(), // bajo consumo
                  onLongPress: (latLng) {
                    // Atajo para registrar golpe si te interesa
                    // prov.grabarGolpe();
                  },
                ),

                // Chip de modo (arriba)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Text(
                            prov.modoTexto,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Badges de distancia segmento A–medio y medio–B (solo en modo planificación)
                if (prov.isEnterScreen) ...[
                  _DistanceBadge(
                    offset: prov.offsetAMedio,
                    text: prov.dSalidaMedio == null ? '--' : '${prov.dSalidaMedio} yds',
                  ),
                  _DistanceBadge(
                    offset: prov.offsetMedioB,
                    text: prov.dMedioGreen == null ? '--' : '${prov.dMedioGreen} yds',
                  ),
                ] else ...[
                  // En modo siguiente golpe, solo un badge en makerA (A–B)
                  _DistanceBadge(
                    offset: prov.offsetAMedio,
                    text: prov.dSalidaMedio == null ? '--' : '${prov.dSalidaMedio} yds',
                  ),
                ],

                // Tarjeta inferior con distancias frente/centro/fondo (compacta)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: _DistanciasGreenCard(
                    frente: prov.dfrente,
                    centro: prov.dCentro,
                    fondo: prov.dAtras,
                    hoyo: prov.dHoyo,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Badge flotante con buen contraste y sombra
class _DistanceBadge extends StatelessWidget {
  final Offset offset;
  final String text;

  const _DistanceBadge({
    Key? key,
    required this.offset,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Evita dibujar fuera de pantalla cuando aún no hay coordenadas
    if (offset == const Offset(0, 0)) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: offset.dx - 38, // centra aprox el chip respecto al punto
      top: offset.dy - 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()], // números más legibles
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card compacta con distancias al green (frente, centro, fondo) + hoyo/tee
class _DistanciasGreenCard extends StatelessWidget {
  final int? frente;
  final int? centro;
  final int? fondo;
  final int? hoyo;

  const _DistanciasGreenCard({
    Key? key,
    required this.frente,
    required this.centro,
    required this.fondo,
    required this.hoyo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    final labelStyle = TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12);

    Widget item(String label, int? value) {
      final v = value == null ? '--' : '$value';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text('$v yds', style: textStyle),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: item('Frente', frente)),
          const SizedBox(width: 8),
          Expanded(child: item('Centro', centro)),
          const SizedBox(width: 8),
          Expanded(child: item('Fondo', fondo)),
          const SizedBox(width: 12),
          _ChipMini(label: 'Hoyo', value: hoyo == null ? '--' : '$hoyo'),
        ],
      ),
    );
  }
}

class _ChipMini extends StatelessWidget {
  final String label;
  final String value;

  const _ChipMini({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
