import 'package:flutter/material.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/constans.dart';

class CampoListTileWidget extends StatefulWidget {
  final List<Campo> campos;
  final Function(int) onCampoSelected;

  const CampoListTileWidget({Key? key, required this.campos, required this.onCampoSelected}) 
    : super(key: key);

  @override
  CampoListTileWidgetState createState() => CampoListTileWidgetState();
}

class CampoListTileWidgetState extends State<CampoListTileWidget> {
  int? selectedCampoId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
       decoration: BoxDecoration(
              color: Colors.white, // Color de fondo del contenedor
              borderRadius: BorderRadius.circular(10.0), // Radio de los bordes redondeados
              // Puedes agregar más propiedades de estilo si lo necesitas
            ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: widget.campos.length,
          itemBuilder: (context, index) {
            Campo campo = widget.campos[index];
            return Card(
              child: ListTile(
                 trailing: const Icon(Icons.golf_course, color: Colors.white),
                title: Text(campo.nombre, style: kTextStyleNegroRobotoSize20,),
                onTap: () {
                  setState(() {
                    selectedCampoId = campo.id;
                  });
                  widget.onCampoSelected(campo.id);
                },
                tileColor: selectedCampoId == campo.id ? Colors.blue : Colors.transparent,
              ),
            );
          },
        ),
      ),
    );
  }
}
