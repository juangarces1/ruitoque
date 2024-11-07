import 'package:flutter/material.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/constans.dart';

class EstadisticaHoyoDialog extends StatefulWidget {
  final List<EstadisticaHoyo> estadisticasHoyo;
  final Function(List<EstadisticaHoyo>) onGuardar;

  const EstadisticaHoyoDialog({
    Key? key,
    required this.estadisticasHoyo,
    required this.onGuardar,
  }) : super(key: key);

  @override
  State<EstadisticaHoyoDialog> createState() => _EstadisticaHoyoDialogState();
}

class _EstadisticaHoyoDialogState extends State<EstadisticaHoyoDialog> {
  late List<EstadisticaHoyo> estadisticasHoyo;
  TextStyle txtHeader = const TextStyle(color: Color.fromARGB(255, 1, 61, 22), fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    estadisticasHoyo = List.from(widget.estadisticasHoyo);
  }

  void _incrementarCampo(EstadisticaHoyo estadistica, String campo) {
    setState(() {
      if (campo == 'golpes') {
        estadistica.golpes++;
      } else if (campo == 'putts') {
        estadistica.putts++;
      } else if (campo == 'bunkerShots') {
        estadistica.bunkerShots++;
      } else if (campo == 'penaltyShots') {
        estadistica.penaltyShots++;
      }
    });
  }

  void _decrementarCampo(EstadisticaHoyo estadistica, String campo) {
    setState(() {
      if (campo == 'golpes' && estadistica.golpes > 0) {
        estadistica.golpes--;
      } else if (campo == 'putts' && estadistica.putts > 0) {
        estadistica.putts--;
      } else if (campo == 'bunkerShots' && estadistica.bunkerShots > 0) {
        estadistica.bunkerShots--;
      } else if (campo == 'penaltyShots' && estadistica.penaltyShots > 0) {
        estadistica.penaltyShots--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title:   Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: ListTile(
                title:  Text('Hoyo ${widget.estadisticasHoyo[0].hoyo.numero.toString()}', style: txtHeader ),
                subtitle: Text(
              'Par ${widget.estadisticasHoyo[0].hoyo.par.toString()}',  style: txtHeader, ),
                trailing: const Icon(Icons.flag_circle, color:  Colors.green, size: 36,),
               
                           ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: estadisticasHoyo.map((estadistica) {
             estadistica.golpes == 0 ? estadistica.golpes = estadistica.hoyo.par : estadistica.golpes;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Center(
                   child: Text(
                   ' ${estadistica.nombreJugador}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                   ),
                 ),
               const SizedBox(height: 5,),
               estadistica.isMain! ?  const Center(child: Text('Fairway:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),)) : const SizedBox(),
                 estadistica.isMain! ?  const SizedBox(height: 4,) : const SizedBox(),
                estadistica.isMain! ?    Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _botonFairway('Izquierda', estadistica.falloFairwayIzquierda,estadistica),
                    _botonFairway('Centro', estadistica.acertoFairway,estadistica),
                    _botonFairway('Derecha', estadistica.falloFairwayDerecha,estadistica),
                  ],
                ): const SizedBox(),
                  const SizedBox(height: 15), 
                _contador('Golpes', estadistica.golpes, 'golpes', estadistica),
                  estadistica.isMain! ?  const SizedBox(height: 10,) : const SizedBox(),
                  estadistica.isMain! ?  _contador('Putts', estadistica.putts, 'putts', estadistica): const SizedBox(),
                  estadistica.isMain! ?  const SizedBox(height: 10,): const SizedBox(),
                  estadistica.isMain! ?  _contador('Bunker', estadistica.bunkerShots, 'bunkerShots', estadistica): const SizedBox(),
                  estadistica.isMain! ?  const SizedBox(height: 10,): const SizedBox(),
                  estadistica.isMain! ?  _contador('Castigo', estadistica.penaltyShots, 'penaltyShots', estadistica): const SizedBox(),
                  estadistica.isMain! ?  const SizedBox(height: 10,): const SizedBox(),
                  ],
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            widget.onGuardar(estadisticasHoyo);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  // Widget _contador(String titulo, int valor, String campo, EstadisticaHoyo estadistica) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         titulo,
  //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       Row(
  //         children: [
  //           IconButton(
  //             icon: const Icon(Icons.remove, color: Colors.red),
  //             onPressed: () => _decrementarCampo(estadistica, campo),
  //           ),
  //           Text(
  //             '$valor',
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.add, color: Colors.green),
  //             onPressed: () => _incrementarCampo(estadistica, campo),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  
 Widget _contador(String titulo, int valor, String campo, EstadisticaHoyo estadistica) {
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
              color: kPprimaryColor,
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.remove, color: kTextColorBlanco, size: 20,),
                onPressed: () => _decrementarCampo(estadistica, campo),
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
              color: kPsecondaryColor,
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.add, color: kTextColorBlanco, size: 20,),
                onPressed: () => _incrementarCampo(estadistica,campo),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonFairway(String texto, bool estado, EstadisticaHoyo estadistica) {
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
      onPressed: () => _cambiarEstadoFairway(texto.toLowerCase(), estadistica),
      child: Icon(iconData, color: botonColor),
    ),
  );
}

  void _cambiarEstadoFairway(String direccion, EstadisticaHoyo estadisticaHoyo) {
    setState(() {
      estadisticaHoyo.acertoFairway = direccion == 'centro';
      estadisticaHoyo.falloFairwayIzquierda = direccion == 'izquierda';
      estadisticaHoyo.falloFairwayDerecha = direccion == 'derecha';
    });
  }


  
}
