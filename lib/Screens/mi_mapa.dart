import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Components/enum.dart';
import 'package:ruitoque/Components/position_item.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';

import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MiMapa extends StatefulWidget {
  final EstadisticaHoyo hoyo;
  final Function(int, Shot) onAgregarShot;
  const MiMapa({
    required this.hoyo,
     required this.onAgregarShot,
    super.key});

  @override
  State<MiMapa> createState() => _MiMapaState();
}

class _MiMapaState extends State<MiMapa> {

 
   static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<PositionItem> _positionItems = <PositionItem>[];
 
  bool positionStreamStarted = false;

  int? dCentro = 0;
  int? dfrente = 0;
  int? dAtras = 0;
  int? dSalidaMedio=0;
  int? dMedioGreen=0;
  bool showLoader = false;
  double? altitude = 0;
  double bearing=0;

  double miLatitud = 0;
  double miLongitud=0;

   late  GoogleMapController mapController;

  late LatLng puntoA; // Tus coordenadas aquí
  late LatLng puntoB; // Tus coordenadas aquí
  late LatLng puntoMedio; // Tus coordenadas aquí

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  late Position pMedio;
 

  @override
  void initState() {
    super.initState();    
    _calculateDistances();
   
    _calculateBering();
    puntoA = LatLng(widget.hoyo.hoyo.teeBlancas!.latitud, widget.hoyo.hoyo.teeBlancas!.longitud);
    puntoB = LatLng(widget.hoyo.hoyo.centroGreen!.latitud, widget.hoyo.hoyo.centroGreen!.longitud);
    puntoMedio = LatLng(widget.hoyo.hoyo.centroHoyo!.latitud, widget.hoyo.hoyo.centroHoyo!.longitud);
    _polylines.add(
    Polyline(
      polylineId: const PolylineId('mi_polyline'),
      points: [puntoA, puntoMedio, puntoB],
      width: 2,
      color: Colors.white,
    ),
  );

     

    // _markers.add(
    //   Marker(
    //   markerId: const MarkerId('puntoMedio'),
    //   position: puntoMedio,
    //   draggable: true,
    //   onDragEnd: (newPosition) {
    //     // Actualiza la posición del punto medio
    //     _updatePolyline(puntoA, newPosition, puntoB);
    //   },
    // ),
    //  );

      _crearMarcadorPersonalizado();

      pMedio = Position(
      longitude: widget.hoyo.hoyo.centroHoyo!.longitud, 
      latitude: widget.hoyo.hoyo.centroHoyo!.latitud, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);
     _calculateDistancesLinea(pMedio);
     setState(() {}); 
  }

   Future<void> _crearMarcadorPersonalizado() async {
    BitmapDescriptor iconoPersonalizado = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/newMarker.png');

    Marker markerPersonalizado = Marker(
      markerId: const MarkerId('puntoMedio'),
      position: puntoMedio, // Asegúrate de tener definida esta variable
      draggable: true,
      icon: iconoPersonalizado,
      onDragEnd: (newPosition) {
         _updatePolyline(puntoA, newPosition, puntoB);
      },
    );

    setState(() {
      _markers.add(markerPersonalizado);
    });
  }


  void _updatePolyline(LatLng inicio, LatLng medio, LatLng fin) {
      // Crea una nueva lista de puntos para la polilínea
      List<LatLng> points = [inicio, medio, fin];
       Position auxMedio = Position(
          longitude: medio.longitude, 
          latitude: medio.latitude, 
          timestamp: DateTime.now(), 
          accuracy: 1, 
          altitude: 0, 
          altitudeAccuracy: 10, 
          heading: 0.0, 
          headingAccuracy: 0.0, 
          speed: 0.0, 
          speedAccuracy: 0.0);

      _calculateDistancesLinea(auxMedio);
      // Actualiza la polilínea
      Polyline polyline = _polylines.firstWhere((p) => p.polylineId == const PolylineId('mi_polyline'));
      _polylines.remove(polyline);
      _polylines.add(polyline.copyWith(pointsParam: points));

      setState(() {}); // Actualiza el estado para reflejar los cambios en el mapa
    }

  Future<void> _calculateDistances() async {

    setState(() {
      showLoader=true;
    });

    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
     miLatitud=position.latitude;
     miLongitud=position.longitude;

     altitude=position.altitude; 

    Position frente = Position(
      longitude: widget.hoyo.hoyo.centroGreen!.longitud, 
      latitude: widget.hoyo.hoyo.centroGreen!.latitud, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);

    Position centro = Position(
      longitude: widget.hoyo.hoyo.centroGreen!.longitud, 
      latitude: widget.hoyo.hoyo.centroGreen!.latitud, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);

    Position fondo = Position(
      longitude: widget.hoyo.hoyo.fondoGreen!.longitud, 
      latitude: widget.hoyo.hoyo.fondoGreen!.latitud, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);

   
   
    if(mounted){
        setState(() {
          dCentro = calculateDistanceInYards(centro, position);
          dAtras=calculateDistanceInYards(fondo, position);
          dfrente=calculateDistanceInYards(frente,position);
          showLoader=false;
        });
    }
    
         
        
  }

  Future<void> _calculateDistancesLinea(Position medio) async {

    setState(() {
      showLoader=true;
    });

    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    // final position = await _geolocatorPlatform.getCurrentPosition();
    //  miLatitud=position.latitude;
    //  miLongitud=position.longitude;

    //  altitude=position.altitude; 

    

    Position centro = Position(
      longitude: widget.hoyo.hoyo.centroGreen!.longitud, 
      latitude: widget.hoyo.hoyo.centroGreen!.latitud, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);

   

     Position salida = Position(
      longitude: widget.hoyo.hoyo.teeBlancas!.longitud, 
      latitude: widget.hoyo.hoyo.teeBlancas!.latitud, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);
   
    if(mounted){
        setState(() {
          dSalidaMedio = calculateDistanceInYards(salida, medio);
          dMedioGreen=calculateDistanceInYards(medio, centro);         
          showLoader=false;
        });
    }
    
         
        
  }

  void _updatePositionList(PositionItemType type, String displayValue) {
    _positionItems.add(PositionItem(type, displayValue));
    setState(() {});
  }

  int calculateDistanceInYards(Position position1, Position position2) {

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

  double radians(double degrees) => degrees * (pi / 180.0);

  double degrees(double radians) => radians * (180.0 / pi);

   void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Stack(
             children: [
       GoogleMap(
        mapType: MapType.satellite,
          onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
        bearing: bearing,
          target: puntoMedio,
          zoom: 18.5,
        ),
        polylines: _polylines,
        markers: _markers,
       ),
        Positioned(
          top: 50, // Ajusta la distancia desde la parte superior
          left: 0, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment:  CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                icon: const Icon(Icons.arrow_back, size: 30.0, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                
              ),
              Text(
                  '${widget.hoyo.hoyo.nombre} | Par ${widget.hoyo.hoyo.par}',
                       style: const TextStyle(
                      fontFamily: 'RobotoCondensed',
                      // Puedes especificar el peso y el estilo si es necesario
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,
                       // Para un estilo en negrita
                       // Para un estilo en cursiva
                    ),
                ),
            ],),
          ),
        ),
       Positioned(
          top: SizeConfig.screenHeight / 2, // Ajusta la distancia desde la parte superior
          left: 20, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                InkWell(
                  onTap: () => _calculateDistances(),
                  child: Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                    const Text(
                        'CENTRO GREEN',
                        style: TextStyle(
                          fontSize: 15.0, // Tamaño de la fuente
                          fontWeight: FontWeight.bold, // Negrita
                          color: Colors.white, // Color de la fuente
                        ),
                      ),
                       Text(
                       '${dCentro.toString()}y',
                        style: const  TextStyle(
                            fontFamily: 'RobotoCondensed',
                            // Puedes especificar el peso y el estilo si es necesario
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                             // Para un estilo en negrita
                             // Para un estilo en cursiva
                          ),
                      ),
                     
                  
                    ],
                  ),
                ),
                showLoader ?  const Center(child: CircularProgressIndicator(backgroundColor: kPrimaryColor,)) : Container(),
              ],
            ),
          ),
        ),

         Positioned(
          top: SizeConfig.screenHeight / 3 * 2, // Ajusta la distancia desde la parte superior
          right: 0, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              const Text(
                  'PUNTO MEDIO',
                  style: TextStyle(
                    fontSize: 15.0, // Tamaño de la fuente
                    fontWeight: FontWeight.bold, // Negrita
                    color: Colors.white, // Color de la fuente
                  ),
                ),
                 Text(
                 '${dSalidaMedio.toString()}y',
                  style: const  TextStyle(
                      fontFamily: 'RobotoCondensed',
                      // Puedes especificar el peso y el estilo si es necesario
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,
                       // Para un estilo en negrita
                       // Para un estilo en cursiva
                    ),
                ),
            ],
           ),
          ),
        ),
          Positioned(
          top: SizeConfig.screenHeight / 3 , // Ajusta la distancia desde la parte superior
          right: 0, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              const Text(
                  'GREEN',
                  style: TextStyle(
                    fontSize: 15.0, // Tamaño de la fuente
                    fontWeight: FontWeight.bold, // Negrita
                    color: Colors.white, // Color de la fuente
                  ),
                ),
                 Text(
                 '${dMedioGreen.toString()}y',
                  style: const  TextStyle(
                      fontFamily: 'RobotoCondensed',
                      // Puedes especificar el peso y el estilo si es necesario
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,
                       // Para un estilo en negrita
                       // Para un estilo en cursiva
                    ),
                ),
            ],
           ),
          ),
        ),
        ],
      ),
         floatingActionButton: FloatingActionButton(
          onPressed: () => grabasGolpe(),
          shape: const CircleBorder(),
          backgroundColor: kPrimaryColor,
          elevation: 8,
          // Usamos un Container para personalizar el botón
          child: Container(
            width: double.infinity,  // Ocupar todo el ancho posible del botón
            height: double.infinity, // Ocupar toda la altura posible del botón
            decoration: const BoxDecoration(
              shape: BoxShape.circle,   // Forma circular
              // Personaliza tu botón aquí (color, sombras, etc.)
            ),
            child: const Center(
              child: Text(
                'GG', // El texto que quieres mostrar
                style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      // Puedes especificar el peso y el estilo si es necesario
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                       // Para un estilo en negrita
                       // Para un estilo en cursiva
                    ),
              ),
            ),
          ), // Esto mantiene la forma circular del botón
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
     
    );
  }

  void grabasGolpe() {
      _calculateDistances();
            Shot nuevoShot = Shot(latitud: miLatitud, longitud: miLatitud);
           widget.onAgregarShot(widget.hoyo.id, nuevoShot);
  }

 double calcularBearing(LatLng start, LatLng end) {
  var startLat = radians(start.latitude);
  var startLng = radians(start.longitude);
  var endLat = radians(end.latitude);
  var endLng = radians(end.longitude);

  var dLong = endLng - startLng;

  var dPhi = log(tan(endLat / 2.0 + pi / 4.0) / tan(startLat / 2.0 + pi / 4.0));
  if (dLong.abs() > pi) {
    if (dLong > 0.0) {
      dLong = -(2.0 * pi - dLong);
    } else {
      dLong = (2.0 * pi + dLong);
    }
  }

  return (degrees(atan2(dLong, dPhi)) + 360.0) % 360.0;
}
  
  void _calculateBering() {
    LatLng start = LatLng(widget.hoyo.hoyo.centroHoyo!.latitud, widget.hoyo.hoyo.centroHoyo!.longitud);
    LatLng end = LatLng(widget.hoyo.hoyo.centroGreen!.latitud, widget.hoyo.hoyo.centroGreen!.longitud);
    bearing = calcularBearing(start, end);
  }
}

