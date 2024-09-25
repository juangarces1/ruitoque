import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/constans.dart';

class CardJugador extends StatefulWidget {
  final Jugador jugador;
  const CardJugador({super.key, required this.jugador});

  @override
  State<CardJugador> createState() => _CardJugadorState();
}

class _CardJugadorState extends State<CardJugador> {
  bool  showLoader = false;
  @override
  Widget build(BuildContext context) {
   
    return Stack(
      children: [
        Card(
          color: const Color(0xC3F2EFEF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
             
              children: <Widget>[
                 Text('Hola!! ${widget.jugador.nombre}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('Handicap', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    widget.jugador.handicap.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  trailing:  IconButton(
                        icon: const Icon(Icons.edit, color: kPverdeBienOscuto, ),
                        onPressed: () => mostrarEditarDialog(context),
                        tooltip: 'Editar Caja Chica',
                      ),
                ),
                // Aquí puedes agregar más ListTile si tienes más información para mostrar
              ],
            ),
          ),
        ),
        showLoader ? const MyLoader(opacity: 1, text: 'Actualizando...',) : Container(),
      ],
    );
  }

  Future<void> mostrarEditarDialog(BuildContext context,) async {
  TextEditingController controller = TextEditingController(text: widget.jugador.handicap.toString());

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Editar Handicap'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true), // Teclado numérico con opción decimal
          // Puedes añadir más configuraciones aquí
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Cierra el diálogo sin guardar cambios
            },
          ),
          TextButton(
            child: const Text('Guardar'),
            onPressed: () {
              // Intenta convertir el texto a double y actualizar cajaChica
              int? valorActualizado = int.tryParse(controller.text);
              if (valorActualizado != null) {
               goUpdate(valorActualizado);              
              }
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}

  Future<void> goUpdate(int valorActualizado) async {
     setState(() {
      showLoader = true;
    });
    
    Response response = await ApiHelper.updateHandicap(widget.jugador.id, valorActualizado);   
   
    setState(() {
      showLoader = false;
    });

     if (!response.isSuccess) {
        if (mounted) {         
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
        }        
        return;
     }   
   
     Fluttertoast.showToast(
        msg: "Handicap Actualizado exotosamente.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor:kPcontrastMoradoColor,
        textColor: Colors.white,
        fontSize: 16.0
    );
    setState(() {
      widget.jugador.handicap=valorActualizado;
    });
  }
}
