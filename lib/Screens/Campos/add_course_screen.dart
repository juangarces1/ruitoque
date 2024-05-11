import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Campo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Screens/Campos/agregar_hoyos_screen.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key, });
  @override
  AddCourseScreenState createState() => AddCourseScreenState();
}

class AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final List<Hoyo> _hoyos = [];
  bool showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Campo"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                   if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el ID';
                      }
                      return null;
                },
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                   if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del campo';
                  }
                  return null;
                
                },
              ),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
                validator: (value) {
                  // if (value.isEmpty) {
                  //   return 'Esta ubicación no se va a llenar sola';
                  // }
                  // return null;
                    if (value == null || value.isEmpty) {
                    return 'Esta ubicación no se va a llenar sola';
                  }
                  return null;
          
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de agregar hoyos
                  _navegarYAgregarHoyos(context);
                },
                child: const Text('Agregar Hoyos'),
              ),
            
              const Divider(thickness: 3,),
              buildCard(),
               const Divider(thickness: 3,),
                ElevatedButton(
                onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Aquí guardas tu campo o haces lo que necesites con la información
                      var nuevoCampo = Campo(
                        id: int.parse(_idController.text),
                        nombre: _nombreController.text,
                        ubicacion: _ubicacionController.text,
                        hoyos: _hoyos,
                      );
          
                     writeJsonToFile(nuevoCampo);
                    }
                  },
                child: const Text('Guardar Campo Json'),
              ),
             
               ElevatedButton(
                onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Aquí guardas tu campo o haces lo que necesites con la información
                     
          
                     _goSave();
                    }
                  },
                child: const Text('Guardar Campo BD'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

   Future<File> writeJsonToFile(Campo nuevoCampo) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${nuevoCampo.nombre}.json');

    Map<String, dynamic> objeto = nuevoCampo.toJson();
    String jsonString = jsonEncode(objeto);

    return file.writeAsString(jsonString);
}

  

  void _navegarYAgregarHoyos(BuildContext context) async {
   await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AgregarHoyosScreen(
        onAgregarHoyo: (nuevoHoyo) {
          setState(() {
            _hoyos.add(nuevoHoyo);
          });
        },
      ),
    ),
  );
}


Future<void> _goSave() async {
    
    setState(() {
     showLoader = true;
   });
 var nuevoCampo = Campo(
                        id: int.parse(_idController.text),
                        nombre: _nombreController.text,
                        ubicacion: _ubicacionController.text,
                        hoyos: _hoyos,
                      );

   Response response = await ApiHelper.post('api/Campos/', nuevoCampo.toJson());
 
    setState(() {
      showLoader = false;
    });

     if (!response.isSuccess) {
      if(mounted) {
          showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content:  Text(response.message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
       }
     }
      if(mounted) {
          showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Todo Good'),
              content:  Text(response.message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
  
  }
  

  Widget buildCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Campo: ${_nombreController.text}", style: Theme.of(context).textTheme.titleLarge),
            Text("ID: ${_idController.text}"),
            Text("Ubicación: ${_ubicacionController.text}"),
            const Divider(),
            Text(_hoyos.length.toString(), style: Theme.of(context).textTheme.titleMedium),
            
          ],
        ),
      ),
    );
  }

}



