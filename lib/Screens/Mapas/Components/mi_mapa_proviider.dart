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

class MiMapaProvider extends ChangeNotifier {
  // Variables necesarias
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  // Variables de estado
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
  late String distanciaHoyo;
  double miLatitud = 0;
  double miLongitud = 0;
  late GoogleMapController mapController;
  late LatLng puntoA;
  late LatLng puntoB;
  late LatLng puntoMedio;
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
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateScreenCoordinates();
    });
  }

  void setInitialData() {
    // Encontramos el Tee desde el cual jugamos
    tee = _encontrarHoyoTeePorColor(hoyo.hoyo.hoyotees!, teeSalida);
    // El puntoA o de inicio es la coordenada del tee que escogimos
    puntoA = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);
    // El puntoB o de fin es la coordenada del centro del green al que vamos
    puntoB = LatLng(
        hoyo.hoyo.centroGreen!.latitud, hoyo.hoyo.centroGreen!.longitud);
    // El punto medio es la coordenada del centro del hoyo
    puntoMedio = LatLng(
        hoyo.hoyo.centroHoyo!.latitud, hoyo.hoyo.centroHoyo!.longitud);

    // Calculamos los puntos de los markers
    makerA = _calcularPuntoMedio(puntoA, puntoMedio);
    makerB = _calcularPuntoMedio(puntoMedio, puntoB);

    // Inicializamos la posición de la salida para calcular las distancias luego
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
      speedAccuracy: 0.0
    );

    // Inicializamos la posición del punto medio para calcular las distancias luego
    pMedio = Position(
      longitude: hoyo.hoyo.centroHoyo!.longitud,
      latitude: hoyo.hoyo.centroHoyo!.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
    );

    // Agregamos la polyline con sus coordenadas
    polylines.add(
      Polyline(
        polylineId: const PolylineId('mi_polyline'),
        points: [puntoA, puntoMedio, puntoB],
        width: 2,
        color: Colors.white,
      ),
    );

    // Creamos el marcador
    _crearMarcadorPersonalizado();

    // Calculamos las distancias de las líneas
    _calculateDistancesLinea(pMedio);

    // Calculamos las distancias a frente, centro y fondo del green
    calculateDistances();
  }

  Future<void> updateScreenCoordinates() async {
    Offset offsetaMediotemp = await _getScreenPosition(makerA);
    Offset offsetmedioBtemp = await _getScreenPosition(makerB);
    offsetAMedio = offsetaMediotemp;
    offsetMedioB = offsetmedioBtemp;
    notifyListeners();
  }

  Future<Offset> _getScreenPosition(LatLng punto) async {
    ScreenCoordinate screenCoordinate =
        await mapController.getScreenCoordinate(punto);
    double devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    double adjustedX = screenCoordinate.x.toDouble() / devicePixelRatio;
    double adjustedY = screenCoordinate.y.toDouble() / devicePixelRatio;
    return Offset(adjustedX, adjustedY);
  }

  Future<void> _crearMarcadorPersonalizado() async {
    BitmapDescriptor iconoPersonalizado = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/newMarker.png');

    Marker markerPersonalizado = Marker(
      markerId: const MarkerId('puntoMedio'),
      position: isEnterScreen ? puntoMedio : puntoB,
      draggable: true,
      icon: iconoPersonalizado,
      anchor: const Offset(0.5, 0.5),
      onDragEnd: (newPosition) {
        isEnterScreen
            ? _updatePolyline(puntoA, newPosition, puntoB)
            : _updatePolyline(puntoA, puntoMedio, newPosition);
      },
    );

    markers.add(markerPersonalizado);
    notifyListeners();
  }

  HoyoTee? _encontrarHoyoTeePorColor(List<HoyoTee> hoyos, String color) {
    for (var hoyotee in hoyos) {
      if (hoyotee.color.toLowerCase() == color.toLowerCase()) {
        return hoyotee;
      }
    }
    return null; // Retorna null si no encuentra ninguna coincidencia
  }

  LatLng _calcularPuntoMedio(LatLng puntoA, LatLng puntoB) {
    double lat1 = radians(puntoA.latitude);
    double lon1 = radians(puntoA.longitude);
    double lat2 = radians(puntoB.latitude);
    double lon2 = radians(puntoB.longitude);

    double dLon = lon2 - lon1;

    double Bx = cos(lat2) * cos(dLon);
    double By = cos(lat2) * sin(dLon);
    double lat3 = atan2(
        sin(lat1) + sin(lat2), sqrt((cos(lat1) + Bx) * (cos(lat1) + Bx) + By * By));
    double lon3 = lon1 + atan2(By, cos(lat1) + Bx);

    return LatLng(degrees(lat3), degrees(lon3));
  }

  void _updatePolyline(LatLng inicio, LatLng medio, LatLng fin) {
    if (isEnterScreen) {
      List<LatLng> points = [inicio, medio, fin];
      Position auxMedio = Position(
        longitude: medio.longitude,
        latitude: medio.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
         altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
      );

      _calculateDistancesLinea(auxMedio);

      // Actualiza la polilínea
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('mi_polyline'),
          points: points,
          width: 2,
          color: Colors.white,
        ),
      );

      makerA = _calcularPuntoMedio(puntoA, medio);
      makerB = _calcularPuntoMedio(medio, puntoB);
      updateScreenCoordinates();
      notifyListeners();
    } else {
      List<LatLng> points = [inicio, fin];
      Position auxFin = Position(
        longitude: fin.longitude,
        latitude: fin.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
         altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
      );

      Position auxInicio = Position(
        longitude: inicio.longitude,
        latitude: inicio.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0.0,
        speed: 0.0,
         altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
      );

      _calculateDistancesLineaAfterGolpe(auxInicio, auxFin);

      // Actualiza la polilínea
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('mi_polyline'),
          points: points,
          width: 2,
          color: Colors.white,
        ),
      );

      makerA = _calcularPuntoMedio(puntoA, fin);
      updateScreenCoordinates();
      notifyListeners();
    }
  }

  Future<void> calculateDistances() async {
    showLoader = true;
    notifyListeners();

    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      showLoader = false;
      notifyListeners();
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    miLatitud = position.latitude;
    miLongitud = position.longitude;

    altitude = position.altitude;

    Position frente = Position(
      longitude: hoyo.hoyo.centroGreen!.longitud,
      latitude: hoyo.hoyo.centroGreen!.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
       altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
    );

    Position centro = Position(
      longitude: hoyo.hoyo.centroGreen!.longitud,
      latitude: hoyo.hoyo.centroGreen!.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
       altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
    );

    Position fondo = Position(
      longitude: hoyo.hoyo.fondoGreen!.longitud,
      latitude: hoyo.hoyo.fondoGreen!.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
       altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
    );

    dCentro = _calculateDistanceInYards(centro, position);
    dAtras = _calculateDistanceInYards(fondo, position);
    dfrente = _calculateDistanceInYards(frente, position);
    dHoyo = tee!.distancia == 0
        ? _calculateDistanceInYards(salida, centro)
        : tee!.distancia;
    showLoader = false;
    notifyListeners();
  }

  Future<void> _calculateDistancesLinea(Position medio) async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      return;
    }

    Position puntoBCentroGreen = Position(
      longitude: hoyo.hoyo.centroGreen!.longitud,
      latitude: hoyo.hoyo.centroGreen!.latitud,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0.0,
      speed: 0.0,
       altitudeAccuracy: 10, 
      headingAccuracy: 0.0, 
      speedAccuracy: 0.0
    );

    dSalidaMedio = _calculateDistanceInYards(salida, medio);
    dMedioGreen = _calculateDistanceInYards(medio, puntoBCentroGreen);
    notifyListeners();
  }

  Future<void> _calculateDistancesLineaAfterGolpe(
      Position inicio, Position fin) async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      return;
    }

    dSalidaMedio = _calculateDistanceInYards(inicio, fin);
    notifyListeners();
  }

  int _calculateDistanceInYards(Position position1, Position position2) {
    double distanceInMeters = Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
    // Convertir metros a yardas
    double distanceInYards = distanceInMeters * 1.09361;
    return distanceInYards.toInt();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updatePositionList(
        PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        _updatePositionList(
          PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updatePositionList(
        PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    _updatePositionList(
      PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void _updatePositionList(PositionItemType type, String displayValue) {
    // Manejo de logs o mensajes
  }

  double radians(double degrees) => degrees * (pi / 180.0);

  double degrees(double radians) => radians * (180.0 / pi);

  void _calculateBearing() {
    LatLng start = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);
    LatLng end = LatLng(
        hoyo.hoyo.centroHoyo!.latitud, hoyo.hoyo.centroHoyo!.longitud);
    bearing = _calcularBearing(start, end);
  }

  double _calcularBearing(LatLng start, LatLng end) {
    var startLat = radians(start.latitude);
    var startLng = radians(start.longitude);
    var endLat = radians(end.latitude);
    var endLng = radians(end.longitude);

    var dLong = endLng - startLng;

    var dPhi =
        log(tan(endLat / 2.0 + pi / 4.0) / tan(startLat / 2.0 + pi / 4.0));
    if (dLong.abs() > pi) {
      if (dLong > 0.0) {
        dLong = -(2.0 * pi - dLong);
      } else {
        dLong = (2.0 * pi + dLong);
      }
    }

    return (degrees(atan2(dLong, dPhi)) + 360.0) % 360.0;
  }

  void grabarGolpe() async {
    await calculateDistances(); // Asegúrate de tener la posición actualizada

    LatLng puntoAnterior;

    if (hoyo.shots == null || hoyo.shots!.isEmpty) {
      // Si no hay shots registrados, usar el puntoA
      puntoAnterior = puntoA;
    } else {
      // Si ya hay shots, usar la última posición registrada
      Shot ultimoShot = hoyo.shots!.last;
      puntoAnterior = LatLng(ultimoShot.latitud, ultimoShot.longitud);
    }

    // Obtener la posición actual
    Position position = await _geolocatorPlatform.getCurrentPosition();

    LatLng puntoActual = LatLng(position.latitude, position.longitude);

    // Calcular la distancia en yardas
    int distancia = _calculateDistanceInYards(
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
      speedAccuracy: 0.0
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
      speedAccuracy: 0.0
      ),
    );

    // Crear un nuevo shot con la distancia calculada
    Shot nuevoShot = Shot(
      latitud: puntoActual.latitude,
      longitud: puntoActual.longitude,
      distancia: distancia,
    );

    // Agregar el shot a la lista y ejecutar el callback
    onAgregarShot(hoyo.id, nuevoShot);

    isEnterScreen = false;

    _afterGrabarGolpe(position);
  }

  void _afterGrabarGolpe(Position position) {
    puntoA = LatLng(position.latitude, position.longitude);
    // El puntoB o de fin es la coordenada del centro del green al que vamos
    puntoB = LatLng(
        hoyo.hoyo.centroGreen!.latitud, hoyo.hoyo.centroGreen!.longitud);
    // El punto medio es la coordenada del centro del hoyo
    puntoMedio = LatLng(
        hoyo.hoyo.centroHoyo!.latitud, hoyo.hoyo.centroHoyo!.longitud);

    // Calculamos los puntos de los markers
    makerA = _calcularPuntoMedio(puntoA, puntoB);

    polylines.clear();
    markers.clear();

    // Agregamos la polilínea con sus coordenadas
    polylines.add(
      Polyline(
        polylineId: const PolylineId('mi_polyline'),
        points: [puntoA, puntoB],
        width: 2,
        color: Colors.white,
      ),
    );

    // Creamos el marcador
    _crearMarcadorPersonalizado();

    // Calculamos las distancias de las líneas
    _calculateDistancesLinea(position);

    // Calculamos las distancias a frente, centro y fondo del green
    calculateDistances();

    notifyListeners();
  }

void mostrarModalDeDistancias(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Consumer<MiMapaProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: 300, // Ajusta la altura según tus necesidades
            child: provider.hoyo.shots == null || provider.hoyo.shots!.isEmpty
                ? const Center(
                    child: Text(
                      'No hay golpes registrados.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.hoyo.shots!.length,
                    itemBuilder: (context, index) {
                      final shot = provider.hoyo.shots![index];
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
                            // Eliminar el golpe de la lista
                            provider.onDeleteShot(provider.hoyo.id, shot);
                            // Notificar cambios para actualizar la UI
                            provider.notifyListeners();
                          },
                        ),
                        onTap: () {
                          // Opcional: Manejar toques en el ListTile
                        },
                      );
                    },
                  ),
          );
        },
      );
    },
  );
}

}
