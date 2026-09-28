import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Mapas/Components/iconos_mapa.dart';
import 'package:ruitoque/Screens/Mapas/Components/elevacion.dart';
import 'package:ruitoque/Screens/Mapas/Components/golf_map_style_type.dart';
import 'package:ruitoque/Screens/Mapas/Components/golf_map_styles.dart';
import 'package:ruitoque/Screens/Mapas/Components/ruta_hoyo.dart';
import 'package:ruitoque/Screens/Mapas/Components/trazo_golpe.dart';
import 'package:ruitoque/Screens/Mapas/Components/vuelo_hoyo.dart';

/// Estado del mapa de un hoyo, para cualquier par (ver [RutaHoyo]).
class MapaHoyoProvider extends ChangeNotifier {
  final EstadisticaHoyo hoyo;
  final String teeSalida;
  final Function(int, Shot) onAgregarShot;
  final Function(int, Shot) onDeleteShot;

  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  HoyoTee? tee;

  /// Null si al hoyo le faltan coordenadas (tee o green); la UI muestra un aviso.
  RutaHoyo? ruta;
  late int _golpesDados;

  GoogleMapController? _mapController;
  final Set<Polyline> polylines = {};

  /// Recorrido aéreo al entrar al hoyo; se hace una sola vez.
  bool _vueloHecho = false;
  bool volando = false;
  int _idVuelo = 0;

  /// Golpes ya dados en el hoyo: línea desde el tee y un punto donde cayó cada uno.
  final Set<Marker> _marcasGolpes = {};
  BitmapDescriptor? _iconoGolpe;
  BitmapDescriptor? _iconoBola;
  bool _animandoGolpe = false;
  final TrazoGolpe _trazo = TrazoGolpe();

  /// Durante la animación el golpe nuevo aún no se dibuja en el historial.
  int? _golpesVisibles;

  /// Marcadores que se arrastran (intermedios u objetivo).
  final Set<Marker> _movibles = {};

  /// Distancia de cada tramo, dibujada como marcador en el centro del tramo.
  final Set<Marker> _etiquetas = {};
  final Map<String, BitmapDescriptor> _iconosEtiqueta = {};
  final Set<String> _etiquetasEnCurso = {};
  final Map<int, BitmapDescriptor> _ultimoIconoTramo = {};

  Set<Marker> get markers => {..._marcasGolpes, ..._movibles, ..._etiquetas};

  int? dHoyo;
  int? dFrente;
  int? dCentro;
  int? dFondo;

  /// Distancia al centro del green ajustada por desnivel; null si no hay alturas
  /// o el desnivel es despreciable. Positivo el desnivel = green más alto que yo.
  int? juegaCentro;
  double? desnivelCentro;

  /// Alturas del terreno del hoyo; se descargan una vez por hoyo y sesión.
  static FuenteElevacion fuenteElevacion = OpenMeteoElevacion();
  static final Map<int, MallaElevacion> _mallasPorHoyo = {};
  MallaElevacion? _malla;

  bool showLoader = false;
  bool permissionDeniedForever = false;
  LocationPermission? _permissionStatus;
  StreamSubscription<Position>? _posSub;
  Position? _lastKnownPosition;

  GolfMapStyleType currentStyle = GolfMapStyleType.minimalist;

  static Future<BitmapDescriptor>? _iconoFuture;
  BitmapDescriptor? _icono;

  bool _disposed = false;

  MapaHoyoProvider({
    required this.hoyo,
    required this.teeSalida,
    required this.onAgregarShot,
    required this.onDeleteShot,
  }) {
    _inicializar();
  }

  @override
  void dispose() {
    _disposed = true;
    _idVuelo++;
    _posSub?.cancel();
    _trazo.cancelar();
    super.dispose();
  }

  void _notificar() {
    if (!_disposed) notifyListeners();
  }

  // ---------------- Setup ----------------

  LatLng? get _green => _latLng(hoyo.hoyo.centroGreen);

  void _inicializar() {
    tee = _buscarTee(hoyo.hoyo.hoyotees ?? [], teeSalida);
    final green = _green;
    if (tee == null || green == null) return;

    final salida = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);
    dHoyo = tee!.distancia == 0 ? yardasEntre(salida, green) : tee!.distancia;

    // Si se vuelve a entrar al hoyo con golpes ya grabados, se planea desde el último.
    final shots = hoyo.shots ?? [];
    _golpesDados = shots.length;
    final origen = shots.isEmpty ? salida : LatLng(shots.last.latitud, shots.last.longitud);
    _planearDesde(origen);

    _cargarIcono();
    _cargarIconosGolpes();
    _iniciarStreamPosicion();
    _cargarElevacion();
    calcularDistanciasGreen();
  }

  void _planearDesde(LatLng origen) {
    ruta = RutaHoyo.planear(
      origen: origen,
      green: _green!,
      cantidadIntermedios: RutaHoyo.intermediosPara(par: hoyo.hoyo.par, golpesDados: _golpesDados),
      centroHoyo: _golpesDados == 0 ? _latLng(hoyo.hoyo.centroHoyo) : null,
    );
    _ultimoIconoTramo.clear();
    _reconstruirPolylines();
    _reconstruirMarcadores();
    _reconstruirEtiquetas();
  }

  Future<void> _cargarIcono() async {
    _icono = await (_iconoFuture ??= BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/PuntoCentro.png',
    ));
    _reconstruirMarcadores();
    _notificar();
  }

  /// La primera vez arranca a ras del origen para el recorrido aéreo; después
  /// (p. ej. al recrear el mapa por cambio de estilo) muestra el hoyo completo.
  CameraPosition get camaraInicial => _vueloHecho ? camaraGeneral(ruta!) : camaraInicioVuelo(ruta!);

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    if (!_vueloHecho) _volar();
  }

  Future<void> _volar() async {
    _vueloHecho = true;
    volando = true;
    final id = ++_idVuelo;
    _notificar();

    // Deja que carguen las primeras imágenes del satélite antes de despegar.
    await Future.delayed(const Duration(milliseconds: 600));
    for (final paso in pasosVuelo(ruta!)) {
      if (id != _idVuelo) return;
      await _moverCamara(paso.camara, paso.duracion);
      await Future.delayed(paso.duracion + paso.pausa);
    }
    if (id != _idVuelo) return;
    volando = false;
    _notificar();
  }

  /// Detiene el recorrido aéreo. Si fue con el botón "Saltar", va a la vista general;
  /// si fue porque el usuario tocó el mapa, la cámara queda donde él la lleve.
  void cancelarVuelo({bool irAVistaGeneral = false}) {
    if (!volando) return;
    _idVuelo++;
    volando = false;
    if (irAVistaGeneral) _encuadrarRuta();
    _notificar();
  }

  Future<void> _moverCamara(CameraPosition camara, Duration duracion) async {
    try {
      await _mapController?.animateCamera(CameraUpdate.newCameraPosition(camara), duration: duracion);
    } catch (_) {
      // El mapa pudo haberse cerrado a mitad de animación.
    }
  }

  Future<void> _encuadrarRuta() async {
    final r = ruta;
    if (r == null) return;
    await _moverCamara(camaraGeneral(r), const Duration(milliseconds: 900));
  }

  // ---------------- Ruta y marcadores ----------------

  List<LatLng> get _puntosGolpes {
    final shots = hoyo.shots ?? <Shot>[];
    return [
      LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud),
      for (final s in shots.take(_golpesVisibles ?? shots.length)) LatLng(s.latitud, s.longitud),
    ];
  }

  void _reconstruirPolylines() {
    polylines.removeWhere((p) => p.polylineId.value != 'golpe_animado');
    final golpes = _puntosGolpes;
    if (golpes.length > 1) {
      polylines.add(Polyline(
        polylineId: const PolylineId('golpes'),
        points: golpes,
        width: 3,
        color: colorGolpes,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    }
    if (!_animandoGolpe) {
      polylines.add(Polyline(
        polylineId: const PolylineId('ruta'),
        points: ruta!.puntos,
        width: 3,
        color: Colors.white,
      ));
    }
  }

  void _reconstruirMarcasGolpes() {
    final icono = _iconoGolpe;
    _marcasGolpes.removeWhere((m) => m.markerId.value != 'bola');
    if (icono == null) return;
    final golpes = _puntosGolpes;
    for (var i = 1; i < golpes.length; i++) {
      _marcasGolpes.add(Marker(
        markerId: MarkerId('golpe_$i'),
        position: golpes[i],
        icon: icono,
        anchor: const Offset(0.5, 0.5),
        consumeTapEvents: true,
      ));
    }
  }

  Future<void> _cargarIconosGolpes() async {
    final pr = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final golpe =
        await dibujarPuntoPng(relleno: Colors.white, borde: colorGolpes, diametro: 12, pixelRatio: pr);
    final bola =
        await dibujarPuntoPng(relleno: Colors.white, borde: Colors.black54, diametro: 16, pixelRatio: pr);
    _iconoGolpe = BitmapDescriptor.bytes(golpe, imagePixelRatio: pr);
    _iconoBola = BitmapDescriptor.bytes(bola, imagePixelRatio: pr);
    if (_disposed) return;
    _reconstruirMarcasGolpes();
    _notificar();
  }

  void _reconstruirMarcadores() {
    final r = ruta;
    final icono = _icono;
    _movibles.clear();
    if (r == null || icono == null || _animandoGolpe) return;

    Marker marcador(String id, LatLng posicion, void Function(LatLng) mover) => Marker(
          markerId: MarkerId(id),
          position: posicion,
          draggable: true,
          icon: icono,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 2,
          onDragStart: (_) => cancelarVuelo(),
          onDrag: (p) => _alArrastrar(mover, p),
          onDragEnd: (p) {
            _alArrastrar(mover, p);
            // Solo al soltar: reconstruir marcadores durante el arrastre lo interrumpe.
            _reconstruirMarcadores();
            HapticFeedback.selectionClick();
            _notificar();
          },
        );

    if (r.objetivoMovible) {
      _movibles.add(marcador('objetivo', r.objetivo, r.moverObjetivo));
    } else {
      for (var i = 0; i < r.intermedios.length; i++) {
        _movibles.add(marcador('intermedio_$i', r.intermedios[i], (p) => r.moverIntermedio(i, p)));
      }
    }
  }

  void _alArrastrar(void Function(LatLng) mover, LatLng posicion) {
    mover(posicion);
    _reconstruirPolylines();
    // Los marcadores movibles no se tocan aquí: cambiarlos interrumpe el arrastre.
    _reconstruirEtiquetas();
    _notificar();
  }

  void _reconstruirEtiquetas() {
    final r = ruta;
    _etiquetas.clear();
    if (r == null || _animandoGolpe) return;

    final tramos = r.tramosYardas;
    final centros = r.centrosTramos;
    for (var i = 0; i < tramos.length; i++) {
      final texto = _textoTramo(tramos[i], r.puntos[i], r.puntos[i + 1]);
      final icono = _iconosEtiqueta[texto];
      if (icono == null) _generarEtiqueta(texto);
      // Mientras se dibuja el número nuevo se muestra el anterior, sin parpadeo.
      final mostrado = icono ?? _ultimoIconoTramo[i];
      if (mostrado == null) continue;
      _ultimoIconoTramo[i] = mostrado;
      _etiquetas.add(Marker(
        markerId: MarkerId('tramo_$i'),
        position: centros[i],
        icon: mostrado,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: 1,
        consumeTapEvents: true,
      ));
    }
  }

  /// "150y", o "150y ↑161" si el desnivel del tramo cambia la distancia que juega.
  String _textoTramo(int yardas, LatLng desde, LatLng hasta) {
    final h1 = _malla?.alturaEn(desde);
    final h2 = _malla?.alturaEn(hasta);
    final juega = (h1 == null || h2 == null) ? null : juegaComo(yardas, h2 - h1);
    if (juega == null) return '${yardas}y';
    return '${yardas}y ${juega > yardas ? '↑' : '↓'}$juega';
  }

  Future<void> _generarEtiqueta(String texto) async {
    if (!_etiquetasEnCurso.add(texto)) return;
    final pixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    try {
      final png = await dibujarEtiquetaPng(texto, pixelRatio: pixelRatio);
      _iconosEtiqueta[texto] = BitmapDescriptor.bytes(png, imagePixelRatio: pixelRatio);
    } finally {
      _etiquetasEnCurso.remove(texto);
    }
    if (_disposed) return;
    _reconstruirEtiquetas();
    _notificar();
  }

  // ---------------- Ubicación ----------------

  void _iniciarStreamPosicion() async {
    if (!await _tienePermiso() || _disposed) return;
    _posSub = _geolocator
        .getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    )
        .listen((pos) {
      _lastKnownPosition = pos;
      _recalcularDistanciasGreen(pos);
      _notificar();
    }, onError: (_) {});
  }

  /// Distancias desde mi posición al frente, centro y fondo del green.
  Future<void> calcularDistanciasGreen() async {
    showLoader = true;
    _notificar();
    try {
      if (!await _tienePermiso()) return;
      final pos = _lastKnownPosition ?? await _geolocator.getCurrentPosition();
      _lastKnownPosition = pos;
      _recalcularDistanciasGreen(pos);
    } catch (_) {
      // Sin posición: se mantienen las últimas distancias.
    } finally {
      showLoader = false;
      _notificar();
    }
  }

  void _recalcularDistanciasGreen(Position pos) {
    final yo = LatLng(pos.latitude, pos.longitude);
    int? a(Cordenada? c) => c == null ? null : yardasEntre(yo, _latLng(c)!);
    dFrente = a(hoyo.hoyo.frenteGreen);
    dCentro = a(hoyo.hoyo.centroGreen);
    dFondo = a(hoyo.hoyo.fondoGreen);

    final hYo = _malla?.alturaEn(yo);
    final hGreen = _green == null ? null : _malla?.alturaEn(_green!);
    desnivelCentro = (hYo == null || hGreen == null) ? null : hGreen - hYo;
    juegaCentro = (desnivelCentro == null || dCentro == null) ? null : juegaComo(dCentro!, desnivelCentro!);
  }

  Future<void> _cargarElevacion() async {
    final id = hoyo.hoyo.id;
    try {
      _malla = _mallasPorHoyo[id] ??= await MallaElevacion.cargar([
        for (final c in [
          hoyo.hoyo.centroHoyo,
          hoyo.hoyo.frenteGreen,
          hoyo.hoyo.centroGreen,
          hoyo.hoyo.fondoGreen,
          tee?.cordenada,
        ])
          if (c != null) _latLng(c)!,
        for (final s in hoyo.shots ?? <Shot>[]) LatLng(s.latitud, s.longitud),
      ], fuenteElevacion);
    } catch (e) {
      // Sin alturas simplemente no se muestra el "juega como".
      debugPrint('Elevación no disponible: $e');
      return;
    }
    if (_disposed) return;
    if (_lastKnownPosition != null) _recalcularDistanciasGreen(_lastKnownPosition!);
    _reconstruirEtiquetas();
    _notificar();
  }

  Future<bool> _tienePermiso() async {
    if (_permissionStatus == LocationPermission.always ||
        _permissionStatus == LocationPermission.whileInUse) {
      return true;
    }
    if (_permissionStatus == LocationPermission.deniedForever) return false;
    if (!await _geolocator.isLocationServiceEnabled()) return false;

    var permiso = await _geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await _geolocator.requestPermission();
    }
    _permissionStatus = permiso;
    permissionDeniedForever = permiso == LocationPermission.deniedForever;
    return permiso == LocationPermission.always || permiso == LocationPermission.whileInUse;
  }

  // ---------------- Golpes ----------------

  Future<void> grabarGolpe() async {
    if (ruta == null || _animandoGolpe || !await _tienePermiso()) return;

    final Position pos;
    try {
      pos = await _geolocator.getCurrentPosition();
    } catch (_) {
      return;
    }
    if (_disposed) return;
    cancelarVuelo();

    final shots = hoyo.shots ?? [];
    final golpesPrevios = shots.length;
    final anterior = shots.isEmpty
        ? LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud)
        : LatLng(shots.last.latitud, shots.last.longitud);
    final actual = LatLng(pos.latitude, pos.longitude);

    onAgregarShot(
      hoyo.id,
      Shot(latitud: actual.latitude, longitud: actual.longitude, distancia: yardasEntre(anterior, actual)),
    );

    _golpesDados++;
    _lastKnownPosition = pos;
    _recalcularDistanciasGreen(pos);

    await _animarGolpe(anterior, actual, golpesPrevios);
    if (_disposed) return;
    _planearDesde(actual);
    _notificar();
    _encuadrarRuta();
  }

  /// Encuadra el golpe y dibuja su trayectoria creciendo hasta donde cayó la bola.
  Future<void> _animarGolpe(LatLng desde, LatLng hasta, int golpesPrevios) async {
    _animandoGolpe = true;
    _golpesVisibles = golpesPrevios;
    _movibles.clear();
    _etiquetas.clear();
    _reconstruirPolylines();
    _reconstruirMarcasGolpes();
    _notificar();

    const acercamiento = Duration(milliseconds: 700);
    await _moverCamara(
      CameraPosition(
        target: interpolar(desde, hasta, 0.5),
        bearing: rumbo(desde, hasta),
        zoom: zoomParaDistancia(yardasEntre(desde, hasta) / 1.09361),
      ),
      acercamiento,
    );
    await Future.delayed(acercamiento);
    if (_disposed) return;

    HapticFeedback.lightImpact();
    await _trazo.animar(desde, hasta, (bola) {
      polylines
        ..removeWhere((p) => p.polylineId.value == 'golpe_animado')
        ..add(Polyline(
          polylineId: const PolylineId('golpe_animado'),
          points: [desde, bola],
          width: 4,
          color: colorGolpes,
          startCap: Cap.roundCap,
        ));
      _marcasGolpes.removeWhere((m) => m.markerId.value == 'bola');
      if (_iconoBola != null) {
        _marcasGolpes.add(Marker(
          markerId: const MarkerId('bola'),
          position: bola,
          icon: _iconoBola!,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 3,
        ));
      }
      _notificar();
    });
    if (_disposed) return;
    await Future.delayed(const Duration(milliseconds: 400));

    // El golpe nuevo pasa al historial del hoyo.
    polylines.removeWhere((p) => p.polylineId.value == 'golpe_animado');
    _marcasGolpes.removeWhere((m) => m.markerId.value == 'bola');
    _animandoGolpe = false;
    _golpesVisibles = null;
    _reconstruirPolylines();
    _reconstruirMarcasGolpes();
  }

  void mostrarGolpes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final shots = hoyo.shots ?? [];
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: 300,
            child: shots.isEmpty
                ? const Center(
                    child: Text(
                      'No hay golpes registrados.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: shots.length,
                    itemBuilder: (context, index) {
                      final shot = shots[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          '${shot.distancia} yds',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            onDeleteShot(hoyo.id, shot);
                            _reconstruirPolylines();
                            _reconstruirMarcasGolpes();
                            _notificar();
                            setModalState(() {});
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  // ---------------- Estilo ----------------

  String get estiloMapa {
    switch (currentStyle) {
      case GolfMapStyleType.minimalist:
        return GolfMapStyles.getMinimalistGolfStyle();
      case GolfMapStyleType.ultraClean:
        return GolfMapStyles.getUltraCleanGolfStyle();
      case GolfMapStyleType.professional:
        return GolfMapStyles.getProfessionalGolfStyle();
      case GolfMapStyleType.night:
        return GolfMapStyles.getNightGolfStyle();
    }
  }

  void cambiarEstilo(GolfMapStyleType estilo) {
    currentStyle = estilo;
    _notificar();
  }

  // ---------------- Helpers ----------------

  static LatLng? _latLng(Cordenada? c) => c == null ? null : LatLng(c.latitud, c.longitud);

  static HoyoTee? _buscarTee(List<HoyoTee> tees, String color) {
    for (final t in tees) {
      if (t.color.toLowerCase() == color.toLowerCase()) return t;
    }
    return null;
  }
}
