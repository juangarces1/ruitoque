import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/enum.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:flutter/services.dart';

class MiMapaProvider extends ChangeNotifier {
  // ---------------- Constantes & mensajes ----------------
  static const String _kLocationServicesDisabledMessage = 'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage = 'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  // ---------------- Dependencias ----------------
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  // ---------------- Estado de UI / cálculo ----------------
  bool positionStreamStarted = false;

  int? dHoyo = 0;
  int? dCentro = 0;
  int? dfrente = 0;
  int? dAtras = 0;
  int? dSalidaMedio = 0;
  int? dMedioGreen = 0;

  bool showLoader = false;
  double? altitude = 0;
  double bearing = 0;

  double miLatitud = 0;
  double miLongitud = 0;

  GoogleMapController? mapController;

  late LatLng puntoA;       // tee o última posición (después de golpe)
  late LatLng puntoB;       // objetivo (centro green por defecto o drag final)
  late LatLng puntoMedio;   // centro del hoyo

  final Set<Polyline> polylines = {};
  final Set<Marker> markers = {};

  late Position pMedio;
  late Position salida;
  late HoyoTee? tee;

  late LatLng makerA;
  late LatLng makerB;

  Offset offsetAMedio = const Offset(0, 0);
  Offset offsetMedioB = const Offset(0, 0);

  bool isEnterScreen = true;

  // Flags para UI según permisos
  bool permissionDeniedForever = false;

  // Exponer un helper de modo para el chip
  String get modoTexto => isEnterScreen ? 'Modo planificación' : 'Siguiente golpe';


  // ---------------- Streams & cachés ----------------
  StreamSubscription<Position>? _posSub;
  Position? _lastKnownPosition;
  LocationPermission? _permissionStatus;

  // Cache de ícono de marcador para evitar recargar el asset repetidamente
  static Future<BitmapDescriptor>? _markerFuture;

  // ---------------- Props de negocio ----------------
  final EstadisticaHoyo hoyo;
  final String teeSalida;
  final Function(int, Shot) onAgregarShot;
  final Function(int, Shot) onDeleteShot;

  MiMapaProvider({
    required this.hoyo,
    required this.onAgregarShot,
    required this.teeSalida,
    required this.onDeleteShot,
  }) {
    setInitialData();
    _calculateBearing();
    _ensureMarkerCache();
    _startPositionStream(); // inicia stream con filtro de distancia
  }

  // --------------- Ciclo de vida ---------------
  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  // --------------- Setup inicial ---------------
  void setMapController(GoogleMapController controller) {
    mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateScreenCoordinates();
    });
  }

  void _ensureMarkerCache() {
    _markerFuture ??= BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/PuntoCentro.png',
    );
  }

  void setInitialData() {
    // 1) Tee de salida por color
    tee = _encontrarHoyoTeePorColor(hoyo.hoyo.hoyotees ?? [], teeSalida);

    // Guardas para evitar nulls críticos
    final centroGreen = hoyo.hoyo.centroGreen;
    final frenteGreen = hoyo.hoyo.frenteGreen;
    final fondoGreen = hoyo.hoyo.fondoGreen;
    final centroHoyo = hoyo.hoyo.centroHoyo;

    if (tee == null || centroGreen == null || centroHoyo == null || fondoGreen == null || frenteGreen == null) {
      // Si falta información clave, deja el estado mínimo y no crashea
      polylines.clear();
      markers.clear();
      notifyListeners();
      return;
    }

    // 2) Puntos principales
    puntoA = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);
    puntoB = LatLng(centroGreen.latitud, centroGreen.longitud);
    puntoMedio = LatLng(centroHoyo.latitud, centroHoyo.longitud);

    // 3) Markers intermedios (para badges de distancia visual)
    makerA = _calcularPuntoMedio(puntoA, puntoMedio);
    makerB = _calcularPuntoMedio(puntoMedio, puntoB);

    // 4) Posiciones de referencia
    salida = Position(
      longitude: tee!.cordenada.longitud,
      latitude: tee!.cordenada.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );

    pMedio = Position(
      longitude: centroHoyo.longitud,
      latitude: centroHoyo.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );

    // 5) Polyline inicial A–medio–B
    polylines
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId('mi_polyline'),
          points: [puntoA, puntoMedio, puntoB],
          width: 3, // un poco más gruesa para legibilidad
          color: Colors.white,
        ),
      );

    // 6) Marcador principal
    _crearMarcadorPersonalizado();

    // 7) Distancias base
    _calculateDistancesLinea(pMedio);
    calculateDistances(); // calcula frente/centro/fondo/hoyo
  }

  // --------------- Posición: stream optimizado ---------------
  void _startPositionStream() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return;

    if (positionStreamStarted) return;

    positionStreamStarted = true;
    // Afinar para golf: alta precisión, pero filtrando movimientos pequeños
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // recalcular al moverse ≥ 5m
    );

    _posSub = _geolocatorPlatform.getPositionStream(locationSettings: settings).listen(
      (pos) {
        _lastKnownPosition = pos;
        miLatitud = pos.latitude;
        miLongitud = pos.longitude;
        altitude = pos.altitude;

        // Recalcular distancias a green solo si ya tenemos coordenadas claves
        if (hoyo.hoyo.centroGreen != null && hoyo.hoyo.frenteGreen != null && hoyo.hoyo.fondoGreen != null) {
          _recalculateGreenDistancesFrom(pos);
        }

        // Reducimos notificaciones: una sola al final
        notifyListeners();
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  // --------------- Helpers de UI ---------------
  Future<void> updateScreenCoordinates() async {
    if (mapController == null) return;
    final a = await _getScreenPosition(makerA);
    final b = await _getScreenPosition(makerB);
    offsetAMedio = a;
    offsetMedioB = b;
    notifyListeners();
  }

  Future<Offset> _getScreenPosition(LatLng punto) async {
    if (mapController == null) return const Offset(0, 0);
    try {
      final screenCoordinate = await mapController!.getScreenCoordinate(punto);
      final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
      return Offset(screenCoordinate.x / devicePixelRatio, screenCoordinate.y / devicePixelRatio);
    } catch (_) {
      return const Offset(0, 0);
    }
  }

  Future<void> _crearMarcadorPersonalizado() async {
    final icono = await (_markerFuture ??= BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/PuntoCentro.png',
    ));

    final markerPosition = isEnterScreen ? puntoMedio : puntoB;

    final markerPersonalizado = Marker(
      markerId: const MarkerId('marcadorPrincipal'),
      position: markerPosition,
      draggable: true,
      icon: icono,
      // anchor afinado: punta del pin cerca del suelo
      anchor: const Offset(0.5, 0.5),
      onDrag: (newPosition) {
        _updatePolylineDuringDrag(newPosition);
      },
      onDragEnd: (newPosition) {
        if (isEnterScreen) {
          _updatePolyline(puntoA, newPosition, puntoB);
        } else {
          // Modo "siguiente golpe": línea A–B (arrastre redefine B)
          puntoB = newPosition;

          polylines
            ..clear()
            ..add(
              Polyline(
                polylineId: const PolylineId('mi_polyline'),
                points: [puntoA, puntoB],
                width: 3,
                color: Colors.white,
              ),
            );

          makerA = _calcularPuntoMedio(puntoA, puntoB);

          // Recalcula distancia del tramo A–B (post golpe)
          _calculateDistancesLineaAfterGolpe(
            Position(
              longitude: puntoA.longitude,
              latitude: puntoA.latitude,
              timestamp: DateTime.now(),
              accuracy: 1,
              altitude: 0,
              heading: 0.0,
              speed: 0.0,
              altitudeAccuracy: 10,
              headingAccuracy: 0.0,
              speedAccuracy: 0.0,
            ),
            Position(
              longitude: puntoB.longitude,
              latitude: puntoB.latitude,
              timestamp: DateTime.now(),
              accuracy: 1,
              altitude: 0,
              heading: 0.0,
              speed: 0.0,
              altitudeAccuracy: 10,
              headingAccuracy: 0.0,
              speedAccuracy: 0.0,
            ),
          );

          // También refresca distancias al green desde la ubicación actual
          calculateDistances();
          notifyListeners();
        }
      },
    );

    markers
      ..clear()
      ..add(markerPersonalizado);

    notifyListeners();
  }

  // --------------- Búsqueda de tee ----------------
  HoyoTee? _encontrarHoyoTeePorColor(List<HoyoTee> hoyos, String color) {
    try {
      return hoyos.firstWhere((h) => h.color.toLowerCase() == color.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  // --------------- Geodesia ----------------
  LatLng _calcularPuntoMedio(LatLng a, LatLng b) {
    final lat1 = radians(a.latitude);
    final lon1 = radians(a.longitude);
    final lat2 = radians(b.latitude);
    final lon2 = radians(b.longitude);

    final dLon = lon2 - lon1;
    final Bx = cos(lat2) * cos(dLon);
    final By = cos(lat2) * sin(dLon);
    final lat3 = atan2(
      sin(lat1) + sin(lat2),
      sqrt((cos(lat1) + Bx) * (cos(lat1) + Bx) + By * By),
    );
    final lon3 = lon1 + atan2(By, cos(lat1) + Bx);

    return LatLng(degrees(lat3), degrees(lon3));
  }

  void _updatePolyline(LatLng inicio, LatLng medio, LatLng fin) {
    if (isEnterScreen) {
      final auxMedio = Position(
        longitude: medio.longitude,
        latitude: medio.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
        altitudeAccuracy: 10,
        headingAccuracy: 0.0,
        speedAccuracy: 0.0,
      );

      _calculateDistancesLinea(auxMedio);

      polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('mi_polyline'),
            points: [inicio, medio, fin],
            width: 3,
            color: Colors.white,
          ),
        );

      makerA = _calcularPuntoMedio(puntoA, medio);
      makerB = _calcularPuntoMedio(medio, puntoB);

      updateScreenCoordinates();
      notifyListeners();
    } else {
      final auxInicio = Position(
        longitude: inicio.longitude,
        latitude: inicio.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
        altitudeAccuracy: 10,
        headingAccuracy: 0.0,
        speedAccuracy: 0.0,
      );
      final auxFin = Position(
        longitude: fin.longitude,
        latitude: fin.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
        altitudeAccuracy: 10,
        headingAccuracy: 0.0,
        speedAccuracy: 0.0,
      );

      _calculateDistancesLineaAfterGolpe(auxInicio, auxFin);

      polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('mi_polyline'),
            points: [inicio, fin],
            width: 3,
            color: Colors.white,
          ),
        );

      makerA = _calcularPuntoMedio(puntoA, fin);
      updateScreenCoordinates();
      notifyListeners();
    }
  }

  void _updatePolylineDuringDrag(LatLng newPosition) {
    if (isEnterScreen) {
      polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('mi_polyline'),
            points: [puntoA, newPosition, puntoB],
            width: 3,
            color: Colors.white,
          ),
        );
      makerA = _calcularPuntoMedio(puntoA, newPosition);
      makerB = _calcularPuntoMedio(newPosition, puntoB);
    } else {
      puntoB = newPosition;
      polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('mi_polyline'),
            points: [puntoA, puntoB],
            width: 3,
            color: Colors.white,
          ),
        );
      makerA = _calcularPuntoMedio(puntoA, puntoB);
    }

    updateScreenCoordinates();
    notifyListeners();
  }

  Future<void> calculateDistances() async {
    showLoader = true;
    notifyListeners();

    try {
      final hasPermission = await _handlePermission();
      if (!hasPermission) return;

      // Usar última posición del stream si existe; si no, tomar una puntual
      Position position;
      if (_lastKnownPosition != null) {
        position = _lastKnownPosition!;
      } else {
        position = await _geolocatorPlatform.getCurrentPosition();
      }
      _lastKnownPosition = position;

      miLatitud = position.latitude;
      miLongitud = position.longitude;
      altitude = position.altitude;

      _recalculateGreenDistancesFrom(position);

      // dHoyo: si tee.distancia == 0, calcula desde salida a CENTRO (no frente)
      if (tee != null) {
        final centro = Position(
          longitude: hoyo.hoyo.centroGreen!.longitud,
          latitude: hoyo.hoyo.centroGreen!.latitud,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 0,
          heading: 0.0,
          speed: 0.0,
          altitudeAccuracy: 10,
          headingAccuracy: 0.0,
          speedAccuracy: 0.0,
        );
        dHoyo = tee!.distancia == 0 ? _calculateDistanceInYards(salida, centro) : tee!.distancia;
      }
    } finally {
      showLoader = false;
      notifyListeners();
    }
  }

  void _recalculateGreenDistancesFrom(Position from) {
    final frente = hoyo.hoyo.frenteGreen!;
    final centro = hoyo.hoyo.centroGreen!;
    final fondo = hoyo.hoyo.fondoGreen!;

    final pFrente = Position(
      longitude: frente.longitud,
      latitude: frente.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );
    final pCentro = Position(
      longitude: centro.longitud,
      latitude: centro.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );
    final pFondo = Position(
      longitude: fondo.longitud,
      latitude: fondo.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );

    dfrente = _calculateDistanceInYards(pFrente, from);
    dCentro = _calculateDistanceInYards(pCentro, from);
    dAtras = _calculateDistanceInYards(pFondo, from);
  }

  Future<void> _calculateDistancesLinea(Position medio) async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return;
    if (hoyo.hoyo.centroGreen == null) return;

    final puntoBCentroGreen = Position(
      longitude: hoyo.hoyo.centroGreen!.longitud,
      latitude: hoyo.hoyo.centroGreen!.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );

    dSalidaMedio = _calculateDistanceInYards(salida, medio);
    dMedioGreen = _calculateDistanceInYards(medio, puntoBCentroGreen);
    notifyListeners();
  }

  Future<void> _calculateDistancesLineaAfterGolpe(Position inicio, Position fin) async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return;

    dSalidaMedio = _calculateDistanceInYards(inicio, fin);
    notifyListeners();
  }

  int _calculateDistanceInYards(Position position1, Position position2) {
    final distanceInMeters = Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
    return (distanceInMeters * 1.09361).round();
  }

  // --------------- Permisos ---------------
  Future<bool> _handlePermission() async {
    if (_permissionStatus == LocationPermission.deniedForever) {
      permissionDeniedForever = true;
      return false;
    }
    if (_permissionStatus == LocationPermission.always || _permissionStatus == LocationPermission.whileInUse) {
      return true;
    }

    final serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updatePositionList(PositionItemType.log, _kLocationServicesDisabledMessage);
      return false;
    }

    var permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        _updatePositionList(PositionItemType.log, _kPermissionDeniedMessage);
        _permissionStatus = permission;
        permissionDeniedForever = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updatePositionList(PositionItemType.log, _kPermissionDeniedForeverMessage);
      permissionDeniedForever = true; // la UI puede mostrar CTA a Ajustes
      _permissionStatus = permission;
      return false;
    }

    _updatePositionList(PositionItemType.log, _kPermissionGrantedMessage);
    permissionDeniedForever = false;
    _permissionStatus = permission;
    return true;
  }

  void _updatePositionList(PositionItemType type, String displayValue) {
    debugPrint(displayValue);
  }

  // --------------- Bearing / rumbos ---------------
  double radians(double degrees) => degrees * (pi / 180.0);
  double degrees(double radians) => radians * (180.0 / pi);

  void _calculateBearing() {
    if (tee == null || hoyo.hoyo.centroHoyo == null) return;
    final start = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);
    final end = LatLng(hoyo.hoyo.centroHoyo!.latitud, hoyo.hoyo.centroHoyo!.longitud);
    bearing = _calcularBearing(start, end);
  }

  double _calcularBearing(LatLng start, LatLng end) {
    var startLat = radians(start.latitude);
    var startLng = radians(start.longitude);
    var endLat = radians(end.latitude);
    var endLng = radians(end.longitude);

    var dLong = endLng - startLng;
    var dPhi = log(tan(endLat / 2.0 + pi / 4.0) / tan(startLat / 2.0 + pi / 4.0));

    if (dLong.abs() > pi) {
      dLong = dLong > 0.0 ? -(2.0 * pi - dLong) : (2.0 * pi + dLong);
    }
    return (degrees(atan2(dLong, dPhi)) + 360.0) % 360.0;
  }

  // --------------- Registro de golpes ---------------
  Future<void> grabarGolpe() async {
    // Asegura permisos/posición actual antes de calcular
    final hasPermission = await _handlePermission();
    if (!hasPermission) return;

    Position position;
    try {
      position = await _geolocatorPlatform.getCurrentPosition();
    } catch (_) {
      return;
    }

    // Punto anterior = tee si no hay shots; si hay, el último shot
    LatLng puntoAnterior;
    if (hoyo.shots == null || hoyo.shots!.isEmpty) {
      puntoAnterior = puntoA;
    } else {
      final ultimoShot = hoyo.shots!.last;
      puntoAnterior = LatLng(ultimoShot.latitud, ultimoShot.longitud);
    }

    final puntoActual = LatLng(position.latitude, position.longitude);

    final distancia = _calculateDistanceInYards(
      Position(
        latitude: puntoAnterior.latitude,
        longitude: puntoAnterior.longitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
        altitudeAccuracy: 10,
        headingAccuracy: 0.0,
        speedAccuracy: 0.0,
      ),
      Position(
        latitude: puntoActual.latitude,
        longitude: puntoActual.longitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
        altitudeAccuracy: 10,
        headingAccuracy: 0.0,
        speedAccuracy: 0.0,
      ),
    );

    final nuevoShot = Shot(
      latitud: puntoActual.latitude,
      longitud: puntoActual.longitude,
      distancia: distancia,
    );

    onAgregarShot(hoyo.id, nuevoShot);

    isEnterScreen = false;
    _afterGrabarGolpe(position);
  }

  void _afterGrabarGolpe(Position position) {
    // A = nueva posición
    puntoA = LatLng(position.latitude, position.longitude);

    // B = centro de green
    if (hoyo.hoyo.centroGreen == null) return;
    puntoB = LatLng(hoyo.hoyo.centroGreen!.latitud, hoyo.hoyo.centroGreen!.longitud);

    makerA = _calcularPuntoMedio(puntoA, puntoB);

    final fin = Position(
      longitude: hoyo.hoyo.centroGreen!.longitud,
      latitude: hoyo.hoyo.centroGreen!.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );

    _calculateDistancesLineaAfterGolpe(position, fin);

    polylines
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId('mi_polyline'),
          points: [puntoA, puntoB],
          width: 3,
          color: Colors.white,
        ),
      );

    isEnterScreen = false;

    _crearMarcadorPersonalizado(); // reubica marcador
    calculateDistances();          // refresca frente/centro/fondo
    notifyListeners();
  }

  // --------------- Modal (solo callback de borrar ya existe) ---------------
  void mostrarModalDeDistancias(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: false, // <- importante para heredar el provider de esta ruta
    builder: (sheetContext) {
      // Aseguramos que el bottom sheet tenga el mismo MiMapaProvider
      return ChangeNotifierProvider<MiMapaProvider>.value(
        value: this, // <- el mismo instance del provider actual
        child: Consumer<MiMapaProvider>(
          builder: (context, provider, child) {
            final shots = provider.hoyo.shots ?? [];

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
                              provider.onDeleteShot(provider.hoyo.id, shot);
                              provider.notifyListeners(); // si mantienes este patrón
                            },
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      );
    },
  );
}




  // Ajuste de cámara a bounds (tee ↔ green) con padding
Future<void> fitCameraToBounds({double padding = 60}) async {
  if (mapController == null) return;
  final sw = LatLng(
    min(puntoA.latitude, puntoB.latitude),
    min(puntoA.longitude, puntoB.longitude),
  );
  final ne = LatLng(
    max(puntoA.latitude, puntoB.latitude),
    max(puntoA.longitude, puntoB.longitude),
  );
  final bounds = LatLngBounds(southwest: sw, northeast: ne);
  await mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
}

// Señal háptica al finalizar drag del marcador (lo llamaremos desde la UI)
Future<void> hapticOnDragEnd() async {
  try {
    await HapticFeedback.selectionClick();
  } catch (_) {}
}

// onCameraIdle de bajo consumo
  void onCameraIdle() {
    updateScreenCoordinates();
  }

  void onCameraMove() {
    updateScreenCoordinates();
  }

}
