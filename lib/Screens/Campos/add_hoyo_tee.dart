import 'package:flutter/material.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/editar_coordenada_screen.dart';

class AddHoyoTeesPage extends StatefulWidget {
  final List<Tee> availableTees;
  final Cordenada cordenada;
  final Function(HoyoTee) onAddHoyoTee;
 

  const AddHoyoTeesPage({
    Key? key,
    required this.availableTees,
    required this.onAddHoyoTee,
    required this.cordenada
  
  }) : super(key: key);

  @override
  AddHoyoTeesPageState createState() => AddHoyoTeesPageState();
}

class AddHoyoTeesPageState extends State<AddHoyoTeesPage> {
  Tee? selectedTee;

  Cordenada cordenadaActual = Cordenada(id: 0, latitud: 0, longitud: 0);

  TextEditingController distanciaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar HoyoTees"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: DropdownButton<Tee>(
                hint: const Text("Seleccione un Tee"),
                value: selectedTee,
                onChanged: (Tee? newValue) {
                  setState(() {
                    selectedTee = newValue;
                  });
                },
                items: widget.availableTees.map((Tee tee) {
                  return DropdownMenuItem<Tee>(
                    value: tee,
                    child: Text(tee.color),
                  );
                }).toList(),
              ),
            ),
              ElevatedButton(
               onPressed: () => _editarCoordenada(),
                  child: const Text('Agregar Cordenada'),
             ),
          
          
              const SizedBox(height: 20,),
              if (selectedTee != null) _buildTeeEntry(),
                ElevatedButton(
              onPressed: () => _addHoyoTee(),
              child: const Text('Agregar HoyoTee'),
            ),
          ],
        ),
      ),
    );
  }

  
  void _editarCoordenada() async {
  
  

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditarCoordenadaScreen(
        coordenadaInicial: widget.cordenada,
        ubicacion: widget.cordenada,
        onCoordenadaActualizada: (nuevaCoordenada) {
          // Esta es la lógica para actualizar la coordenada en el Hoyo
          setState(() {
            cordenadaActual=nuevaCoordenada;
          
          });
        },
      ),
    ),
    
  );
  }

  Widget _buildTeeEntry() {
    return Center(
      child: Column(
        children: <Widget>[
          Text("Tee Color: ${selectedTee!.color}"),
          Text("Corenada Latitud: ${cordenadaActual.latitud}"),
           Text("Corenada Longitud: ${cordenadaActual.longitud}"),
          Padding(
            padding: const EdgeInsets.only(left: 100, right: 100, top: 5),
            child: TextFormField(
              controller: distanciaController,
              decoration: const InputDecoration(labelText: 'Distancia'),
              keyboardType: TextInputType.number,
            ),
          ),
         
        
        ],
      ),
    );
  }

  

  void _addHoyoTee() {
    if (selectedTee != null && distanciaController.text.isNotEmpty) {
      HoyoTee hoyoTee = HoyoTee(
        id: 0,
        hoyoId: 0, // ID del Hoyo se asignará cuando se guarde el Hoyo
        
        cordenada: cordenadaActual,
        color: selectedTee!.color, 
        distancia: int.parse(distanciaController.text),
      );
      widget.onAddHoyoTee(hoyoTee);
      // Limpiar datos para permitir nuevas entradas
      Navigator.pop(context);
    }
  }
}
