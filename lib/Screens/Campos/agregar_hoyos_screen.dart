import 'package:flutter/material.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Models/tipos_cordenada.dart';
import 'package:ruitoque/Screens/Campos/Components/hoyo_tee_list.dart';
import 'package:ruitoque/Screens/Campos/add_hoyo_tee.dart';
import 'package:ruitoque/Screens/Campos/editar_coordenada_screen.dart';

class AgregarHoyosScreen extends StatefulWidget {
  final List<Tee> tees;
  final Function(Hoyo) onAgregarHoyo;
  const AgregarHoyosScreen({super.key, required this.onAgregarHoyo, required this.tees});

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
      hoyotees: [],
     
      fondoGreen: Cordenada(id: 0, latitud: 0,longitud: 0),
      frenteGreen: Cordenada(id: 0, latitud: 0,longitud: 0),
      centroGreen: Cordenada(id: 0, latitud: 0,longitud: 0),
      centroHoyo: Cordenada(id: 0, latitud: 0,longitud: 0),
   
        // Inicializa los valores requeridos aquí
      );

  List<TipoCoordenada> tiposCoordenadas = TipoCoordenada.values;
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nombreController = TextEditingController();
  final _parController = TextEditingController();
  final _handicapController = TextEditingController();

  
  Cordenada ubicacion= Cordenada(id: 0, latitud: 7.027436, longitud: -73.083597);


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
    
    default:     
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
              default:     
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
               onPressed: () => _navegarYAgregarHoyoTee(context),
                  child: const Text('Agregar Tee'),
             ),
          
          const Divider(),
           Text('Tees', style: Theme.of(context).textTheme.titleLarge),
           SizedBox(
                  height: 130,
                 child: HoyoTeesListWidget(
                    hoyoTees: nuevoHoyo.hoyotees!,
                    onDelete: (HoyoTee hoyoTee) {
                        setState(() {
                            nuevoHoyo.hoyotees!.removeWhere((hoyoTee) => hoyoTee.color == hoyoTee.color);
                        });

                      // Aquí implementarías la lógica para borrar el HoyoTee del backend o del estado de la app
                   
                    },
                  ),
                ),
          const Divider(),
            buildCard(),
             const Divider(),
              ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                   widget.onAgregarHoyo(nuevoHoyo);
                   Navigator.pop(context);
                }
              },
              child: const Text('Guardar Hoyo'),
            ),
          ],
        ),
      ),
    );
  }
  void _navegarYAgregarHoyoTee(BuildContext context) async {
   await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddHoyoTeesPage(
        cordenada: ubicacion,
        onAddHoyoTee: (tee) {
          setState(() {
            nuevoHoyo.hoyotees!.add(tee);
          });
        },
        availableTees:getAvailableTeesByColor( widget.tees, nuevoHoyo.hoyotees!)
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
   
             
        _construirTextoCoordenada("Frente Green", nuevoHoyo.frenteGreen),
        _construirTextoCoordenada("Centro Green", nuevoHoyo.centroGreen),
        _construirTextoCoordenada("Fondo Green", nuevoHoyo.fondoGreen),
        _construirTextoCoordenada("Centro Hoyo", nuevoHoyo.centroHoyo),
  
      ],
    ),
  ),
);
}

  Widget _construirTextoCoordenada(String titulo, Cordenada? coordenada) {
    return Text("$titulo: ${coordenada != null ? 'Lat: ${coordenada.latitud}, Long: ${coordenada.longitud}' : 'No especificado'}");
  }

  List<Tee> getAvailableTeesByColor(List<Tee> campoTees, List<HoyoTee> hoyoTees) {
  // Crear un conjunto de colores de Tees que están siendo usados
  Set<String> usedTeeColors = hoyoTees.map((hoyoTee) => hoyoTee.color).toSet();

  // Filtrar los tees del campo para excluir los que están en usedTeeColors
  List<Tee> availableTees = campoTees.where((tee) => !usedTeeColors.contains(tee.color)).toList();

  return availableTees;
}

}