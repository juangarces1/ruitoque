import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/custom_header.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Components/new_card_tardejta.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/constans.dart';



class RondaRapida extends StatefulWidget {
  final Ronda ronda;
 
  const RondaRapida({super.key, required this.ronda, });

  @override
  State<RondaRapida> createState() => _RondaRapidaState();
}

class _RondaRapidaState extends State<RondaRapida> {
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
   
     jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;   
     isCreator = jugador.id == _ronda.creatorId ? true: false;
     myTarjeta =  _ronda.tarjetas.firstWhere((t) => t.jugadorId == jugador.id);
     _ronda.calcularYAsignarPosiciones();
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
                     
                     
                      return CustomScrollView(
                        slivers: <Widget>[
                          // Primera parte
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              height: totalHeight,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: _ronda.tarjetas.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return NewTarjetaCard(
                                    tarjeta: _ronda.tarjetas[index],
                                    onSave: _confirmSave,
                                    onBack: _confirmBack,
                                    onEnterScores:  () => _showScoreEntryDialogForPlayer(_ronda.tarjetas[index]),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Segunda parte
                        //  const SliverToBoxAdapter(child: GolfScoreCard()),
                          
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
    await _goSave();
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
            _ronda.tarjetas.sort((a, b) => a.scorePar.compareTo(b.scorePar));
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
        msg: "Ronda Guardada.",
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

  void _showScoreEntryDialogForPlayer(Tarjeta tarjeta) {
   List<int> scores = tarjeta.hoyos.map((h) => h.golpes == 0 ? h.hoyo.par : h.golpes).toList();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Para poder hacer setState dentro del diálogo usamos StatefulBuilder
      return StatefulBuilder(
        builder: (BuildContext context, setStateDialog) {
        
      

          return AlertDialog(
            title: Text('Scores de ${tarjeta.jugador!.nombre}'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Ingresa los golpes para cada hoyo de forma rápida',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: ListView.builder(
                      itemCount: tarjeta.hoyos.length,
                      itemBuilder: (context, index) {
                        final estadistica = tarjeta.hoyos[index];
                        return Card(
                          color: const Color.fromARGB(117, 255, 255, 255),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Info del hoyo
                                Expanded(
                                  child: Text(
                                    'Hoyo ${estadistica.hoyo.numero} Par:${estadistica.hoyo.par}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Botón para bajar el score
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      color: Colors.redAccent,
                                      onPressed: () {
                                        setStateDialog(() {
                                          if (scores[index] > 1) {
                                            scores[index]--;
                                             
                                          }
                                        });
                                      },
                                    ),
                                    // Muestra el valor actual
                                    Text(
                                      scores[index].toString(),
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    // Botón para subir el score
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      color: Colors.green,
                                      onPressed: () {
                                        setStateDialog(() {
                                          scores[index]++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Actualiza los golpes en la tarjeta
                   for (int i = 0; i < tarjeta.hoyos.length; i++) {
                    final estadisticaHoyo = tarjeta.hoyos[i];
                    estadisticaHoyo.golpes = scores[i];

                   
                   
                  }

                  // 3. Actualizamos el estado de la tarjeta
                  // Updating the state of the tarjeta here ensures that the UI reflects the changes made to the scores.
                  setState(() {
                    _ronda.calcularYAsignarPosiciones();
                  });

                  Navigator.of(context).pop();

                  // Si quieres, llama a tu _goUpdateRonda() para reflejar los cambios
                 // _goUpdateRonda();

                  // Sarcasmo de confirmación:
                  Fluttertoast.showToast(
                    msg: "El jugador ${tarjeta.jugador!.nombre} registró sus golpes. ",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}

}