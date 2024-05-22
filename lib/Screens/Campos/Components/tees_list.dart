import 'package:flutter/material.dart';
import 'package:ruitoque/Models/tee.dart';

class TeesListWidget extends StatelessWidget {
  final List<Tee> tees;

  const TeesListWidget({Key? key, required this.tees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tees.length,
      itemBuilder: (context, index) {
        final tee = tees[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Color: ${tee.color}'),          
            trailing: const Icon(Icons.edit), // Icono para editar, puede ser un botón si se necesita funcionalidad
          ),
        );
      },
    );
  }
}
