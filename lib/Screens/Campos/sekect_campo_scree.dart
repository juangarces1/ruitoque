
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_item_campo.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Screens/Campos/add_course_screen.dart';
import 'package:ruitoque/constans.dart';

class SelectCampoScreen extends StatefulWidget {
  const SelectCampoScreen({super.key});

  @override
  State<SelectCampoScreen> createState() => _SelectCampoScreenState();
}

class _SelectCampoScreenState extends State<SelectCampoScreen> {
  bool showLoader = false;
  List<Campo>? campos = [];
  int campoIdSelected = 0; 
  Campo? campoSeleccionado; 
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
        title: 'Seleccione El Campo',
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
     campoSeleccionado = response.result as Campo?; // Si el resultado es Campo?, se puede asignar
      _isCampoSeleccionadoInitialized = campoSeleccionado != null; // Solo lo inicializas si es no-nulo
    });
  }

  Widget _noContent() {
   return Center(
      child: Container(
        decoration: const BoxDecoration(
          gradient: kFondoGradient
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
             Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  campoSeleccionado!.nombre,
                  style: kTextStyleBlancoNuevaFuente20,
                ),
              ),
            ),
            
            const SizedBox(height: 5),
            Center(
              child: DefaultButton(
                text: const Text(
                  'Editar Campo',
                  style: kTextStyleBlancoNuevaFuente20,
                  textAlign: TextAlign.center,
                ),
                press: () => goEditCampo(),
                gradient: kPrimaryGradientColor,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }
  

  void mostrarSnackBar(BuildContext context, String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: const Duration(seconds: 2),
    );

    // Muestra el SnackBar usando ScaffoldMessenger
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
goEditCampo() {
  if (campoSeleccionado != null) {
      Navigator.pushAndRemoveUntil(
           context, 
          MaterialPageRoute(
            builder: (context) => AddCourseScreen(campo: campoSeleccionado),
          ), 
          (Route<dynamic> route) => false, // Esto elimina todas las rutas anteriores
        );
    } else {
      mostrarSnackBar(context, 'Por favor, seleccione un campo antes de editar.');
    }
  }

  
}