import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Mapas/Components/golf_map_style_type.dart';
import 'package:ruitoque/Screens/Mapas/Components/golf_map_styles.dart';

class MiMapaPar5Provider extends ChangeNotifier {
  bool _disposed = false;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final EstadisticaHoyo hoyo;
  final String teeSalida;
  final Function(int, Shot)? onAgregarShot;
  final Function(int, Shot)? onDeleteShot;

  GoogleMapController? mapController;
  double bearing = 0;

  final Set<Polyline> polylines = {};
  final Set<Marker> markers = {};

  // Tee seleccionado
  HoyoTee? tee;

  // ✅ Cambiado de 'late' a valores por defecto
  LatLng puntoA = const LatLng(0, 0); // tee
  LatLng puntoB1 = const LatLng(0, 0); // 1/3 del recorrido
  LatLng puntoB2 = const LatLng(0, 0); // 2/3 del recorrido
  LatLng puntoC = const LatLng(0, 0); // centro de green

  // Distancias por tramo
  int dTramo1 = 0;
  int dTramo2 = 0;
  int dTramo3 = 0;

  // Distancias al green / hoyo
  int? dHoyo = 0;
  int? dCentro = 0;
  int? dfrente = 0;
  int? dAtras = 0;
  double? altitude = 0;

  // Control de ubicación en tiempo real
  bool positionStreamStarted = false;
  bool permissionDeniedForever = false;
  StreamSubscription<Position>? _posSub;
  Position? _lastKnownPosition;
  LocationPermission? _permissionStatus;

  // Offsets para mostrar etiquetas en pantalla
  Offset offsetTramo1 = Offset.zero;
  Offset offsetTramo2 = Offset.zero;
  Offset offsetTramo3 = Offset.zero;

  // Cache de icono
  static Future<BitmapDescriptor>? _markerFuture;

  // Guardar midpoints para cálculo de offsets
  LatLng midTramo1 = const LatLng(0, 0);
  LatLng midTramo2 = const LatLng(0, 0);
  LatLng midTramo3 = const LatLng(0, 0);

  GolfMapStyleType currentStyle = GolfMapStyleType.minimalist;

  MiMapaPar5Provider({
    required this.hoyo,
    required this.teeSalida,
    this.onAgregarShot,
    this.onDeleteShot,
  }) {
    _ensureMarkerCache();
    _setInitialData();
    _startPositionStream();
  }

  @override
  void dispose() {
    _disposed = true;
    _posSub?.cancel();
    mapController?.dispose();
    _markerFuture = null;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ✅ ACTUALIZADO: Removido setMapStyle deprecado
  void setMapController(GoogleMapController controller) {
    mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateScreenCoordinates();
      fitCameraToBounds();
    });
  }

  // ✅ NUEVO: Método público para obtener el estilo actual
  String getCurrentStyleString() {
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

  // ✅ ACTUALIZADO: Solo cambia el estilo y notifica (no llama setMapStyle)
  void changeMapStyle(GolfMapStyleType newStyle) {
    currentStyle = newStyle;
    _safeNotifyListeners();
  }

  void _ensureMarkerCache() {
    _markerFuture ??= BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/PuntoCentro.png',
    );
  }

  void _setInitialData() {
    tee = _findTeeByColor(hoyo.hoyo.hoyotees ?? [], teeSalida);
    final centroGreen = hoyo.hoyo.centroGreen;
    final frente = hoyo.hoyo.frenteGreen;
    final fondo = hoyo.hoyo.fondoGreen;
    
    if (tee == null || centroGreen == null || frente == null || fondo == null) {
      return;
    }

    puntoA = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);
    puntoC = LatLng(centroGreen.latitud, centroGreen.longitud);

    puntoB1 = _interpolatePoint(puntoA, puntoC, 1 / 3);
    puntoB2 = _interpolatePoint(puntoA, puntoC, 2 / 3);

    _calculateBearing();
    _buildPolyline();
    _buildMarkers();
    _calculateSegmentDistances();
    _calculateMidpoints();
    calculateDistancesToGreen();
  }

  void _buildPolyline() {
    polylines
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId('par5_polyline'),
          points: [puntoA, puntoB1, puntoB2, puntoC],
          width: 3,
          color: Colors.white,
        ),
      );
  }

  Future<void> _buildMarkers() async {
    if (_disposed) return;
   
    final icono = await (_markerFuture ??= BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/PuntoCentro.png',
    ));

    if (_disposed) return;

    final markerB1 = Marker(
      markerId: const MarkerId('b1'),
      position: puntoB1,
      draggable: true,
      icon: icono,
      anchor: const Offset(0.5, 0.5),
      onDrag: (pos) => _onDragIntermediate(pos, isFirst: true),
      onDragEnd: (pos) => _onDragIntermediate(pos, isFirst: true),
    );

    final markerB2 = Marker(
      markerId: const MarkerId('b2'),
      position: puntoB2,
      draggable: true,
      icon: icono,
      anchor: const Offset(0.5, 0.5),
      onDrag: (pos) => _onDragIntermediate(pos, isFirst: false),
      onDragEnd: (pos) => _onDragIntermediate(pos, isFirst: false),
    );

    markers
      ..clear()
      ..addAll([markerB1, markerB2]);

    _safeNotifyListeners();
  }

  void _onDragIntermediate(LatLng newPos, {required bool isFirst}) {
    if (isFirst) {
      puntoB1 = newPos;
    } else {
      puntoB2 = newPos;
    }
    _buildPolyline();
    _calculateSegmentDistances();
    _calculateMidpoints();
    _buildMarkers();
    updateScreenCoordinates();
  }

  void _calculateSegmentDistances() {
    dTramo1 = _calculateDistanceYards(puntoA, puntoB1);
    dTramo2 = _calculateDistanceYards(puntoB1, puntoB2);
    dTramo3 = _calculateDistanceYards(puntoB2, puntoC);
    _safeNotifyListeners();
  }

  Future<void> grabarGolpe() async {
    if (_disposed) return;
    
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
      if (_disposed) return;
    } catch (_) {
      return;
    }

    LatLng puntoAnterior;
    if (hoyo.shots == null || hoyo.shots!.isEmpty) {
      puntoAnterior = puntoA;
    } else {
      final ultimo = hoyo.shots!.last;
      puntoAnterior = LatLng(ultimo.latitud, ultimo.longitud);
    }

    final puntoActual = LatLng(position.latitude, position.longitude);
    final distancia = _calculateDistanceYards(puntoAnterior, puntoActual);

    final nuevoShot = Shot(
      latitud: puntoActual.latitude,
      longitud: puntoActual.longitude,
      distancia: distancia,
    );

    onAgregarShot?.call(hoyo.id, nuevoShot);

    puntoA = puntoActual;
    puntoB1 = _interpolatePoint(puntoA, puntoC, 1 / 3);
    puntoB2 = _interpolatePoint(puntoA, puntoC, 2 / 3);

    _buildPolyline();
    _buildMarkers();
    _calculateSegmentDistances();
    _calculateMidpoints();
    updateScreenCoordinates();
    calculateDistancesToGreen();
    _safeNotifyListeners();
  }

  void mostrarModalDeDistancias(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          onDeleteShot?.call(hoyo.id, shot);
                          _safeNotifyListeners();
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _calculateMidpoints() {
    midTramo1 = _midpoint(puntoA, puntoB1);
    midTramo2 = _midpoint(puntoB1, puntoB2);
    midTramo3 = _midpoint(puntoB2, puntoC);
  }

  Future<void> updateScreenCoordinates() async {
    if (mapController == null || _disposed) return;
    
    try {
      final o1 = await _getScreenPosition(midTramo1);
      if (_disposed) return;

      final o2 = await _getScreenPosition(midTramo2);
      if (_disposed) return;

      final o3 = await _getScreenPosition(midTramo3);
      if (_disposed) return;

      offsetTramo1 = o1;
      offsetTramo2 = o2;
      offsetTramo3 = o3;
      _safeNotifyListeners();
    } catch (_) {}
  }

  Future<Offset> _getScreenPosition(LatLng punto) async {
    if (mapController == null) return Offset.zero;
    final screenCoordinate = await mapController!.getScreenCoordinate(punto);
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    return Offset(
      screenCoordinate.x / devicePixelRatio,
      screenCoordinate.y / devicePixelRatio,
    );
  }

  LatLng _interpolatePoint(LatLng start, LatLng end, double t) {
    final lat = start.latitude + (end.latitude - start.latitude) * t;
    final lng = start.longitude + (end.longitude - start.longitude) * t;
    return LatLng(lat, lng);
  }

  LatLng _midpoint(LatLng a, LatLng b) {
    final lat = (a.latitude + b.latitude) / 2;
    final lng = (a.longitude + b.longitude) / 2;
    return LatLng(lat, lng);
  }

  Future<void> fitCameraToBounds({double padding = 60}) async {
    if (mapController == null || _disposed) return;
    
    final centerLat = (puntoA.latitude + puntoC.latitude) / 2;
    final centerLng = (puntoA.longitude + puntoC.longitude) / 2;
    final center = LatLng(centerLat, centerLng);
    
    final distance = Geolocator.distanceBetween(
      puntoA.latitude,
      puntoA.longitude,
      puntoC.latitude,
      puntoC.longitude,
    );
    
    final zoom = _calculateZoomLevelManual(distance, padding);
    
    try {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: center,
            zoom: zoom,
            bearing: bearing,
            tilt: 0,
          ),
        ),
      );
    } catch (_) {}
  }

  double _calculateZoomLevel(double distanceInMeters, double padding) {
    final paddingMeters = padding * 0.6;
    final totalDistance = distanceInMeters + paddingMeters;
    final metersPerPixel = totalDistance / 400;
    final zoom = 20 - (log(metersPerPixel) / log(2));
    return zoom.clamp(14.5, 19.5);
  }

  double _calculateZoomLevelManual(double distanceInMeters, double padding) {
    final adjustedDistance = distanceInMeters + (padding * 0.6);
    
    if (adjustedDistance > 6000) return 13.5;
    if (adjustedDistance > 5000) return 14.0;
    if (adjustedDistance > 4000) return 14.5;
    if (adjustedDistance > 3000) return 15.0;
    if (adjustedDistance > 2000) return 15.5;
    if (adjustedDistance > 1500) return 16.0;
    if (adjustedDistance > 1000) return 16.5;
    if (adjustedDistance > 700) return 17.0;
    if (adjustedDistance > 500) return 17.5;
    if (adjustedDistance > 350) return 18.0;
    if (adjustedDistance > 200) return 18.5;
    if (adjustedDistance > 120) return 19.0;
    return 19.5;
  }

  double radians(double degrees) => degrees * (pi / 180.0);
  double degrees(double radians) => radians * (180.0 / pi);

  void _calculateBearing() {
    bearing = _calcularBearing(puntoA, puntoC);
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

  int _calculateDistanceYards(LatLng a, LatLng b) {
    final meters = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    return (meters * 1.09361).round();
  }

  HoyoTee? _findTeeByColor(List<HoyoTee> hoyos, String color) {
    try {
      return hoyos.firstWhere(
        (h) => h.color.toLowerCase() == color.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void onCameraMove() => updateScreenCoordinates();
  void onCameraIdle() => updateScreenCoordinates();

  Future<void> calculateDistancesToGreen() async {
    if (_disposed) return;
    
    final hasPermission = await _handlePermission();
    if (!hasPermission || _disposed) return;

    Position position;
    if (_lastKnownPosition != null) {
      position = _lastKnownPosition!;
    } else {
      position = await _geolocatorPlatform.getCurrentPosition();
      if (_disposed) return;
    }
    
    _lastKnownPosition = position;
    altitude = position.altitude;

    _recalculateGreenDistancesFrom(position);
    _safeNotifyListeners();
  }

  void _recalculateGreenDistancesFrom(Position from) {
    if (hoyo.hoyo.frenteGreen == null ||
        hoyo.hoyo.centroGreen == null ||
        hoyo.hoyo.fondoGreen == null) return;

    final fromLatLng = LatLng(from.latitude, from.longitude);
    dfrente = _calculateDistanceYards(
      fromLatLng,
      LatLng(
        hoyo.hoyo.frenteGreen!.latitud,
        hoyo.hoyo.frenteGreen!.longitud,
      ),
    );
    dCentro = _calculateDistanceYards(
      fromLatLng,
      LatLng(
        hoyo.hoyo.centroGreen!.latitud,
        hoyo.hoyo.centroGreen!.longitud,
      ),
    );
    dAtras = _calculateDistanceYards(
      fromLatLng,
      LatLng(
        hoyo.hoyo.fondoGreen!.latitud,
        hoyo.hoyo.fondoGreen!.longitud,
      ),
    );
    dHoyo = _calculateDistanceYards(fromLatLng, puntoC);
  }

  void _startPositionStream() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission || _disposed) return;
    if (positionStreamStarted) return;

    positionStreamStarted = true;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _posSub = _geolocatorPlatform
        .getPositionStream(locationSettings: settings)
        .listen(
      (pos) {
        if (_disposed) return;
        
        _lastKnownPosition = pos;
        altitude = pos.altitude;
        _recalculateGreenDistancesFrom(pos);
        _safeNotifyListeners();
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<bool> _handlePermission() async {
    if (_permissionStatus == LocationPermission.deniedForever) {
      permissionDeniedForever = true;
      return false;
    }
    if (_permissionStatus == LocationPermission.always ||
        _permissionStatus == LocationPermission.whileInUse) {
      return true;
    }

    final serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        _permissionStatus = permission;
        permissionDeniedForever = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      permissionDeniedForever = true;
      _permissionStatus = permission;
      return false;
    }

    permissionDeniedForever = false;
    _permissionStatus = permission;
    return true;
  }
}