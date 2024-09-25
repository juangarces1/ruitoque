import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/Components/input_decoration.dart';
import 'package:ruitoque/constans.dart';

class AddEditTeePage extends StatefulWidget {
  final Tee? tee;
  final Function(Tee) onTeeAdded; // Callback para notificar al widget padre
  final Function(Tee)? onTeeUpdated; // Callback para notificar al widget padre en caso de actualización

  const AddEditTeePage({super.key, this.tee, required this.onTeeAdded, this.onTeeUpdated,});

  @override
  AddEditTeePageState createState() => AddEditTeePageState();
}

class AddEditTeePageState extends State<AddEditTeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si estamos en modo edición, inicializar los valores con el Tee existente
    if (widget.tee != null) {
      _colorController.text = widget.tee!.color; // Cargar el color si estamos editando
    }
  }

  // Guardar o actualizar el Tee
  void _saveTee() {
    if (_formKey.currentState!.validate()) {
      Tee newTee = Tee(
        id: widget.tee?.id ?? 0, // Si estamos editando, usar el ID existente; de lo contrario, nuevo ID
        campoId: widget.tee?.campoId ?? 0, // Usar el campoId existente o 0 si es un nuevo Tee
        color: _colorController.text,
      );

      if (widget.tee == null) {
        widget.onTeeAdded(newTee); // Si no hay un Tee, agregar uno nuevo
      } else {
        widget.onTeeUpdated?.call(newTee); // Si estamos editando, actualizar el Tee
      }

      Navigator.pop(context); // Cerrar pantalla después de guardar
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: MyCustomAppBar(
        title: widget.tee == null ? 'Agregar Tee' : 'Editar Tees',
        automaticallyImplyLeading: true,   
        backgroundColor: kPprimaryColor,
        elevation: 8.0,
        shadowColor: const Color.fromARGB(255, 207, 214, 218),
        foreColor: Colors.white,
        
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: kFondoGradient
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                  controller: _colorController,
                  decoration: buildInputDecoration('Color del Tee'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el color del tee';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
            
               Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: ElevatedButton(
                    onPressed:  _saveTee,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPprimaryColor, // Color de fondo del botón
                      foregroundColor: Colors.white, // Color del texto y iconos del botón
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ), // Estilo del texto
                    ),
                    child: const Text('Guardar Tee'), // Cambiar el texto del botón
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
