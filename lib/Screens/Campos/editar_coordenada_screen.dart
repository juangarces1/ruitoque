
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Models/cordenada.dart';

class EditarCoordenadaScreen extends StatefulWidget {
  final Cordenada? coordenadaInicial;
  final Cordenada? ubicacion;
  final Function(Cordenada) onCoordenadaActualizada;

  const EditarCoordenadaScreen({super.key, this.coordenadaInicial, required this.onCoordenadaActualizada, required this.ubicacion});

  @override
  EditarCoordenadaScreenState createState() => EditarCoordenadaScreenState();
}

class EditarCoordenadaScreenState extends State<EditarCoordenadaScreen> {
  late GoogleMapController mapController;
  late LatLng? _seleccionada;

  @override
  void initState() {
    super.initState();
   
      _seleccionada =  LatLng(widget.ubicacion!.latitud, widget.ubicacion!.longitud );
    
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Coordenada'),
      ),
      body: Column(
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
          ElevatedButton(
            onPressed: () {
              if (_seleccionada != null) {
                widget.onCoordenadaActualizada(Cordenada(
                  id:0,
                  latitud: _seleccionada!.latitude,
                  longitud: _seleccionada!.longitude,
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar Coordenada'),
          ),
        ],
      ),
    );
  }
}


