import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_item_campo.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Components/my_loader.dart';
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
        backgroundColor: kPprimaryColor,
        elevation: 8.0,
        shadowColor: const Color.fromARGB(255, 2, 44, 68),
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
         decoration: const BoxDecoration(
          gradient: kFondoGradient
         ),
          child: Center(
            child: showLoader ? const MyLoader(opacity: 0.8, text: 'Cargando...',) : _getContent(),
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

  _setCampoSelect (int id) {    
    setState(() {
      campoIdSelected = id;
    });
    getCampoSeleccuinado(campoIdSelected);
                  
  }
 
  Widget _getBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: kFondoGradient
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Seleccione el Campo:',
                style: kTextStyleBlancoNuevaFuente20,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: ListView.builder(
                itemCount: campos!.length,
                itemBuilder: (context, index) {
                  Campo campo = campos![index];
                  return CardItemCampo(campo: campo, onTap: () => _setCampoSelect(campo.id));
                },
              ),
            ),
          ),
          if (_isCampoSeleccionadoInitialized) ...[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tee de Salida:',
                style: kTextStyleBlancoNuevaFuente20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                height: 100,
                decoration: BoxDecoration(
                  gradient: kPrimaryGradientColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
                      child: Text(tee.color),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: DefaultButton(
                text: const Text(
                  'Iniciar Ronda',
                  style: kTextStyleBlancoNuevaFuente20,
                  textAlign: TextAlign.center,
                ),
                press: () => goRonda(),
                gradient: kPrimaryGradientColor,
                color: kPsecondaryColor,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }


  
 Future<void> goRonda() async {

 
 
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
                    handicapPlayer: jugador.handicap
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
              handicapPlayer: jugador.handicap
          );
          tarjeta.hoyos.add(aux);
      }  
      }

      

      ronda.tarjetas.add(tarjeta);

      if(mounted){
        Navigator.pushAndRemoveUntil(
           context, 
          MaterialPageRoute(
            builder: (context) => MiRonda(ronda: ronda),
          ), 
          (Route<dynamic> route) => false, // Esto elimina todas las rutas anteriores
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
  
  
  
}