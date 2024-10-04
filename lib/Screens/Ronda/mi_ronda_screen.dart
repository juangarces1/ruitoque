import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Components/new_card_tardejta.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/Screens/Mapas/mapa_par3.dart';
import 'package:ruitoque/Screens/Mapas/mi_mapa.dart';
import 'package:ruitoque/Screens/Ronda/estadistica_hoyo_dialog.dart';
import 'package:ruitoque/Screens/Ronda/shot_tile.dart';
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
        appBar: MyCustomAppBar(
        title: widget.ronda.campo.nombre,
          automaticallyImplyLeading: true,   
          backgroundColor: const Color.fromARGB(255, 41, 18, 45),
          elevation: 8.0,
          shadowColor: Colors.blueGrey,
          foreColor: Colors.white,
          actions: [ 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(
                    'assets/LogoGolf.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ), // Ícono de perfil de usuario
              ),
          ],
        
        ),
        body: Stack(
          children: [
            Container(
               decoration: const BoxDecoration(
                gradient: kFondoGradient
              ),
              child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child:  NewTarjetaCard(tarjeta: widget.ronda.tarjetas[0], onSave:  _confirmSave, onBack:  _confirmBack),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260, // Ajusta esta altura según tus necesidades
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.ronda.tarjetas[0].hoyos.length,
                          itemBuilder: (BuildContext context, int index) {
                            return buildCardEstadistica(widget.ronda.tarjetas[0].hoyos[index]);
                          },
                        ),
                      ),
                    ),
             
              
                    //  SliverToBoxAdapter(
                    //   child:   Center(
                    //     child: buildGetBack(context),
                    //   )
                    // ),
                  
                  ],
                ),
            ),
            showLoader ? const MyLoader(opacity: 0.8, text: 'Guardando...',): const SizedBox(),
          ],
        ),
        
        ),
   );
  }

  Future<bool> mostrarDialogoSalida(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Estás seguro de que quieres salir?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }
   

  goHole(EstadisticaHoyo hoyo) {

   hoyo.hoyo.par == 3 ?
   Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) =>  MiMapaPar3(hoyo: hoyo, onAgregarShot: agregarShotAEstadisticaHoyo, onDeleteShot: deleteShot, teeSalida: widget.ronda.tarjetas[0].teeSalida ?? '',)
    )
   )  :

   Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) =>  MiMapa(hoyo: hoyo, onAgregarShot: agregarShotAEstadisticaHoyo, onDeleteShot: deleteShot, teeSalida: widget.ronda.tarjetas[0].teeSalida ?? '',)
    )
   );
  }

   void agregarShotAEstadisticaHoyo(int idEstadisticaHoyo, Shot nuevoShot) {
    setState(() {
      var estadisticaHoyo = widget.ronda.tarjetas[0].hoyos.firstWhere(
        (est) => est.id == idEstadisticaHoyo,        
      );       
        estadisticaHoyo.shots!.add(nuevoShot);     
    });
  }

   void deleteShot(int idEstadisticaHoyo, Shot shot) {
    setState(() {
      var estadisticaHoyo = widget.ronda.tarjetas[0].hoyos.firstWhere(
        (est) => est.id == idEstadisticaHoyo,        
      );       
        estadisticaHoyo.shots!.remove(shot);     
    });
  }

 
 

Widget buildCardEstadistica(EstadisticaHoyo estadistica) {
  return SizedBox(
    width: 200,   

    child: Card(
      color: estadistica.golpes == 0
          ? const Color.fromARGB(255, 46, 46, 46)
          : kPsecondaryColor,
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
              title: Text(
                'Hoyo: ${estadistica.hoyo.numero.toString()}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.golf_course, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: SizedBox(
                child: Text(
                  'Par: ${estadistica.hoyo.par.toString()}  --  Golpes: ${estadistica.golpes.toString()}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
           
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: SizedBox(
                child: Text(
                  'Putts: ${estadistica.putts.toString()}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 3),
            estadistica.shots != null && estadistica.shots!.isNotEmpty
                ? SizedBox(
                 
                    height: 55, // Altura ajustada para contener los ShotTile
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: estadistica.shots!.asMap().entries.map((entry) {
                          int index = entry.key;
                          Shot shot = entry.value;
                          return ShotTile(
                            index: index,
                            shot: shot,
                            onDelete: () {
                              // Mostrar diálogo de confirmación antes de eliminar
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar Eliminación'),
                                    content: const Text(
                                        '¿Eliminar este golpe?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Cerrar el diálogo
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Eliminar',
                                            style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          // Llamar a la función para eliminar el golpe
                                          deleteShot(estadistica.id, shot);
                                          Navigator.of(context).pop(); // Cerrar el diálogo
                                          // Opcional: Mostrar un SnackBar de confirmación
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text('Golpe eliminado.')),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  decoration: const ShapeDecoration(
                    color: kTextColorBlanco,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.flag,
                      color: kPprimaryColor,
                      size: 30,
                    ),
                    onPressed: () => goHole(estadistica),
                  ),
                ),
                Container(
                  decoration: const ShapeDecoration(
                    color: kTextColorBlanco,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.bar_chart,
                      color: kPsecondaryColor,
                      size: 30,
                    ),
                    onPressed: () => _mostrarDialogoEstadisticaHoyo(estadistica),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              estadisticaModificada.calcularNetoPorHoyo(estadisticaModificada.hoyo, (widget.ronda.tarjetas[0].jugador!.handicap! * 0.75));
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

 
 Future<void> _confirmSave() async {
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Estás seguro de que deseas guardar esta ronda?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna false
            },
          ),
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop(true); // Retorna true
            },
          ),
        ],
      );
    },
  );

  // Si el usuario aceptó, procede con la función _goSave
  if (confirm == true) {
    await _goSave();
  }
}

 
  Future<void> _goSave() async {
    
    setState(() {
     showLoader = true;
   });

   for (var hoyo in widget.ronda.tarjetas[0].hoyos) {
     hoyo.id=0;
  }
  Map<String, dynamic> ronda = widget.ronda.toJson();
  
   
   Response response = await ApiHelper.post('api/Rondas/', ronda);
 
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

      await Future.delayed(const Duration(seconds: 2));

      Fluttertoast.showToast(
        msg: "La Ronda ha sido guardada exotosamente.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor:kPcontrastMoradoColor,
        textColor: Colors.white,
        fontSize: 16.0
    );

     goHome();

  }

   goHome() {
       Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ),                   
      );
    } 

 

   Future<void> _confirmBack() async {
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Estás seguro de que deseas Salir de la ronda?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna false
            },
          ),
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop(true); // Retorna true
            },
          ),
        ],
      );
    },
  );

  // Si el usuario aceptó, procede con la función _goSave
  if (confirm == true) {
    await goHome();
  }
}

}