import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ruitoque/Components/distance_item.dart';
import 'package:ruitoque/Components/enum.dart';
import 'package:ruitoque/Components/position_item.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Screens/mi_mapa.dart';

class GolfWatchScreen extends StatefulWidget {
  final Hoyo hoyo;
  const GolfWatchScreen({super.key, required this.hoyo});
  @override
  State<GolfWatchScreen> createState() => _GolfWatchScreenState();
}

class _GolfWatchScreenState extends State<GolfWatchScreen> {
 
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

  @override
  void initState() {
    super.initState();
    
    _calculateDistances();
  }

  // Obtener la posición actual del usuario
 Future<void> _calculateDistances() async {

    setState(() {
      showLoader=true;
    });

    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();

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

    setState(() {
      dCentro = calculateDistanceInYards(centro, position);
      dAtras=calculateDistanceInYards(fondo, position);
      dfrente=calculateDistanceInYards(frente,position);
      showLoader=false;
    });
         
        
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

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
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
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(
          PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }


  @override
  Widget build(BuildContext context) {
   
    return  SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                 const SizedBox(height: 20,),
                  const Text(
                    'Distancias',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                     Text(
                    'Mi Altitud ${altitude.toString()}',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                   const SizedBox(height: 5,),
                      Center(
                        child: ListTile(
                                      leading: const Icon(Icons.flag, color: Colors.green,),
                                      title: Text(widget.hoyo.nombre,  style:  const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      
                                        ),)),
                      ),
                          DistanceItem(number: 'Atras', distance: dAtras.toString(), color: Colors.blue, isCenter: false,),
                                    const SizedBox(height: 2,),
                                       DistanceItem(number: 'Centro', distance: dCentro.toString(), color: Colors.green, isCenter: true,),
                                      const SizedBox(height: 2,),
                                       DistanceItem(number: 'Frente', distance: dfrente.toString(), color: Colors.indigo, isCenter: false,),
                const SizedBox(height: 10,),  
                                        IconButton(
                    icon:  const Icon(Icons.refresh, color: Colors.white, size: 36,),
                    onPressed:  _calculateDistances,
                  ),
             
                   
            ],
          ),
        ),
       
      ),
    );
  }

 
  
 
}






