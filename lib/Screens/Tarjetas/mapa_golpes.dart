import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Screens/Mapas/Components/iconos_mapa.dart';
import 'package:ruitoque/Screens/Mapas/Components/ruta_hoyo.dart';
import 'package:ruitoque/Screens/Mapas/Components/trazo_golpe.dart';
import 'package:ruitoque/constans.dart';

/// Golpes de un hoyo ya jugado, con repetición animada golpe por golpe.
class MapaGolpes extends StatefulWidget {
  final EstadisticaHoyo estadisticaHoyo;
  final HoyoTee teeSalida;

  const MapaGolpes({super.key, required this.estadisticaHoyo, required this.teeSalida});

  @override
  MapaGolpesState createState() => MapaGolpesState();
}

class MapaGolpesState extends State<MapaGolpes> {
  GoogleMapController? _mapController;

  /// Tee seguido de dónde cayó cada golpe.
  late final List<LatLng> _puntos;
  late final List<int> _distancias;
  late final CameraPosition _vistaGeneral;

  /// Golpes ya dibujados; durante la repetición van apareciendo uno a uno.
  late int _visibles;
  LatLng? _bola;
  int _golpeActual = 0;
  bool _reproduciendo = false;
  int _idRepeticion = 0;
  final TrazoGolpe _trazo = TrazoGolpe();

  BitmapDescriptor? _iconoGolpe;
  BitmapDescriptor? _iconoBola;
  final Map<int, BitmapDescriptor> _etiquetas = {};

  int get _totalGolpes => _puntos.length - 1;

  @override
  void initState() {
    super.initState();
    final tee = LatLng(widget.teeSalida.cordenada.latitud, widget.teeSalida.cordenada.longitud);
    final shots = widget.estadisticaHoyo.shots ?? [];
    _puntos = [tee, for (final s in shots) LatLng(s.latitud, s.longitud)];
    _distancias = [for (final s in shots) s.distancia];
    _visibles = _totalGolpes;
    _vistaGeneral = _calcularVistaGeneral();
    _cargarIconos();
  }

  @override
  void dispose() {
    _idRepeticion++;
    _trazo.cancelar();
    super.dispose();
  }

  /// Todo el hoyo, orientado del tee hacia el green (o hacia el último golpe).
  CameraPosition _calcularVistaGeneral() {
    final tee = _puntos.first;
    final c = widget.estadisticaHoyo.hoyo.centroGreen;
    final haciaDonde = c != null ? LatLng(c.latitud, c.longitud) : _puntos.last;
    final masLejano = _puntos.reduce((a, b) => yardasEntre(tee, a) >= yardasEntre(tee, b) ? a : b);
    return CameraPosition(
      target: interpolar(tee, masLejano, 0.5),
      bearing: _totalGolpes == 0 && c == null ? 0 : rumbo(tee, haciaDonde),
      zoom: zoomParaDistancia(yardasEntre(tee, masLejano) / 1.09361),
    );
  }

  Future<void> _cargarIconos() async {
    final pr = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    BitmapDescriptor desc(Uint8List bytes) => BitmapDescriptor.bytes(bytes, imagePixelRatio: pr);

    final golpe = desc(await dibujarPuntoPng(
      relleno: Colors.white,
      borde: colorGolpes,
      diametro: 12,
      pixelRatio: pr,
    ));
    final bola = desc(await dibujarPuntoPng(
      relleno: Colors.white,
      borde: Colors.black54,
      diametro: 16,
      pixelRatio: pr,
    ));
    final etiquetas = <int, BitmapDescriptor>{
      for (var i = 0; i < _totalGolpes; i++)
        i: desc(await dibujarEtiquetaPng('${i + 1} · ${_distancias[i]}y', pixelRatio: pr)),
    };
    if (!mounted) return;
    setState(() {
      _iconoGolpe = golpe;
      _iconoBola = bola;
      _etiquetas.addAll(etiquetas);
    });
  }

  void _alCrearMapa(GoogleMapController controller) {
    _mapController = controller;
    if (_totalGolpes > 0) _reproducir();
  }

  Future<void> _moverCamara(CameraPosition camara, Duration duracion) async {
    try {
      await _mapController?.animateCamera(CameraUpdate.newCameraPosition(camara), duration: duracion);
    } catch (_) {
      // La pantalla pudo cerrarse a mitad de animación.
    }
    // En Android animateCamera no espera a que termine la animación.
    await Future.delayed(duracion);
  }

  Future<void> _reproducir() async {
    final id = ++_idRepeticion;
    bool vigente() => mounted && id == _idRepeticion;

    setState(() {
      _reproduciendo = true;
      _visibles = 0;
      _bola = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    for (var i = 0; i < _totalGolpes; i++) {
      if (!vigente()) return;
      setState(() => _golpeActual = i);
      final desde = _puntos[i];
      final hasta = _puntos[i + 1];

      await _moverCamara(
        CameraPosition(
          target: interpolar(desde, hasta, 0.5),
          bearing: rumbo(desde, hasta),
          zoom: zoomParaDistancia(yardasEntre(desde, hasta) / 1.09361),
        ),
        const Duration(milliseconds: 800),
      );
      if (!vigente()) return;

      HapticFeedback.lightImpact();
      await _trazo.animar(desde, hasta, (bola) {
        if (vigente()) setState(() => _bola = bola);
      });
      if (!vigente()) return;
      setState(() {
        _visibles = i + 1;
        _bola = null;
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (!vigente()) return;
    await _moverCamara(_vistaGeneral, const Duration(milliseconds: 1200));
    if (vigente()) setState(() => _reproduciendo = false);
  }

  void _detener() {
    _idRepeticion++;
    _trazo.cancelar();
    setState(() {
      _reproduciendo = false;
      _visibles = _totalGolpes;
      _bola = null;
    });
    _moverCamara(_vistaGeneral, const Duration(milliseconds: 800));
  }

  Set<Polyline> get _polylines {
    final bola = _bola;
    return {
      if (_visibles > 0)
        Polyline(
          polylineId: const PolylineId('golpes'),
          points: _puntos.take(_visibles + 1).toList(),
          width: 3,
          color: colorGolpes,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      if (bola != null)
        Polyline(
          polylineId: const PolylineId('golpe_animado'),
          points: [_puntos[_golpeActual], bola],
          width: 4,
          color: colorGolpes,
          startCap: Cap.roundCap,
        ),
    };
  }

  Set<Marker> get _markers {
    final bola = _bola;
    return {
      Marker(
        markerId: const MarkerId('tee'),
        position: _puntos.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Tee de salida'),
      ),
      for (var i = 1; i <= _visibles; i++) ...[
        if (_iconoGolpe != null)
          Marker(
            markerId: MarkerId('golpe_$i'),
            position: _puntos[i],
            icon: _iconoGolpe!,
            anchor: const Offset(0.5, 0.5),
            consumeTapEvents: true,
          ),
        if (_etiquetas[i - 1] != null)
          Marker(
            markerId: MarkerId('distancia_$i'),
            position: interpolar(_puntos[i - 1], _puntos[i], 0.5),
            icon: _etiquetas[i - 1]!,
            anchor: const Offset(0.5, 0.5),
            zIndexInt: 1,
            consumeTapEvents: true,
          ),
      ],
      if (bola != null && _iconoBola != null)
        Marker(
          markerId: const MarkerId('bola'),
          position: bola,
          icon: _iconoBola!,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 2,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El mapa sigue detrás de la barra (se ve en sus esquinas redondeadas).
      extendBodyBehindAppBar: true,
      appBar: MyCustomAppBar(
        title: widget.estadisticaHoyo.hoyo.nombre,
        automaticallyImplyLeading: true,
        backgroundColor: kPprimaryColor,
        elevation: 4.0,
        shadowColor: const Color.fromARGB(255, 2, 44, 68),
        foreColor: Colors.white,
        actions: const [LogoAppBar()],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            initialCameraPosition: _vistaGeneral,
            // Centra el mapa y su logo en la parte visible, bajo la barra.
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            polylines: _polylines,
            markers: _markers,
            onMapCreated: _alCrearMapa,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: _totalGolpes == 0
                  ? const _Aviso(texto: 'No hay golpes registrados en este hoyo.')
                  : _controles(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controles() {
    final texto = _reproduciendo
        ? 'Golpe ${_golpeActual + 1} de $_totalGolpes · ${_distancias[_golpeActual]}y'
        : '$_totalGolpes ${_totalGolpes == 1 ? 'golpe' : 'golpes'}';
    return Row(
      children: [
        Expanded(child: _Aviso(texto: texto)),
        const SizedBox(width: 12),
        FloatingActionButton.extended(
          heroTag: 'MapaGolpesRepetir',
          backgroundColor: kPcontrastMoradoColor,
          onPressed: _reproduciendo ? _detener : _reproducir,
          icon: Icon(_reproduciendo ? Icons.stop : Icons.replay, color: Colors.white),
          label: Text(
            _reproduciendo ? 'Detener' : 'Repetir',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  final String texto;

  const _Aviso({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'RobotoCondensed',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: Colors.white,
        ),
      ),
    );
  }
}
