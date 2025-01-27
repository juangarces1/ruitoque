import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/custom_header.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Components/new_card_tardejta.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/Screens/Mapas/mapa_par3.dart';
import 'package:ruitoque/Screens/Mapas/mi_mapa.dart';
import 'package:ruitoque/Screens/Ronda/estadistica_hoyo_dialog.dart';
import 'package:ruitoque/Screens/Ronda/shot_tile.dart';
import 'package:ruitoque/constans.dart';



class MiRonda extends StatefulWidget {
  final Ronda ronda;
 
  const MiRonda({super.key, required this.ronda, });

  @override
  State<MiRonda> createState() => _MiRondaState();
}

class _MiRondaState extends State<MiRonda> {
  bool showLoader = false;
  late Ronda _ronda;
  late Jugador jugador;
  late Tarjeta myTarjeta;
  bool isCreator = false;  
  get jugadoresSeleccionados => null;

  @override


  void initState() {
    super.initState();
      _ronda=widget.ronda;
    _ronda.id ==0 ? _goSave() : _goRefresh();
     jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;   
     isCreator = jugador.id == _ronda.creatorId ? true: false;
     myTarjeta =  _ronda.tarjetas.firstWhere((t) => t.jugadorId == jugador.id);    
      setState(() {
      _ronda.calcularYAsignarPosiciones();
     });
  }  

  @override
  Widget build(BuildContext context) { 
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: kPrimaryGradientColor,
        ),
        child: Column(
          children: [
            // Barra superior personalizada
          CustomHeader(
            title: _ronda.campo.nombre,
            onBack: _confirmBack,
            onSave: _confirmSave,
            onRefresh: _goRefresh,
            isCreator: isCreator,
          ),
          const SizedBox(height: 12,),
         
            Expanded(
              child: Stack(
                children: [
                  // Cuerpo principal
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double totalHeight = constraints.maxHeight;
                      double segundaParteAltura = 230.0;
                      double primeraParteAltura = totalHeight - segundaParteAltura ;

                      return CustomScrollView(
                        slivers: <Widget>[
                          // Primera parte
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              height: primeraParteAltura,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: _ronda.tarjetas.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return NewTarjetaCard(
                                    tarjeta: _ronda.tarjetas[index],
                                    onSave: _confirmSave,
                                    onBack: _confirmBack,
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Segunda parte
                        isCreator ?  SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              height: segundaParteAltura,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _ronda.tarjetas[0].hoyos.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return buildCardEstadistica(myTarjeta.hoyos[index]);
                                },
                              ),
                            ),
                          ) :  SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              height: segundaParteAltura,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: myTarjeta.hoyos.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return buildCardSoloHoyos(myTarjeta.hoyos[index]);
                                },
                              ),
                            ),
                          ),
                          
                        ],
                      );
                    },
                  ),
                  // Loader
                  if (showLoader)
                    const Positioned.fill(
                      child: MyLoader(opacity: 1, text: ''),
                    ),
                ],
              ),
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

   hoyo.hoyo.par == 3 ?
   Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) =>  MiMapaPar3(hoyo: hoyo, onAgregarShot: agregarShotAEstadisticaHoyo, onDeleteShot: deleteShot, teeSalida: _ronda.tarjetas[0].teeSalida ?? '',)
    )
   )  :

   Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) =>  MiMapa(hoyo: hoyo, onAgregarShot: agregarShotAEstadisticaHoyo, onDeleteShot: deleteShot, teeSalida: _ronda.tarjetas[0].teeSalida ?? '',)
    )
   );
  }

  void agregarShotAEstadisticaHoyo(int idEstadisticaHoyo, Shot nuevoShot) {
    setState(() {
      var estadisticaHoyo = myTarjeta.hoyos.firstWhere(
        (est) => est.id == idEstadisticaHoyo,        
      );       
        estadisticaHoyo.shots!.add(nuevoShot);     
    });
  }

  void deleteShot(int idEstadisticaHoyo, Shot shot) {
    setState(() {
      var estadisticaHoyo = myTarjeta.hoyos.firstWhere(
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
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
               subtitle: Text(
                'Par: ${estadistica.hoyo.par.toString()}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.golf_course, color: Colors.white),
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
                    onPressed: () => _mostrarDialogoEstadisticaHoyo(estadistica.hoyoId),
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

  Widget buildCardSoloHoyos(EstadisticaHoyo estadistica) {
  return SizedBox(
    width: 180,   

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
             
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  void _mostrarDialogoEstadisticaHoyo(int hoyoId) {
  List<EstadisticaHoyo> estadisticasParaHoyo = _ronda.tarjetas.map((tarjeta) {
    return tarjeta.hoyos.firstWhere(
      (hoyo) => hoyo.hoyoId == hoyoId,
      orElse: () => EstadisticaHoyo(hoyo: Hoyo(id: 0,nombre: '', campoId: 0, numero: 0, par: 0), id: 0, hoyoId: 0, golpes: 0, putts: 0, penaltyShots: 0, bunkerShots: 0, acertoFairway: false, falloFairwayDerecha: false, falloFairwayIzquierda: false), // Manejo de caso de no encontrar
    );
  }).toList();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EstadisticaHoyoDialog(
        estadisticasHoyo: estadisticasParaHoyo,
        onGuardar: (List<EstadisticaHoyo> estadisticasGuardadas) {
          setState(() {
            for (int i = 0; i < _ronda.tarjetas.length; i++) {
             //  estadisticasGuardadas[i].calcularNetoPorHoyo(estadisticasGuardadas[i].hoyo, _ronda.tarjetas[i].jugador!.handicap!*1);
              _ronda.tarjetas[i].hoyos = _ronda.tarjetas[i].hoyos.map((hoyo) {
                if (hoyo.hoyoId == hoyoId) {
                  return estadisticasGuardadas[i];
                }
                return hoyo;
              }).toList();
            }
             _ronda.calcularYAsignarPosiciones();

              myTarjeta = _ronda.tarjetas.firstWhere((t) => t.jugadorId == jugador.id);
            
          });
           _goUpdateRonda();
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
        content: const Text('¿Deseas guardar esta ronda?'),
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
    await _goUpdateRonda();
  }
}
 
  Future<void> _goRefresh() async {
    
   setState(() {
     showLoader = true;
   });  
   
    Response   response = await ApiHelper.getRondaById(_ronda.id);
    
    setState(() {
      showLoader=false;
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

      if (mounted) {
        setState(() {
          _ronda = response.result;
           myTarjeta =  _ronda.tarjetas.firstWhere((t) => t.jugadorId == jugador.id);
            _ronda.calcularYAsignarPosiciones();
        });
      }
    

  }

  Future<void> _goSave() async {
    
    setState(() {
     showLoader = true;
   });
   
    Map<String, dynamic> ronda = _ronda.toJson();

    Response response = await ApiHelper.post('api/Rondas/', ronda);   

    setState(() {
      showLoader=false;
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

     

      Fluttertoast.showToast(
        msg: "Ronda Iniciada.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor:kPcontrastMoradoColor,
        textColor: Colors.white,
        fontSize: 20.0
    );

    
       var decodedJson = jsonDecode(response.result);
       var newRonda = Ronda.fromJson(decodedJson);
        
      if (mounted) {
        setState(() {
          _ronda = newRonda;
        });
      }
   

  }

   Future<void> _goUpdateRonda() async {   
    setState(() {
      showLoader=true;
    });
  
    if(isComplete()){
      _ronda.isComplete=true;
    }

    Map<String, dynamic> ronda = _ronda.toJson();

    Response response = await ApiHelper.put('api/Rondas/${_ronda.id}', ronda);
   
    setState(() {
        showLoader=false;
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

      if(isComplete()){
          Fluttertoast.showToast(
            msg: "La Ronda ha Finalizado.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor:kPcontrastMoradoColor,
            textColor: Colors.white,
            fontSize: 20.0
        );
      }
  
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

  
 bool isComplete() {  
  for (var hoyo in _ronda.tarjetas[0].hoyos) {
    if (hoyo.golpes == 0) {
      return false;
    }
  }
  return true;
}
}