import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_jugador.dart';
import 'package:ruitoque/Components/loader_component.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Screens/Campos/add_course_screen.dart';
import 'package:ruitoque/Screens/Campos/sekect_campo_scree.dart';
import 'package:ruitoque/Screens/Home/Components/menu_item.dart';
import 'package:ruitoque/Screens/LogIn/login_screen.dart';
import 'package:ruitoque/Screens/Ronda/intro_ronda_screen.dart';
import 'package:ruitoque/Screens/Tarjetas/my_tarjetas_screen.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, });
 

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showLoader =false;
  double? value = 0;
  Campo campo = Campo(id: 0, nombre: '', ubicacion: '', hoyos: [], tees: []);
  late Jugador jugador;

  @override
  void initState() {   
    super.initState();
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);  
    return SafeArea(
      child: Scaffold(     
               
        body:  Stack(
          children: [
          Container(
            decoration: const BoxDecoration(
              gradient: kGradiantBandera
            ),
          ),
          SafeArea(
    
            child: Container(
            width: 250,
            
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              
             const SizedBox(
               height: 10,),
               Container(
                padding: const EdgeInsets.all(10),
                width: 50,  // Ancho del cuadrado
                height: 50, // Altura del cuadrado
                decoration: BoxDecoration(
                    // Para esquinas redondeadas, usa BorderRadius
                    borderRadius: BorderRadius.circular(10), // Puedes ajustar el radio
                    image: const DecorationImage(
                        image: AssetImage('assets/LogoGolf.png'),
                        fit: BoxFit.cover, // Cubre el área del contenedor
                    ),
                ),
            ) ,
                const SizedBox(height: 10,),
                Text(jugador.nombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
    
                Expanded(             
                
               child:   principalMenu(context, jugador), 
                
                ),
            ]),
          ),
          ),
    
          TweenAnimationBuilder(
            tween: Tween<double>(begin:0, end: value),
            duration: const Duration(milliseconds: 500),
             builder: (_,double val,__){
              return(Transform(transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..setEntry(0, 3, 200*val)
              ..rotateY((pi/6)*val),
              alignment: Alignment.center,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: kColorFondoOscuro,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child:MyCustomAppBar(
                        title: 'Golf Colombia',
                          automaticallyImplyLeading: true,   
                          backgroundColor:  const Color.fromARGB(255, 0, 71, 44),
                          elevation: 8.0,
                          shadowColor: const Color.fromARGB(255, 127, 140, 10),
                          foreColor: Colors.white,
                          actions: [ 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                    'assets/LogoGolf.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ), // Ícono de perfil de usuario
                              ),
                          ],
                        
                        ),
              
                  ),
                  body: Container(
                    decoration: const BoxDecoration(
                       image: DecorationImage(
                        image: AssetImage('assets/fondoHome.webp'),
                        fit: BoxFit.fill, // Ajusta la imagen para que cubra el área de 4:3
                      ),),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10 , right: 10, left: 10),
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            CardJugador(jugador: jugador,),
                          ],
                        )),
                        showLoader ? const Center(child: MyLoader(text: 'Cargando...',opacity: 0.7,),) : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
              ));
             }
             
             ),
             
          GestureDetector(
            onHorizontalDragUpdate: (details){
              if(details.delta.dx>0){
                setState(() {
                  value = 1;
                });
              }
              else{
                setState(() {
                  value = 0;
                });
              }
            },
          ),     
         ],
        ),
      ),
    );
    
  }

 Widget principalMenu(BuildContext context, Jugador jugador) {
  const TextStyle myStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  // Definir los ítems del menú
  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Iniciar Ronda',
      leading: const CircleAvatar(
        radius: 12,
        backgroundImage: AssetImage('assets/marker.png'),
        backgroundColor: kPrimaryColor,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IntroRondaScreen(),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Mis Tarjetas',
      leading: const Icon(
        Icons.scoreboard_sharp,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyTarjetasScreen(jugador: jugador),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Agregar Campo',
      leading: const Icon(
        Icons.flag_circle_outlined,
        color: Colors.white
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddCourseScreen(),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Editar Campo',
      leading: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectCampoScreen(),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Cerrar Sesión',
      leading: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      textColor: Colors.black, // Diferente color para este ítem
    ),
  ];

  return ListView.builder(
    itemCount: menuItems.length,
    itemExtent: 60, // Ajusta el tamaño según tus necesidades
    itemBuilder: (context, index) {
      final item = menuItems[index];
      return ListTile(
        textColor: item.textColor,
        leading: item.leading,
        title: Text(
          item.title,
          style: myStyle,
        ),
        onTap: item.onTap,
      );
    },
  );
}


  Future<String> readJsonFromFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ruitoque .json');

    // Verifica si el archivo existe antes de intentar leerlo
    if (await file.exists()) {
      String jsonString = await file.readAsString();
      // Decodifica el string JSON a un objeto Map
     // Map<String, dynamic> jsonObject = jsonDecode(jsonString);
      return jsonString;
    } else {
     
      return '{}';
    }
  } catch (e) {
   
    return '{};';
  }
}
  
  Future<List<String>> listJsonFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<String> jsonFiles = [];

    // Listar todos los archivos en el directorio.
    final fileList = directory.listSync();
    for (var file in fileList) {
        // Verificar si el archivo es un .json
        if (file.path.endsWith('.json')) {
            jsonFiles.add(file.path.split('/').last);
        }
    }
    return jsonFiles;
}

Future<void> _goSave() async {
    
    setState(() {
     showLoader = true;
   });

   Response response = await ApiHelper.post('api/Campos/', campo.toJson());
 
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
  
  gointroRonda() {
     Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) =>  const IntroRondaScreen()
        ),
      );

  }


 
}