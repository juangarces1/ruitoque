import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Components/tarjeta_card.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Ronda/estadistica_hoyo_dialog.dart';
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
        backgroundColor: Colors.black,
        appBar: MyCustomAppBar(
        title: 'Nueva Ronda',
          automaticallyImplyLeading: true,   
          backgroundColor: kPrimaryColor,
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
        body: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child:  TarjetaRonda(tarjeta: widget.ronda.tarjetas[0],),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280, // Ajusta esta altura según tus necesidades
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.ronda.tarjetas[0].hoyos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildCardEstadistica(widget.ronda.tarjetas[0].hoyos[index]);
                    },
                  ),
                ),
              ),
               SliverToBoxAdapter(
                child:   Stack(
                  children: [
                    Center(
                      child: DefaultButton(
                          text: const Text('Guardar Ronda', style: kTextStyleBlancoNuevaFuente20, textAlign: TextAlign.center ,),
                          press: () => _goSave(),
                          gradient: kSecondaryGradient,
                          color: kPrimaryColor,
                          
                          ),
                    ),
                        showLoader ? const Center(child: CircularProgressIndicator()) : Container(),
                  ],
                )
              ),
            
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
   Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) =>  MiMapa(hoyo: hoyo, onAgregarShot: agregarShotAEstadisticaHoyo, teeSalida: widget.ronda.tarjetas[0].teeSalida ?? '',)
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

 

   gridHoyos() {
     return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),       
       child: GridView.builder(
        shrinkWrap: true,        
        
         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 2, // Dos columnas
           crossAxisSpacing: 5, // Espacio horizontal entre tarjetas
           mainAxisSpacing: 5, // Espacio vertical entre tarjetas
           childAspectRatio: 0.75,
         ),
         itemCount: widget.ronda.tarjetas[0].hoyos.length,
         itemBuilder: (context, index) {
           return buildCardEstadistica(widget.ronda.tarjetas[0].hoyos[index]);
         },
       ),
     );

  }

Widget buildCardEstadistica(EstadisticaHoyo estadistica) {
  return SizedBox(
    width: 200,   

    child: Card(
      color: estadistica.golpes == 0
          ? const Color.fromARGB(255, 46, 46, 46)
          : kSecondaryColor,
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
            const SizedBox(height: 5),
        estadistica.shots != null || estadistica.shots!.isNotEmpty ?  SizedBox(
              height: 60, // Ajusta la altura según tus necesidades
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: estadistica.shots?.map((shot) {
                    int index = estadistica.shots!.indexOf(shot);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Text(
                            'Shot ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${shot.distancia.toString()}y',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList() ?? [],
                ),
              ),
            ) : Container(),
            const SizedBox(height: 5),
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
                      color: kPrimaryColor,
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
                      color: kSecondaryColor,
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

  Future<void> _goSave() async {
    
    setState(() {
     showLoader = true;
   });

   for (var hoyo in widget.ronda.tarjetas[0].hoyos) {
     hoyo.id=0;
  }
  Map<String, dynamic> ronda = widget.ronda.toJson();
  
   int x=1;
   Response response = await ApiHelper.post('api/Rondas/', widget.ronda.toJson());
 
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