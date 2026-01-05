import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/custom_header.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Components/new_card_tardejta.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/Request%20Dtos/create_ronda_request.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';
import 'package:ruitoque/Screens/Mapas/mapa_hoyo_screen.dart';
import 'package:ruitoque/Screens/Mapas/mapa_par3.dart';
import 'package:ruitoque/Screens/Mapas/mapa_par5.dart';
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
     // Usa tienePermisosEdicion() para soportar RondaDeAmigos (responsableId)
     isCreator = _ronda.tienePermisosEdicion(jugador.id);
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
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                              height: segundaParteAltura,
                              child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 12), // margen lateral
                                    itemCount: _ronda.tarjetas[0].hoyos.length,
                                    itemBuilder: (context, index) {
                                      return buildCardEstadistica(myTarjeta.hoyos[index]);
                                    },
                                    separatorBuilder: (context, index) => const SizedBox(width: 12), // espacio entre cards
                                  )
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
                      child: MyLoader(opacity: 1, text: '.'),
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
    if (hoyo.hoyo.par == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MiMapaPar3(
            hoyo: hoyo,
            onAgregarShot: agregarShotAEstadisticaHoyo,
            onDeleteShot: deleteShot,
            teeSalida: _ronda.tarjetas[0].teeSalida ?? '',
          ),
        ),
      );
    } else if (hoyo.hoyo.par == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapaPar5(
            hoyo: hoyo,
            teeSalida: _ronda.tarjetas[0].teeSalida ?? '',
            onAgregarShot: agregarShotAEstadisticaHoyo,
            onDeleteShot: deleteShot,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MiMapa(
            hoyo: hoyo,
            onAgregarShot: agregarShotAEstadisticaHoyo,
            onDeleteShot: deleteShot,
            teeSalida: _ronda.tarjetas[0].teeSalida ?? '',
          ),
        ),
      );
    }
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
  final bool isSaved = (estadistica.golpes > 0) || ((estadistica.shots?.isNotEmpty ?? false));
  const Color baseDark = Color(0xFF151922);
  const Color elev2    = Color(0xFF1B202B);
  const Color txtPri   = Color(0xFFE8EAED);
  const Color txtSec   = Color(0xFFAEB4BE);
  const Color border   = Color(0x1AFFFFFF); // 10% white

  return SizedBox(
    width: 220,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(1), // espacio para el borde "externo"
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Borde animado según estado
        border: Border.all(
          color: isSaved ? Colors.greenAccent : kPsecondaryColor,
          width: isSaved ? 2 : 1,
        ),
        // Glow sutil cuando está guardado
        boxShadow: isSaved
            ? [
                BoxShadow(
                  color: kPsecondaryColor.withOpacity(.35),
                  blurRadius: 14,
                  spreadRadius: 1.2,
                ),
              ]
            : [
                const BoxShadow(
                  color: Colors.black54,
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        color: baseDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isSaved ? kPsecondaryColor.withOpacity(.45) : border,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {}, // solo para ripple
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------- Header ----------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Flag con "ring" sutil si hay progreso
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isSaved)
                          SizedBox(
                            width: 28, height: 28,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 2.2,
                              color: kPsecondaryColor,
                              backgroundColor: Colors.white.withOpacity(.06),
                            ),
                          ),
                        const SizedBox(width: 28, height: 28),
                        const Icon(Icons.flag, color: Colors.white70, size: 18),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hoyo N
                          Text(
                            'Hoyo ${estadistica.hoyo.numero}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: txtPri,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _pill('Par ${estadistica.hoyo.par}', txtSec, elev2, border),
                              const SizedBox(width: 6),
                              _statusBadge(isSaved ? 'Guardado' : 'Pendiente', isSaved),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      
                const SizedBox(height: 10),
                const Divider(height: 1, color: border),
      
                // ---------- Tira de shots ----------
                const SizedBox(height: 10),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: elev2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: (estadistica.shots != null && estadistica.shots!.isNotEmpty)
                      ? Stack(
                          children: [
                            // scroll chips
                            ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, i) {
                                final shot = estadistica.shots![i];
                                return ShotTile(
                                  index: i,
                                  shot: shot,
                                  onDelete: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text('Confirmar eliminación'),
                                          content: const Text('¿Eliminar este golpe?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancelar'),
                                              onPressed: () => Navigator.of(ctx).pop(),
                                            ),
                                            TextButton(
                                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                              onPressed: () {
                                                deleteShot(estadistica.id, shot);
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemCount: estadistica.shots!.length,
                            ),
                            // fades laterales
                            _edgeFade(left: true),
                            _edgeFade(right: true),
                          ],
                        )
                      : const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sports_golf, size: 18, color: txtSec),
                              SizedBox(width: 8),
                              Text('Sin golpes aún', style: TextStyle(color: txtSec, fontSize: 12)),
                            ],
                          ),
                        ),
                ),
      
                // ---------- Acciones ----------
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionPill(
                        icon: Icons.map_outlined,
                        label: 'Mapa',
                        bg: Colors.white,
                        fg: kPprimaryColor,
                        onTap: () => goHole(estadistica),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionPill(
                        icon: Icons.bar_chart,
                        label: 'Stats',
                        bg: kPsecondaryColor,
                        fg: Colors.white,
                        onTap: () => _mostrarDialogoEstadisticaHoyo(estadistica.hoyoId),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------- helpers visuales (solo UI) ----------
Widget _statusBadge(String text, bool ok) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: ok ? Colors.green.withOpacity(.18) : Colors.white.withOpacity(.06),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: ok ? Colors.green.withOpacity(.5) : const Color(0x1AFFFFFF)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ok ? Icons.check_circle : Icons.timelapse, size: 14, color: ok ? Colors.green : Colors.white70),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: ok ? Colors.green : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: .4,
          ),
        ),
      ],
    ),
  );
}

Widget _pill(String text, Color fg, Color bg, Color border) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: border),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .6),
    ),
  );
}

Widget _edgeFade({bool left = false, bool right = false}) {
  assert(left != right); // uno u otro
  return Positioned(
    left: left ? 0 : null,
    right: right ? 0 : null,
    top: 0,
    bottom: 0,
    child: IgnorePointer(
      child: Container(
        width: 18,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: left ? Alignment.centerLeft : Alignment.centerRight,
            end: left ? Alignment.centerRight : Alignment.centerLeft,
            colors: const [
              Color(0xFF1B202B),
              Color(0x001B202B),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _actionPill({
  required IconData icon,
  required String label,
  required Color bg,
  required Color fg,
  required VoidCallback onTap,
}) {
  return Material(
    color: bg,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
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

  
    
    Response response = await ApiHelper.post('api/Rondas/', _ronda.toJson());   

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
          _ronda.calcularYAsignarPosiciones();
          myTarjeta = _ronda.tarjetas.firstWhere(
            (t) => t.jugadorId == jugador.id,
            orElse: () => _ronda.tarjetas.first,
          );
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
      Navigator.popUntil(context, (route) => route.isFirst);
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
