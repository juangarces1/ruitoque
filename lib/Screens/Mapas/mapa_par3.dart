import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Components/enum.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Components/position_item.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MiMapaPar3 extends StatefulWidget {
  final String teeSalida;
  final EstadisticaHoyo hoyo;
  final Function(int, Shot) onAgregarShot;
   final Function(int, Shot) onDeleteShot;
  const MiMapaPar3({
    required this.hoyo,
     required this.onAgregarShot,
     required this.teeSalida,
    super.key, required this.onDeleteShot});

  @override
  State<MiMapaPar3> createState() => _MiMapaPar3State();
}

class _MiMapaPar3State extends State<MiMapaPar3> { 
  static const String _kLocationServicesDisabledMessage = 'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =  'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<PositionItem> _positionItems = <PositionItem>[]; 
  bool positionStreamStarted = false;
  int? dHoyo = 0;
  int? dCentro = 0;
  int? dfrente = 0;
  int? dAtras = 0;
  int? dPuntoFinal=0;
  bool showLoader = false;
  double? altitude = 0;
  double bearing=0;
  late String distanciaHoyo;
  double miLatitud = 0;
  double miLongitud=0;
   late  GoogleMapController mapController;
  late LatLng puntoA; // Tus coordenadas aquí
  late LatLng puntoB; // Tus coordenadas aquí 
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};  
  late Position salida;   
  late HoyoTee? tee;
  late LatLng makerA;

   Offset offsetAMedio = const Offset(0, 0); 
   final GlobalKey _mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();    
    setInitialData();
    _calculateBering();
  }

  void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    updateScreenCoordinates();
  });
}


  Future<void> updateScreenCoordinates() async {   
    Offset offsetaMediotemp   = await getScreenPosition(makerA);  
      setState(() {
        offsetAMedio = offsetaMediotemp;      
      });   
  }

  void setInitialData ()  {
     //Encontramos el Tee desde el cual jugamos
     tee = encontrarHoyoTeePorColor(widget.hoyo.hoyo.hoyotees!, widget.teeSalida);
     //el puntaA o de inicio es la coordenada del tee que escogimos
     puntoA = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);   
     //el puntoB o de fin es la cordenada del centro del hoyo al que vamos  
     puntoB = LatLng(widget.hoyo.hoyo.centroGreen!.latitud, widget.hoyo.hoyo.centroGreen!.longitud);
     //ek punto medio es la cordenada del centro del hoyo
      //Calculamos los puntos de los makers
     makerA = calcularPuntoMedio(puntoA, puntoB);
    
      //inicializamos la position de la salida para calcular las distacias luego
     salida = Position(
        longitude: tee!.cordenada.longitud, 
        latitude: tee!.cordenada.latitud,
        timestamp: DateTime.now(), 
        accuracy: 1, 
        altitude: 0, 
        altitudeAccuracy: 10, 
        heading: 0.0, 
        headingAccuracy: 0.0, 
        speed: 0.0, 
        speedAccuracy: 0.0
      );  

      Position puntoFin =  Position(
        longitude: widget.hoyo.hoyo.centroGreen!.longitud, 
        latitude: widget.hoyo.hoyo.centroGreen!.latitud, 
        timestamp: DateTime.now(), 
        accuracy: 1, 
        altitude: 0, 
        altitudeAccuracy: 10, 
        heading: 0.0, 
        headingAccuracy: 0.0, 
        speed: 0.0, 
        speedAccuracy: 0.0
      );  
     
       
      //agregamos la polyline con sus cordenadas
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('mi_polyline'),
        points: [puntoA,  puntoB],
        width: 2,
        color: Colors.white,
      ),
    );

      //creamos el marcador
      _crearMarcadorPersonalizado();

     //Calculamos las Distancias de las lineas es decir la distancia del puntaA al pMedio y del PMedio a puntoB
     _calculateDistancesLinea(puntoFin);

     //aqui calculamos las distancias de nuestra posicion al frente centre y fondo del green
     _calculateDistances();   


     setState(() {}); 
  }

  Future<Offset> getScreenPosition(LatLng punto) async {
  ScreenCoordinate screenCoordinate = await mapController.getScreenCoordinate(punto);
  double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  double adjustedX = screenCoordinate.x.toDouble() / devicePixelRatio;
  double adjustedY = screenCoordinate.y.toDouble() / devicePixelRatio; 
  return Offset(adjustedX, adjustedY);
}

  Future<void> _crearMarcadorPersonalizado() async {    
  
      BitmapDescriptor iconoPersonalizado = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/newMarker.png');

      Marker markerPersonalizado = Marker(
        markerId: const MarkerId('puntoMedio'),
        position: puntoB, // Asegúrate de tener definida esta variable
        draggable: true,
        icon: iconoPersonalizado,
        anchor: const Offset(0.5, 0.5),
        onDragEnd: (newPosition) {
          _updatePolyline(puntoA,  newPosition);
        },
      );

      setState(() {
        _markers.add(markerPersonalizado);
      });
  }

  HoyoTee? encontrarHoyoTeePorColor(List<HoyoTee> hoyos, String color) {
  for (var hoyotee in hoyos) {
    if (hoyotee.color.toLowerCase() == color.toLowerCase()) {
      return hoyotee;
    }
  }
  return null; // Retorna null si no encuentra ninguna coincidencia
}

  LatLng calcularPuntoMedio(LatLng puntoA, LatLng puntoB) {
  double latitudMedia = (puntoA.latitude + puntoB.latitude) / 2;
  double longitudMedia = (puntoA.longitude + puntoB.longitude) / 2;
  
  return LatLng(latitudMedia, longitudMedia);
}

  void _updatePolyline(LatLng inicio,  LatLng fin) {
      // Crea una nueva lista de puntos para la polilínea
      
      List<LatLng> points = [inicio,  fin];
       Position auxFin = Position(
          longitude: fin.longitude, 
          latitude: fin.latitude, 
          timestamp: DateTime.now(), 
          accuracy: 1, 
          altitude: 0, 
          altitudeAccuracy: 10, 
          heading: 0.0, 
          headingAccuracy: 0.0, 
          speed: 0.0, 
          speedAccuracy: 0.0);

      _calculateDistancesLinea(auxFin);

    
      
      // Actualiza la polilínea
      Polyline polyline = _polylines.firstWhere((p) => p.polylineId == const PolylineId('mi_polyline'));
      _polylines.remove(polyline);
      _polylines.add(polyline.copyWith(pointsParam: points));
     
      makerA = calcularPuntoMedio(puntoA, fin);
       updateScreenCoordinates();


      setState(() {}); // Actualiza el estado para reflejar los cambios en el mapa
    }

  Future<Offset> getMarkerScreenPosition(LatLng latLng, GoogleMapController mapController) async {
  // Obtener las coordenadas de pantalla del marcador
    ScreenCoordinate screenCoordinate = await mapController.getScreenCoordinate(latLng);
    
    // Convertir las coordenadas de pantalla a Offset (coordenadas en Flutter)
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      // Convertir a coordenadas de la pantalla en Flutter
      return Offset(
        screenCoordinate.x.toDouble(), 
        screenCoordinate.y.toDouble(),
      );
    } else {
      return Offset.zero;
    }
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
          dHoyo = tee!.distancia == 0 ? calculateDistanceInYards(salida, centro) : tee!.distancia;
          showLoader=false;
        });
    }
    
         
        
  }

  Future<void> _calculateDistancesLinea(Position fin) async {
   
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }             
   
    if(mounted){
        setState(() {
          dPuntoFinal = calculateDistanceInYards(salida, fin); 
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

 void _onCameraIdle() {
  updateScreenCoordinates();
}

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Stack(
      children: [
         GoogleMap(
          key: _mapKey,
            mapType: MapType.satellite,
              onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
            bearing: bearing,
              target: makerA,
              zoom: 19.25,
            ),
            polylines: _polylines,
            markers: _markers,
            onCameraIdle: _onCameraIdle,

        ),

     Positioned(
          left: offsetAMedio.dx - 20, // Ajuste para centrar mejor el círculo
          top: offsetAMedio.dy - 20,  // Ajuste para centrar mejor el círculo
          child: ClipOval(
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(9.0), // Ajuste del padding para que el texto quede dentro del círculo
              color: Colors.white,
              child: Text(
                dPuntoFinal.toString(),
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center, // Centrar el texto dentro del círculo
              ),
            ),
          ),
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
                  '${widget.hoyo.hoyo.nombre}| Par ${widget.hoyo.hoyo.par} | ${dHoyo}y',
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
          top: 50, // Ajusta la distancia desde la parte superior
          right: 0, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40.0,
              width: 40.0,
              child: FloatingActionButton(
                onPressed: () => _calculateDistances(),
                backgroundColor: Colors.white,
                child: const Icon(Icons.refresh, color: Colors.black), // Ícono dentro del botón
              ),
            ),
          ),
        ),


        Positioned(
          top: SizeConfig.screenHeight / 2 - 80, // Ajusta la distancia desde la parte superior
          left: 20, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              const Text(
                  'Fondo',
                  style: TextStyle(
                    fontSize: 15.0, // Tamaño de la fuente
                    fontWeight: FontWeight.bold, // Negrita
                    color: Colors.white, // Color de la fuente
                  ),
                ),
                 Text(
                 '${dAtras.toString()}y',
                  style: const  TextStyle(
                      fontFamily: 'RobotoCondensed',
                      // Puedes especificar el peso y el estilo si es necesario
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
          top: SizeConfig.screenHeight / 2, // Ajusta la distancia desde la parte superior
          left: 20, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              const Text(
                  'Centro',
                  style: TextStyle(
                    fontSize: 20.0, // Tamaño de la fuente
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
                      fontSize: 28,
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
          top: SizeConfig.screenHeight / 2 + 80, // Ajusta la distancia desde la parte superior
          left: 20, // Ajusta la distancia desde la izquierda
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              const Text(
                  'Frente ',
                  style: TextStyle(
                    fontSize: 15.0, // Tamaño de la fuente
                    fontWeight: FontWeight.bold, // Negrita
                    color: Colors.white, // Color de la fuente
                  ),
                ),
                 Text(
                 '${dfrente.toString()}y',
                  style: const  TextStyle(
                      fontFamily: 'RobotoCondensed',
                      // Puedes especificar el peso y el estilo si es necesario
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                       // Para un estilo en negrita
                       // Para un estilo en cursiva
                    ),
                ),  
              ],
            ),
          ),
        ),
       
        
          showLoader ? const MyLoader(text: 'Actualizando...', opacity: 0.8,) : const SizedBox()
        ],
      ),
         floatingActionButton: GestureDetector(
          onLongPress:() => mostrarModalDeDistancias(context),
           child: FloatingActionButton(
            heroTag: 'UniqueTag',
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
         ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
     
    );
  }

 void grabasGolpe() async {
  await _calculateDistances(); // Asegúrate de tener la posición actualizada

  LatLng puntoAnterior;

  if (widget.hoyo.shots == null || widget.hoyo.shots!.isEmpty) {
    // Si no hay shots registrados, usar el puntoA
    puntoAnterior = puntoA;
  } else {
    // Si ya hay shots, usar la última posición registrada
    Shot ultimoShot = widget.hoyo.shots!.last;
    puntoAnterior = LatLng(ultimoShot.latitud, ultimoShot.longitud);
  }

  // Obtener la posición actual
  Position position = await _geolocatorPlatform.getCurrentPosition();
  LatLng puntoActual = LatLng(position.latitude, position.longitude);

  // Calcular la distancia en yardas
  int distancia = calculateDistanceInYards(Position(
    latitude: puntoAnterior.latitude,
    longitude: puntoAnterior.longitude,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 10,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  ), Position(
    latitude: puntoActual.latitude,
    longitude: puntoActual.longitude,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 10,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  ));

  // Crear un nuevo shot con la distancia calculada
  Shot nuevoShot = Shot(
    latitud: puntoActual.latitude,
    longitud: puntoActual.longitude,
    distancia: distancia,
  );

  // Agregar el shot a la lista y ejecutar el callback
  widget.onAgregarShot(widget.hoyo.id, nuevoShot);
 // widget.hoyo.shots = [...?widget.hoyo.shots, nuevoShot];

  setState(() {});
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
    LatLng start = LatLng(tee!.cordenada.latitud, tee!.cordenada.longitud);
    LatLng end = LatLng(widget.hoyo.hoyo.centroGreen!.latitud, widget.hoyo.hoyo.centroGreen!.longitud);
    bearing = calcularBearing(start, end);
  }

  @override
  void dispose() {
    
    super.dispose();
    mapController.dispose();
  }
  
 void mostrarModalDeDistancias(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: 300, // Ajusta la altura según tus necesidades
            child: widget.hoyo.shots == null || widget.hoyo.shots!.isEmpty
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
                    itemCount: widget.hoyo.shots!.length,
                    itemBuilder: (context, index) {
                      final shot = widget.hoyo.shots![index];
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
                            widget.onDeleteShot(widget.hoyo.id, shot);
                            // Actualizar el estado del modal
                            setModalState(() {});
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

