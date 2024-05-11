import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Models/hoyo.dart';

class AgregarCampoScren extends StatefulWidget {
  const AgregarCampoScren({super.key});

  @override
  State<AgregarCampoScren> createState() => _AgregarCampoScrenState();
}

class _AgregarCampoScrenState extends State<AgregarCampoScren> {
  final _formKey = GlobalKey<FormState>();
  final Hoyo _hoyo = Hoyo(id: 0, numero: 0, nombre: '', par: 0, campoId: 1);
  late  String? selectedCordentada; 
 
  final List<String> opcionesCoordenadas = [
  'frenteGreen',
  'centroGreen',
  'fondoGreen',
  'centroHoyo',
 
  // Puedes agregar más si tu modelo Hoyo tiene más campos de coordenadas
];

 late GoogleMapController mapController;

  final LatLng _centro = const LatLng(7.024892, -73.081839);

  LatLng? _ultimaPosicionSeleccionada;

 void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
     selectedCordentada = opcionesCoordenadas.isNotEmpty ? opcionesCoordenadas.first : null;
  }

  String nombreCampo = '';
  String ubicacion = '';



  @override
  Widget build(BuildContext context) {
   return SafeArea(
     child: Scaffold(
       
        body: Column( // o Column si prefieres vertical
          children: <Widget>[
           
             SizedBox(
              height: 200,
              child: Form(
                key: _formKey,
                child: ListView(
                     padding: const EdgeInsets.all(16.0),
                     children: [
                    TextFormField(
                        decoration: const InputDecoration(labelText: 'Nombre del Campo'),
                        initialValue: nombreCampo,
                        onSaved: (value) => nombreCampo = value ?? '',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el nombre del campo';
                          }
                          return null;
                        },
                      ),
     
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Ubicación'),
                        initialValue: ubicacion,
                        onSaved: (value) => ubicacion = value ?? '',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la ubicación';
                          }
                          return null;
                        },
                      ),
     
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Número'),
                          initialValue: _hoyo.numero.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _hoyo.numero = int.tryParse(value!) ?? 0,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa un número';
                            }
                            return null;
                          },
                        ),
     
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Nombre'),
                          initialValue: _hoyo.nombre,
                          onSaved: (value) => _hoyo.nombre = value!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa un nombre';
                            }
                            return null;
                          },
                        ),
     
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Par'),
                          initialValue: _hoyo.par.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _hoyo.par = int.tryParse(value!) ?? 0,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa un valor para el par';
                            }
                            return null;
                          },
                        ),
     
                      
     
                        // Agrega TextFormFields para los campos opcionales si es necesario
                        // Por ejemplo, para el handicap:
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Handicap'),
                          initialValue: _hoyo.handicap?.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _hoyo.handicap = int.tryParse(value!),
                        ),
     
                    
     
                    
     
                   
     
                     
     
                     
     
                         DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Seleccionar Coordenada'),
                          value: selectedCordentada,
                          items: opcionesCoordenadas.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCordentada = newValue;
                              // Asigna el valor al campo correspondiente
                              // _hoyo.centroGreen = obtenerCoordenadaSegunSeleccion(newValue);
                            });
                          },
                        ),
     
                         ElevatedButton(
                          child: const Text('Guardar Cordenada'),
                          onPressed: () => guardarCordenada(),
                        ),
     
                        // No olvides el botón para enviar el formulario
                        ElevatedButton(
                          child: const Text('Guardar Hoyo'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              // Lógica para guardar tu modelo Hoyo
                            }
                          },
                        ),
                     ],
              ),) ),
     
              SizedBox(
                height: 500.0, // Altura del contenedor
                child: GoogleMap(
                   mapType: MapType.satellite,
                  onMapCreated: _onMapCreated,
                  onTap: (LatLng posicion) {
                      setState(() {
                        _ultimaPosicionSeleccionada = posicion;
                      });
                    },
                  initialCameraPosition: CameraPosition(
                    target: _centro,
                    zoom: 11.0,
                  ),
                ),
              ),
            
          ],
        ),
         floatingActionButton: FloatingActionButton(
          onPressed: _guardarPosicion,
          tooltip: 'Guardar Posición',
          child: const Icon(Icons.save),
        ),
      ),
   );
  }

   void _guardarPosicion() {
    if (_ultimaPosicionSeleccionada != null) {
      // Aquí puedes guardar la posición, mostrar un Snackbar, etc.
      print('latitud : ${_ultimaPosicionSeleccionada!.latitude} Longitud : ${_ultimaPosicionSeleccionada!.longitude.toString()}');
    }
  }
  
  guardarCordenada() {}

  
}