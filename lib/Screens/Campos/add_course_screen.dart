import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Campo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/Components/hoyo_list.dart';
import 'package:ruitoque/Screens/Campos/Components/tees_list.dart';
import 'package:ruitoque/Screens/Campos/add_tee.dart';
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
   final List<Tee> _tees = [];
  bool showLoader = false;

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Campo"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'ID'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Por favor ingresa el ID' : null,
                ),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty ? 'Por favor ingresa el nombre del campo' : null,
                ),
                TextFormField(
                  controller: _ubicacionController,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                  validator: (value) => value == null || value.isEmpty ? 'Esta ubicación no se va a llenar sola' : null,
                ),
                   ElevatedButton(
                  onPressed: () => _navegarAddTee(context),
                  child: const Text('Agregar Tee'),
                ),
                SizedBox(
                  height: 100,
                  child: TeesListWidget(tees: _tees),
                ),
                ElevatedButton(
                  onPressed: () => _navegarYAgregarHoyos(context),
                  child: const Text('Agregar Hoyo'),
                ),
                SizedBox(
                  height: 200,
                  child: HoyosListWidget(
                     onDelete: (Hoyo hoyo) {
                        setState(() {
                            _hoyos.removeWhere((mihoyo) => mihoyo.nombre == hoyo.nombre);
                        });

                      // Aquí implementarías la lógica para borrar el HoyoTee del backend o del estado de la app
                   
                    },
                    hoyos: _hoyos
                  ),
                ),
             
                ElevatedButton(
                  onPressed: _goSave,
                  child: const Text('Guardar Campo'),
                ),
              ],
            ),
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
        tees: _tees,
        onAgregarHoyo: (nuevoHoyo) {
          setState(() {
            _hoyos.add(nuevoHoyo);
          });
        },
      ),
    ),
  );
}
  

  void _navegarAddTee(BuildContext context) async {
   await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddEditTeePage(
        onTeeAdded: (newTee) {
          setState(() {
           _tees.add(newTee);
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
                        tees: _tees,
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
  



}



