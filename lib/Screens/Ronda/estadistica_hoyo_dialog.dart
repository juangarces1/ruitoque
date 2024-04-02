import 'package:flutter/material.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/constans.dart';

class EstadisticaHoyoDialog extends StatefulWidget {
  final EstadisticaHoyo estadisticaHoyo;

  final Function(EstadisticaHoyo) onGuardar;

  const EstadisticaHoyoDialog({
    Key? key,
    required this.estadisticaHoyo,
    required this.onGuardar,
   
  }) : super(key: key);

  @override
  State<EstadisticaHoyoDialog> createState() => _EstadisticaHoyoDialogState();
}

class _EstadisticaHoyoDialogState extends State<EstadisticaHoyoDialog> {
   late EstadisticaHoyo estadisticaHoyo;
    TextStyle txtHeader = const TextStyle(color: Color.fromARGB(255, 1, 61, 22), fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    estadisticaHoyo = widget.estadisticaHoyo;
  }

  void _cambiarEstadoFairway(String direccion) {
    setState(() {
      estadisticaHoyo.acertoFairway = direccion == 'centro';
      estadisticaHoyo.falloFairwayIzquierda = direccion == 'izquierda';
      estadisticaHoyo.falloFairwayDerecha = direccion == 'derecha';
    });
  }


  void _incrementarCampo(String campo) {
    setState(() {
      if (campo == 'golpes') {
        widget.estadisticaHoyo.golpes++;
      } else if (campo == 'putts'){
          widget.estadisticaHoyo.putts++;
      } 
      else if (campo == 'bunkerShots'){
        widget.estadisticaHoyo.bunkerShots++;
      }  else if (campo == 'penaltyShots'){
        widget.estadisticaHoyo.penaltyShots++;
      } 
    });
  }

  void _decrementarCampo(String campo) {
    setState(() {
      if (campo == 'golpes' && widget.estadisticaHoyo.golpes > 0) {
        widget.estadisticaHoyo.golpes--;

      } else if (campo == 'putts' && widget.estadisticaHoyo.putts > 0) 
       {
        widget.estadisticaHoyo.putts--;
       }
      else if (campo == 'bunkerShots' && widget.estadisticaHoyo.bunkerShots > 0) {
        widget.estadisticaHoyo.bunkerShots--;

      } else if (campo == 'penaltyShots' && widget.estadisticaHoyo.penaltyShots > 0) {
        widget.estadisticaHoyo.bunkerShots--;

      }
    });
  }

  @override
  Widget build(BuildContext context) {
   

    return AlertDialog(
      
      title:   Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: ListTile(
                title:  Text('Hoyo ${widget.estadisticaHoyo.hoyo.numero.toString()}', style: txtHeader ),
                subtitle: Text(
              'Par ${widget.estadisticaHoyo.hoyo.par.toString()}',  style: txtHeader, ),
                trailing: const Icon(Icons.flag_circle, color:  Colors.green, size: 36,),
               
                           ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
             const Center(child: Text('Fairway:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),)),
               const SizedBox(height: 4,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _botonFairway('Izquierda', widget.estadisticaHoyo.falloFairwayIzquierda),
                _botonFairway('Centro', widget.estadisticaHoyo.acertoFairway),
                _botonFairway('Derecha', widget.estadisticaHoyo.falloFairwayDerecha),
              ],
            ),
              const SizedBox(height: 15,),
            _contador('Golpes', widget.estadisticaHoyo.golpes, 'golpes'),
            const SizedBox(height: 10,),
            _contador('Putts', widget.estadisticaHoyo.putts, 'putts'),
             const SizedBox(height: 10,),
            _contador('Bunker', widget.estadisticaHoyo.bunkerShots, 'bunkerShots'),
             const SizedBox(height: 10,),
            _contador('Castigo', widget.estadisticaHoyo.penaltyShots, 'penaltyShots'),
             const SizedBox(height: 10,),
        
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Color del texto
            elevation: 5, // Sombra del botón
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
          ),
          onPressed: () {
            widget.onGuardar(widget.estadisticaHoyo);
            Navigator.of(context).pop();
          },
          child: const Text(
            'Guardar',
            style: TextStyle(
              fontSize: 16, // Tamaño del texto
              fontWeight: FontWeight.bold, // Grosor del texto
            ),
          ),
        )
      ],
    );
  }

   Widget _botonFairway(String texto, bool estado) {
  IconData iconData;
  Color botonColor;
  double elevation;
  String tooltip;

  switch (texto.toLowerCase()) {
    case 'izquierda':
      iconData = Icons.arrow_back;
      botonColor = Colors.black;
      tooltip = 'Mover a la izquierda';
      break;
    case 'centro':
      iconData = Icons.circle;
      botonColor = Colors.black;
      tooltip = 'Centrar';
      break;
    case 'derecha':
      iconData = Icons.arrow_forward;
      botonColor = Colors.black;
      tooltip = 'Mover a la derecha';
      break;
    default:
      iconData = Icons.circle;
      botonColor = const Color.fromARGB(255, 242, 240, 240);
      tooltip = 'Opción no reconocida';
  }

  elevation = estado ? 10 : 2;

  return Tooltip(
    message: tooltip,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: estado ? Colors.green : Colors.grey,
        elevation: elevation,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
      ),
      onPressed: () => _cambiarEstadoFairway(texto.toLowerCase()),
      child: Icon(iconData, color: botonColor),
    ),
  );
}



 Widget _contador(String titulo, int valor, String campo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 35,
            width: 35,
            decoration:  const BoxDecoration(
              shape: BoxShape.circle,
              color: kSecondaryColor,
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.remove, color: kTextColorBlanco, size: 20,),
                onPressed: () => _decrementarCampo(campo),
              ),
            ),
          ),
          Text(
            '$valor',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Container(
            height: 35,
            width: 35,
            decoration:  const BoxDecoration(
              shape: BoxShape.circle,
              color: kSecondaryColor,
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.add, color: kTextColorBlanco, size: 20,),
                onPressed: () => _incrementarCampo(campo),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
