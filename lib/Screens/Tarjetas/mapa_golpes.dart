import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/constans.dart';

class MapaGolpes extends StatefulWidget {
  final EstadisticaHoyo estadisticaHoyo;
  final HoyoTee teeSalida;

  const MapaGolpes({super.key, required this.estadisticaHoyo, required this.teeSalida});

  @override
  MapaGolpesState createState() => MapaGolpesState();
}

class MapaGolpesState extends State<MapaGolpes> {
  late GoogleMapController mapController;
  late List<LatLng> puntos;
  late List<double> distancias;
  late Set<Polyline> polylines;
  late Set<Marker> markers;

  @override
  void initState() {
    super.initState();

    puntos = obtenerPuntosPolilinea(widget.estadisticaHoyo, widget.teeSalida);
    distancias = calcularDistancias(puntos);
    polylines = {
      Polyline(
        polylineId: const PolylineId('ruta_golpes'),
        points: puntos,
        color: Colors.blue,
        width: 4,
      ),
    };
    markers = Set.from(crearMarcadoresDistancia(puntos, distancias));

    // Agregar marcadores para el inicio y el final
    markers.add(
      Marker(
        markerId: const MarkerId('inicio'),
        position: puntos.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Tee de salida'),
      ),
    );

   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title: widget.estadisticaHoyo.hoyo.nombre,
        automaticallyImplyLeading: true,   
        backgroundColor: kPprimaryColor,
        elevation: 8.0,
        shadowColor: const Color.fromARGB(255, 2, 44, 68),
        foreColor: Colors.white,
         actions: [ Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipOval(child:  Image.asset(
                  'assets/LogoGolf.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),), // Ícono de perfil de usuario
            ),],
      ),
      body: GoogleMap(
         mapType: MapType.satellite,
        initialCameraPosition: CameraPosition(
          target: puntos.first,
          zoom: 16,
        ),
        polylines: polylines,
        markers: markers,
        onMapCreated: (controller) {
          mapController = controller;
          _ajustarVistaMapa();
        },
      ),
    );
  }

  void _ajustarVistaMapa() {
    if (puntos.isEmpty) return;

    LatLngBounds bounds = _crearBounds(puntos);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _crearBounds(List<LatLng> puntos) {
    double southWestLat = puntos.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double southWestLng = puntos.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double northEastLat = puntos.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double northEastLng = puntos.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  List<Marker> crearMarcadoresDistancia(List<LatLng> puntos, List<double> distancias) {
  List<Marker> marcadores = [];

  for (int i = 0; i < puntos.length - 1; i++) {
    // Calcular el punto medio
    // LatLng puntoMedio = LatLng(
    //   (puntos[i].latitude + puntos[i + 1].latitude) / 2,
    //   (puntos[i].longitude + puntos[i + 1].longitude) / 2,
    // );

     marcadores.add(
      Marker(
        markerId: MarkerId('golpe_$i'),
        position: puntos[i+1],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: '${distancias[i].toStringAsFixed(1)} yds',
        ),
      ),
    );

    // Crear el marcador punto medio
    // marcadores.add(
    //   Marker(
    //     markerId: MarkerId('distancia_$i'),
    //     position: puntoMedio,
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    //     infoWindow: InfoWindow(
    //       title: '${distancias[i].toStringAsFixed(1)} yds',
    //     ),
    //   ),
    // );
  }

  return marcadores;
}

List<double> calcularDistancias(List<LatLng> puntos) {
  List<double> distancias = [];

  for (int i = 0; i < puntos.length - 1; i++) {
    double distancia = Geolocator.distanceBetween(
      puntos[i].latitude,
      puntos[i].longitude,
      puntos[i + 1].latitude,
      puntos[i + 1].longitude,
    );

    // Convertir metros a yardas si es necesario
    double distanciaEnYardas = distancia * 1.09361;

    distancias.add(distanciaEnYardas);
  }

  return distancias;
}

List<LatLng> obtenerPuntosPolilinea(EstadisticaHoyo estadisticaHoyo, HoyoTee tee) {
  List<LatLng> puntos = [];

  // Agregar el punto inicial (coordenadas del tee)
  puntos.add(LatLng(tee.cordenada.latitud, tee.cordenada.longitud));

  // Agregar los puntos de los shots
  if (estadisticaHoyo.shots != null && estadisticaHoyo.shots!.isNotEmpty) {
    for (var shot in estadisticaHoyo.shots!) {
      puntos.add(LatLng(shot.latitud, shot.longitud));
    }
  }

  // // Agregar el punto final (centro del green)
  // puntos.add(LatLng(
  //   estadisticaHoyo.hoyo.centroGreen!.latitud,
  //   estadisticaHoyo.hoyo.centroGreen!.longitud,
  // ));

  return puntos;
}



}
