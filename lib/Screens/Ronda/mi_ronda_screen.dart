import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/tarjeta_card.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Screens/Ronda/estadistica_hoyo_dialog.dart';
import 'package:ruitoque/Screens/golf_watch_screen.dart';
import 'package:ruitoque/Screens/mi_mapa.dart';
import 'package:ruitoque/constans.dart';


class MiRonda extends StatefulWidget {
  final Ronda ronda;
  
  const MiRonda({super.key, required this.ronda });

  @override
  State<MiRonda> createState() => _MiRondaState();
}

class _MiRondaState extends State<MiRonda> {
  bool showLoader = false;
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kSecondaryColor,
        appBar: MyCustomAppBar(
        title: 'Nueva Ronda',
         automaticallyImplyLeading: true,   
          backgroundColor: Colors.green,
          elevation: 8.0,
          shadowColor: Colors.blueGrey,
          foreColor: Colors.white,
          actions: [ 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(
                    'assets/logoApp.jpg',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ), // Ícono de perfil de usuario
              ),
          ],
        
        ),
        body: CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child:  TarjetaRonda(tarjeta: widget.ronda.tarjetas[0],),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Número de elementos en una fila (horizontalmente)
            mainAxisSpacing: 5.0, // Espaciado vertical entre elementos
            crossAxisSpacing: 5.0, // Espaciado horizontal entre elementos
            childAspectRatio:  (1 / 1.2), // La proporción de la altura y ancho de los elementos
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
               return buildCardEstadistica(widget.ronda.tarjetas[0].hoyos[index]);
            },
            childCount:  widget.ronda.tarjetas[0].hoyos.length,
          ),
        ),
      ],
    ),
        
        ),
        
        
      );
  }
  
 

  goHole(Hoyo hoyo) {
   Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) =>  MiMapa(hoyo: hoyo,)
    )
   );
  }

  goEstadistica(Hoyo hoyo) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) =>  GolfWatchScreen(hoyo: hoyo,)
      )
    );
  }

   gridHoyos() {
     return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),       
       child: GridView.builder(
        shrinkWrap: true,        
        
         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 2, // Dos columnas
           crossAxisSpacing: 5, // Espacio horizontal entre tarjetas
           mainAxisSpacing: 5, // Espacio vertical entre tarjetas
            childAspectRatio: (1 / 1.3),
         ),
         itemCount: widget.ronda.tarjetas[0].hoyos.length,
         itemBuilder: (context, index) {
           return buildCardEstadistica(widget.ronda.tarjetas[0].hoyos[index]);
         },
       ),
     );

  }

  buildCardEstadistica(EstadisticaHoyo estadistica) {
     return Card(
       
      color: estadistica.golpes == 0 ? const Color.fromARGB(255, 46, 46, 46) : kSecondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
                title:  Text('Hoyo: ${estadistica.hoyo.numero.toString()}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                trailing: const Icon(Icons.golf_course, color: Colors.white,),
           ),
         
     
               Padding(
                 padding: const EdgeInsets.only(left: 15),
                 child: Text('Par: ${estadistica.hoyo.par.toString()}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
               ),
              
               
                Padding(
                 padding: const EdgeInsets.only(left: 15),
                  child: Text('Golpes: ${estadistica.golpes.toString()}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                ),
               
               Padding(
                 padding: const EdgeInsets.only(left: 15),
                 child: Text('Putts: ${estadistica.putts.toString()}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
               ),
               const SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // Centra los botones en la fila
                  children: <Widget>[
                   Ink(
                      decoration: const ShapeDecoration(
                        color: kTextColorBlanco, // Puedes cambiar el color de fondo aquí
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.flag,
                          color:kPrimaryColor,
                          size: 30,
                        ),
                        onPressed: () => goHole(estadistica.hoyo),
                      ),
                    ),
                    Ink(
                      decoration: const ShapeDecoration(
                        color: kTextColorBlanco, // Puedes cambiar el color de fondo aquí
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.bar_chart,
                          color: Colors.blueGrey,
                          size: 30,
                        ),
                        onPressed: () => _mostrarDialogoEstadisticaHoyo(estadistica),
                      ),
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.bar_chart , color:Colors.blueGrey, size: 35,),  // Segundo ícono, cambia según tus necesidades
                    //   onPressed: () => _mostrarDialogoEstadisticaHoyo(estadistica),
                    // ),
                  ],
                ),

        
          ],
        ),
      ),
     );


  }

  void _mostrarDialogoEstadisticaHoyo(EstadisticaHoyo estadistica) {
    if(estadistica.golpes == 0 
    && estadistica.putts == 0 
    && estadistica.bunkerShots==0 
    && estadistica.penaltyShots==0
    ){
      estadistica.golpes=estadistica.hoyo.par;
      estadistica.putts=2;
    }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EstadisticaHoyoDialog(
        estadisticaHoyo: estadistica,
        onGuardar: (EstadisticaHoyo estadisticaModificada) {
          setState(() {
              // Encuentra el índice del objeto original y actualízalo
              estadisticaModificada.calcularNetoPorHoyo(estadisticaModificada.hoyo, (widget.ronda.tarjetas[0].jugador.handicap * 0.75));
              int index = widget.ronda.tarjetas[0].hoyos.indexWhere((e) => e.id == estadisticaModificada.id);
              if (index != -1) {
                widget.ronda.tarjetas[0].hoyos[index] = estadisticaModificada;
              }
            });
        },
      );
    },
  );
}



 Future<File> writeJsonToFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/myJsonFile.json');

  Map<String, dynamic> objeto = widget.ronda.toJson();
  String jsonString = jsonEncode(objeto);

  return file.writeAsString(jsonString);
}


 
}