
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/Providers/cordenada_provider.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/constans.dart';

class EditarCoordenadaScreen extends StatefulWidget {
  final Cordenada coordenadaInicial;  
  final String? titulo;
  final Function(Cordenada) onCoordenadaActualizada;

  const EditarCoordenadaScreen({super.key, required this.coordenadaInicial, required this.onCoordenadaActualizada,  this.titulo});

  @override
  EditarCoordenadaScreenState createState() => EditarCoordenadaScreenState();
}

class EditarCoordenadaScreenState extends State<EditarCoordenadaScreen> {
  late GoogleMapController mapController;
  late LatLng? _seleccionada;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  @override
  void initState() {
    super.initState();
   
      _seleccionada =  LatLng(widget.coordenadaInicial.latitud, widget.coordenadaInicial.longitud );
    
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _seleccionarCoordenada(LatLng position) {
    setState(() {
      _seleccionada = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    var cordenadaProvider = Provider.of<CordenadaProvider>(context);
    return Scaffold(
     
      appBar:  PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child:MyCustomAppBar(
                        title: widget.titulo != null ? widget.titulo! : 'Establecer Coordenada',
                          automaticallyImplyLeading: true,   
                          backgroundColor: kPrimaryColor,
                          elevation: 8.0,
                          shadowColor: const Color.fromARGB(255, 244, 244, 245),
                          foreColor: Colors.white,
                          actions: [ 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                    'assets/LogoGolf.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ), // Ícono de perfil de usuario
                              ),
                          ],
                        
                        ),
              
                  ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kFondoGradient
        ),
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                   mapType: MapType.satellite,
                initialCameraPosition: CameraPosition(
                  target: _seleccionada ?? const LatLng(0, 0), // Ubicación por defecto
                  zoom: 20.0,
                ),
                onTap: _seleccionarCoordenada,
                markers: _seleccionada != null
                    ? {
                        Marker(
                          markerId: const MarkerId('seleccionada'),
                          position: _seleccionada!,
                        ),
                      }
                    : {},
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                  Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        child: ElevatedButton(
                             onPressed: () {
                                  if (_seleccionada != null) {
                                    widget.onCoordenadaActualizada(Cordenada(
                                      id:0,
                                      latitud: _seleccionada!.latitude,
                                      longitud: _seleccionada!.longitude,
                                    ));
                                  }
                                    cordenadaProvider.actualizarCordenada(_seleccionada!.latitude, _seleccionada!.longitude);
                                  Navigator.pop(context);
                                },
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPrimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                           child: const Text('Guardar Coordenada'),
                          ),
                      ),
             
                    IconButton(
                  icon: const Icon(Icons.pin_drop_outlined),
                  iconSize: 40.0, // Tamaño del ícono
                  color: Colors.white70, // Color del ícono
                  onPressed: () async {
                   Position position = await _geolocatorPlatform.getCurrentPosition();
                    widget.onCoordenadaActualizada(Cordenada(
                        id:0,
                        latitud: position.latitude,
                        longitud: position.longitude,
                      ));
                    
                     cordenadaProvider.actualizarCordenada(position.latitude, position.longitude);
                    if(mounted){
                        Navigator.pop(context);
                    }
                      
                  },
                ),
                  ],
            ),
            
          ],
        ),
      ),
    );
  }
}


