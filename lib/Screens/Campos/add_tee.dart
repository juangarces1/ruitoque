import 'package:flutter/material.dart';
import 'package:ruitoque/Models/tee.dart';

class AddEditTeePage extends StatefulWidget {
  final Tee? tee;
  final Function(Tee) onTeeAdded; // Callback para notificar al widget padre

  const AddEditTeePage({super.key, this.tee, required this.onTeeAdded});

  @override
  AddEditTeePageState createState() => AddEditTeePageState();
}

class AddEditTeePageState extends State<AddEditTeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tee != null) {
      _colorController.text = widget.tee!.color; // Cargar el color si estamos editando
    }
  }

  void _saveTee() {
    if (_formKey.currentState!.validate()) {
      Tee newTee = Tee(
        id: widget.tee?.id ?? 0, // Asumir nuevo ID o usar el existente
        campoId: widget.tee?.campoId ?? 0, // Asumir campoId por defecto o usar el existente
        color: _colorController.text,
      );

      widget.onTeeAdded(newTee); // Llamar al callback con el nuevo Tee
      Navigator.pop(context); // Opcional, cerrar esta pantalla después de guardar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tee == null ? 'Agregar Tee' : 'Editar Tee'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color del Tee'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el color del tee';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _saveTee,
              child: const Text('Guardar Tee'),
            ),
          ],
        ),
      ),
    );
  }
}
