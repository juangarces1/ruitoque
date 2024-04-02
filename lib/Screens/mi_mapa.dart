import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Components/distance_item.dart';
import 'package:ruitoque/Components/enum.dart';
import 'package:ruitoque/Components/position_item.dart';
import 'package:ruitoque/Models/hoyo.dart';

class MiMapa extends StatefulWidget {
  final Hoyo hoyo;
  
  const MiMapa({
    required this.hoyo,
    
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
  bool showLoader = false;
  double? altitude = 0;
  double bearing=0;

  double miLatitud = 0;
  double miLongitud=0;
 

  @override
  void initState() {
    super.initState();
    
    _calculateDistances();
   _calculateBering();
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
      longitude: widget.hoyo.longitudFrente, 
      latitude: widget.hoyo.latitudFrente, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);

    Position centro = Position(
      longitude: widget.hoyo.longitudCentro, 
      latitude: widget.hoyo.latitudCentro, 
      timestamp: DateTime.now(), 
      accuracy: 1, 
      altitude: 0, 
      altitudeAccuracy: 10, 
      heading: 0.0, 
      headingAccuracy: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0);

    Position fondo = Position(
      longitude: widget.hoyo.longitudFondo, 
      latitude: widget.hoyo.latitudFondo, 
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


  @override
  Widget build(BuildContext context) {
     return SafeArea(
       child: Scaffold(
        body: Stack(
               children: [
         GoogleMap(
          mapType: MapType.satellite,
          initialCameraPosition: CameraPosition(
          bearing: bearing,
            target: LatLng(widget.hoyo.latitudCentroHoyo, widget.hoyo.longitudCentroHoyo),
            zoom: 18.5,
          ),
         ),
         Positioned(
            top: 0, // Ajusta la distancia desde la parte superior
            right: 0, // Ajusta la distancia desde la izquierda
            child: Opacity(
              opacity: 0.5,
              child: Container(
              //  width: 150, // Ajusta la anchura del panel
              //  height: 300, // Ajusta la altura del panel
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment:  CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.golf_course, color: Colors.green, size: 40,),
                        Text(widget.hoyo.numero.toString(),  style:  const TextStyle(
                        color: Colors.black,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                                               ),),
                      ],
                    ),
                                     
                      DistanceItem(number: 'A', distance: dAtras.toString(), color: Colors.black, isCenter: false,),
                      const SizedBox(height: 2,),
                      DistanceItem(number: 'C', distance: dCentro.toString(), color: Colors.red, isCenter: true,),
                      const SizedBox(height: 2,),
                      DistanceItem(number: 'F', distance: dfrente.toString(), color: Colors.black, isCenter: false,),
                  ],),
                )
              ),
            ),
          ),
               ],
             ),
       ),
     );
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
    LatLng start = LatLng(widget.hoyo.latitudCentroHoyo, widget.hoyo.longitudCentroHoyo);
    LatLng end = LatLng(widget.hoyo.latitudCentro, widget.hoyo.longitudCentro);
    bearing = calcularBearing(start, end);
  }
}

