import 'package:flutter/material.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/tipos_cordenada.dart';
import 'package:ruitoque/Screens/Campos/editar_coordenada_screen.dart';

class AgregarHoyosScreen extends StatefulWidget {
  final Function(Hoyo) onAgregarHoyo;
  const AgregarHoyosScreen({super.key, required this.onAgregarHoyo});

  @override
  State<AgregarHoyosScreen> createState() => _AgregarHoyosScreenState();
}

class _AgregarHoyosScreenState extends State<AgregarHoyosScreen> {

    Hoyo nuevoHoyo = Hoyo(
      id: 0,
      nombre: '',
      numero: 0,
      par:0,
      campoId: 0,
      distamciaAzules: 0,
      distanciaAmarillas: 0,
      distanciaBlancas: 0,
      distanciaNegras: 0,
      distanciaRojas: 0,
      fondoGreen: Cordenada(id: 0, latitud: 0,longitud: 0),
      frenteGreen: Cordenada(id: 0, latitud: 0,longitud: 0),
      centroGreen: Cordenada(id: 0, latitud: 0,longitud: 0),
      centroHoyo: Cordenada(id: 0, latitud: 0,longitud: 0),
      teeAmarillas: Cordenada(id: 0, latitud: 0,longitud: 0),
      teeAzules: Cordenada(id: 0, latitud: 0,longitud: 0),
      teeBlancas: Cordenada(id: 0, latitud: 0,longitud: 0),
      teeNegras: Cordenada(id: 0, latitud: 0,longitud: 0),
      teeRojas: Cordenada(id: 0, latitud: 0,longitud: 0),
        // Inicializa los valores requeridos aquí
      );

  List<TipoCoordenada> tiposCoordenadas = TipoCoordenada.values;
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nombreController = TextEditingController();
  final _parController = TextEditingController();
  final _handicapController = TextEditingController();

  final _distanciaNegras = TextEditingController();
  final _distanciaAzules = TextEditingController();
  final _distanciaBlancas = TextEditingController();
  final _distanciaAmarillas = TextEditingController();
  final _distanciaRojas = TextEditingController();
  Cordenada ubicacion= Cordenada(id: 0, latitud: 7.024484, longitud: -73.084170);


  void _editarCoordenada(TipoCoordenada tipo) async {
  Cordenada? coordenadaInicial;
  switch (tipo) {
    case TipoCoordenada.frenteGreen:
      coordenadaInicial = nuevoHoyo.frenteGreen;
      break;
    case TipoCoordenada.centroGreen:
      coordenadaInicial = nuevoHoyo.centroGreen;
      break;
    case TipoCoordenada.fondoGreen:
      coordenadaInicial = nuevoHoyo.fondoGreen;
      break;
     case TipoCoordenada.centroHoyo:
      coordenadaInicial = nuevoHoyo.centroHoyo;
      break;  
      case TipoCoordenada.teeAmarillas:
      coordenadaInicial = nuevoHoyo.teeAmarillas;
      break;  
       case TipoCoordenada.teeAzules:
      coordenadaInicial = nuevoHoyo.teeAzules;
      break;  

       case TipoCoordenada.teeBlancas:
      coordenadaInicial = nuevoHoyo.teeBlancas;
      break;  

       case TipoCoordenada.teeNegras:
      coordenadaInicial = nuevoHoyo.teeNegras;
      break;  

       case TipoCoordenada.teeRojas:
      coordenadaInicial = nuevoHoyo.teeRojas;
      break;  


  }

  final coordenadaActualizada = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditarCoordenadaScreen(
        coordenadaInicial: coordenadaInicial,
        ubicacion: ubicacion,
        onCoordenadaActualizada: (nuevaCoordenada) {
          // Esta es la lógica para actualizar la coordenada en el Hoyo
          setState(() {
            ubicacion=nuevaCoordenada;
            switch (tipo) {
              case TipoCoordenada.frenteGreen:
                nuevoHoyo.frenteGreen = nuevaCoordenada;
                break;
              case TipoCoordenada.centroGreen:
                nuevoHoyo.centroGreen = nuevaCoordenada;
                break;
              case TipoCoordenada.fondoGreen:
                nuevoHoyo.fondoGreen = nuevaCoordenada;
                break;
              case TipoCoordenada.centroHoyo:
                nuevoHoyo.centroHoyo = nuevaCoordenada;
                break; 
              case TipoCoordenada.teeAmarillas:
                nuevoHoyo.teeAmarillas = nuevaCoordenada;
                break; 
              case TipoCoordenada.teeAzules:
                nuevoHoyo.teeAzules = nuevaCoordenada;
                break;     
              case TipoCoordenada.teeBlancas:
                nuevoHoyo.teeBlancas = nuevaCoordenada;
                break; 
              case TipoCoordenada.teeNegras:
                nuevoHoyo.teeNegras = nuevaCoordenada;
                break; 
              case TipoCoordenada.teeRojas:
                nuevoHoyo.teeRojas = nuevaCoordenada;
                break; 
              // Continúa para los otros tipos de coordenadas
              // ...
            }
          });
        },
      ),
    ),
    
  );
  }

  // Tu lógica para agregar hoyos va aquí
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Hoyo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(labelText: 'Número del Hoyo'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.numero = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.nombre = value;
                          });
                        }
                      },
                    ),
                   
                    TextFormField(
                      controller: _parController,
                      decoration: const InputDecoration(labelText: 'Par'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.par = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: _handicapController,
                      decoration: const InputDecoration(labelText: 'Handicap'),
                      keyboardType: TextInputType.number,
                       onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.handicap = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                     TextFormField(
                      controller: _distanciaNegras,
                      decoration: const InputDecoration(labelText: 'Distancia Negras'),
                      keyboardType: TextInputType.number,
                       onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.distanciaNegras = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                     TextFormField(
                      controller: _distanciaAzules,
                      decoration: const InputDecoration(labelText: 'Distancia Azules'),
                      keyboardType: TextInputType.number,
                       onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.distamciaAzules = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                     TextFormField(
                      controller: _distanciaBlancas,
                      decoration: const InputDecoration(labelText: 'Distancia Blancas'),
                      keyboardType: TextInputType.number,
                       onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.distanciaBlancas = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                     TextFormField(
                      controller: _distanciaAmarillas,
                      decoration: const InputDecoration(labelText: 'Distancia Amarillas'),
                      keyboardType: TextInputType.number,
                       onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.distanciaAmarillas = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                     TextFormField(
                      controller: _distanciaRojas,
                      decoration: const InputDecoration(labelText: 'Distancia Rojas'),
                      keyboardType: TextInputType.number,
                       onChanged: (value) {
                      if (value.isNotEmpty) {
                          setState(() {
                            nuevoHoyo.distanciaRojas = int.tryParse(value) ?? 0;
                          });
                        }
                      },
                    ),
                    // Añadir más campos según sea necesario
                  ],
                ),
              ),
            ),
            const Divider(),
            Text('Coordenadas', style: Theme.of(context).textTheme.titleLarge),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Para evitar scroll dentro de scroll
              itemCount: TipoCoordenada.values.length,
              itemBuilder: (context, index) {
                var tipoCoordenada = TipoCoordenada.values[index];
                return ListTile(
                  title: Text(tipoCoordenada.toString().split('.').last),
                  onTap: () => _editarCoordenada(tipoCoordenada),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                   widget.onAgregarHoyo(nuevoHoyo);
                   Navigator.pop(context);
                }
              },
              child: const Text('Guardar Hoyo'),
            ),
          const Divider(),
            buildCard(),
          ],
        ),
      ),
    );
  }

  Widget buildCard() {
  return Card(
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Detalle del Hoyo", style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Text("Número: ${nuevoHoyo.numero}"),
        Text("Nombre: ${nuevoHoyo.nombre}"),
        Text("Par: ${nuevoHoyo.par}"),
        Text("Handicap: ${nuevoHoyo.handicap ?? 'No especificado'}"),
        Text("Distancia Negras: ${nuevoHoyo.distanciaNegras ?? 'No especificado'}"),
        Text("Distancia Azules: ${nuevoHoyo.distamciaAzules ?? 'No especificado'}"),
        Text("Distancia Blancas: ${nuevoHoyo.distanciaBlancas ?? 'No especificado'}"),
        Text("Distancia Amarillas: ${nuevoHoyo.distanciaAmarillas ?? 'No especificado'}"),
        Text("Distancia Rojas: ${nuevoHoyo.distanciaRojas ?? 'No especificado'}"),
             
        _construirTextoCoordenada("Frente Green", nuevoHoyo.frenteGreen),
        _construirTextoCoordenada("Centro Green", nuevoHoyo.centroGreen),
        _construirTextoCoordenada("Fondo Green", nuevoHoyo.fondoGreen),
        _construirTextoCoordenada("Centro Hoyo", nuevoHoyo.centroHoyo),
        _construirTextoCoordenada("Tee Blancas", nuevoHoyo.teeBlancas),
        _construirTextoCoordenada("Tee Rojas", nuevoHoyo.teeRojas),
        _construirTextoCoordenada("Tee Azules", nuevoHoyo.teeAzules),
        _construirTextoCoordenada("Tee Negras", nuevoHoyo.teeNegras),
        _construirTextoCoordenada("Tee Amarillas", nuevoHoyo.teeAmarillas),
      ],
    ),
  ),
);
}

  Widget _construirTextoCoordenada(String titulo, Cordenada? coordenada) {
    return Text("$titulo: ${coordenada != null ? 'Lat: ${coordenada.latitud}, Long: ${coordenada.longitud}' : 'No especificado'}");
  }
}