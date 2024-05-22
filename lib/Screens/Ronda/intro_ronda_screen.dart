import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/color_change_listtile.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Ronda/mi_ronda_screen.dart';
import 'package:ruitoque/constans.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class IntroRondaScreen extends StatefulWidget {
  const IntroRondaScreen({super.key});

  @override
  State<IntroRondaScreen> createState() => _IntroRondaScreenState();
}

class _IntroRondaScreenState extends State<IntroRondaScreen> {
  bool showLoader = false;
  List<Campo>? campos = [];
  int campoIdSelected = 0;
  String _seleccionado =''; 
  late Campo campoSeleccionado;
  late Jugador jugador;
   bool _isCampoSeleccionadoInitialized = false;

  @override
  void initState() {
   
    super.initState();
    getCampos();
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
  }

 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
        title: 'Iniciar Ronda',
        automaticallyImplyLeading: true,   
        backgroundColor: kPrimaryColor,
        elevation: 8.0,
        shadowColor: const Color.fromARGB(255, 207, 214, 218),
        foreColor: Colors.white,
         actions: [ Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipOval(child:  Image.asset(
                  'assets/LogoGolf.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),), // Ícono de perfil de usuario
            ),],
      ),
         body: Container(
          color: const Color.fromARGB(255, 176, 184, 200),
          child: Center(
            child: showLoader ? const CircularProgressIndicator() : _getContent(),
          ),
        ), 

      
    ),
    );
  }
  
  Future<void> getCampos() async {
    setState(() {
      showLoader = true;
    });
    
    Response response = await ApiHelper.getCampos();

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
     

    setState(() {
      campos=response.result;
   
    });
  }

   Future<void> getCampoSeleccuinado(int id) async {
    setState(() {
      showLoader = true;
    });
    
    Response response = await ApiHelper.getCampo(id.toString());

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
     

    setState(() {
      campoSeleccionado = response.result;
      _seleccionado=campoSeleccionado.tees[0].color;
      _isCampoSeleccionadoInitialized=true;
    });
  }

  Widget _noContent() {
   return Center(
      child: Container(
        decoration: const BoxDecoration(
          gradient: kPrimaryGradientColor
        ),
        margin: const EdgeInsets.all(20),
        child: const Text(
         'No hay Campos.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
   }

  Widget _getContent() {
    return campos!.isEmpty 
      ? _noContent()
      : _getBody();
  }

  _getBody() {
    return Container(
       decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
      child: Column(
        children: [
            const SizedBox(height: 30,),
          const Text('Seleccione el Campo: ', style: kTextStyleBlancoNuevaFuente20 ,),
         CampoListTileWidget(
            campos: campos!,
            onCampoSelected: (int id) {
             setState(() {
               campoIdSelected = id;            
             });
             getCampoSeleccuinado(campoIdSelected);
            },
          ),
           const SizedBox(height: 20,),
           _isCampoSeleccionadoInitialized ?   const Text('Tee de Salida: ', style: kTextStyleBlancoNuevaFuente20 ,) : Container(),
           _isCampoSeleccionadoInitialized ? Padding(
             padding: const EdgeInsets.all(10),
             child: Container(
                  padding: const EdgeInsets.all(8),
                height: 100,
                decoration: BoxDecoration(
                  gradient: kPrimaryGradientColor,
                  borderRadius: BorderRadius.circular(10.0), // Radio de los bordes redondeados
                  // Puedes agregar más propiedades de estilo si lo necesitas
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoPicker(
                    magnification: 1.2,
                    diameterRatio: 1.1,
                    backgroundColor: Colors.white,
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _seleccionado = campoSeleccionado.tees[index].color;
                      });
                    },
                    children: campoSeleccionado.tees.map((Tee tee) {
                      return Center(
                        child: Text(tee.color), // Solo se muestra el nombre del color
                      );
                    }).toList(),
                  ),
                ),
              ),
           ) : Container( decoration: const BoxDecoration(gradient: kPrimaryGradientColor), ),
      
          const SizedBox(height: 5,),
       _isCampoSeleccionadoInitialized ?   DefaultButton(
            text: const Text('Iniciar Ronda', style: kTextStyleBlancoNuevaFuente20, textAlign: TextAlign.center ,),
             press: () => goRonda(),
             gradient: kSecondaryGradient,
             color: kPrimaryColor,
             
            ) :Container( decoration: const BoxDecoration(gradient: kPrimaryGradientColor), ),
               const SizedBox(height: 5,),
         
        ],
      ),
    );
  }
  
 Future<void> goRonda() async {

    // if(campoIdSelected == 0) {
    //   mostrarSnackBar(context, '¡Seleccione un Campo!');
    //   return;
    // }

    // await getCampoSeleccuinado(campoIdSelected);
 
      Tarjeta tarjeta = Tarjeta(
        id: 0, 
        jugadorId: jugador.id, 
        rondaId: 0, 
        jugador: jugador,  
        hoyos: [], 
        campo: campoSeleccionado, 
        teeSalida: _seleccionado.toString(),
      );

      Ronda ronda = Ronda(id: 0, fecha: DateTime.now(), tarjetas: [], campo: campoSeleccionado, campoId: campoSeleccionado.id, isComplete: false);

      if (campoSeleccionado.hoyos.length == 6){
        int idc = 1;
          for (int i = 1; i <= 3; i++) {
               for (Hoyo hoyo in campoSeleccionado.hoyos) {
                  EstadisticaHoyo aux = EstadisticaHoyo(
                    id: idc,
                    hoyo: hoyo,
                    hoyoId: hoyo.id, 
                    golpes: 0, 
                    putts: 0, 
                    bunkerShots: 0, 
                    acertoFairway: false, 
                    falloFairwayIzquierda: false, 
                    falloFairwayDerecha: false, 
                    penaltyShots: 0,
                    shots: [],
                  );
                  tarjeta.hoyos.add(aux);
                  idc+=1;
                }
           }
      }
      else {
        for (Hoyo hoyo in campoSeleccionado.hoyos) {
          EstadisticaHoyo aux = EstadisticaHoyo(
             id: hoyo.id,
             hoyo: hoyo,
             hoyoId: hoyo.id, 
             golpes: 0, 
             putts: 0, 
             bunkerShots: 0, 
             acertoFairway: false, 
             falloFairwayIzquierda: false, 
             falloFairwayDerecha: false, 
             penaltyShots: 0,
             shots: [],
          );
          tarjeta.hoyos.add(aux);
      }  
      }

      

      ronda.tarjetas.add(tarjeta);

      if(mounted){
        Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) =>  MiRonda(ronda: ronda,)
          ),
        );
      }
     
  }

  void mostrarSnackBar(BuildContext context, String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: const Duration(seconds: 2),
    );

    // Muestra el SnackBar usando ScaffoldMessenger
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // goCampo() async {

  //    if(campoIdSelected == 0) {
  //     mostrarSnackBar(context, '¡Seleccione un Campo!');
  //     return;
  //   }

    
  //   await getCampoSeleccuinado(campoIdSelected);

  //   campoSeleccionado.id=0;
  //   for (Hoyo hoyo in campoSeleccionado.hoyos){
  //     hoyo.campoId=0;
  //     hoyo.id=0;
  //     hoyo.frenteGreen!.id=0;
  //     hoyo.centroGreen!.id=0;
  //     hoyo.fondoGreen!.id=0;
  //     hoyo.centroHoyo!.id=0;
     
  //   }

  //    Map<String, dynamic> request = campoSeleccionado.toJson();

  //   var url = Uri.parse('http://200.91.130.215:9095/api/Campos/');
  //   var response = await http.post(
  //     url,
  //     headers: {
  //       'content-type' : 'application/json',
  //       'accept' : 'application/json',       
  //     },
  //     body: jsonEncode(request)
  //   );    

  //   if(response.statusCode >= 400){
     
  //       if (mounted) {       
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: const Text('Error'),
  //               content:  const Text('Paila'),
  //               actions: <Widget>[
  //                 TextButton(
  //                   child: const Text('Aceptar'),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       }  
  //      return;
     
  //   }     
  //    if (mounted) {       
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: const Text('Error'),
  //               content:  const Text('Todo Good'),
  //               actions: <Widget>[
  //                 TextButton(
  //                   child: const Text('Aceptar'),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       }  

  // }

  
}