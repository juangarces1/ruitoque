import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/Components/input_decoration.dart';
import 'package:ruitoque/Screens/Campos/editar_coordenada_screen.dart';
import 'package:ruitoque/constans.dart';

class AddHoyoTeesPage extends StatefulWidget {
  final List<Tee> availableTees;
  final Cordenada cordenada;
  final Function(HoyoTee) onAddHoyoTee;
  final Function(HoyoTee) onEditTee;
  final HoyoTee? hoyoTee; // Parámetro opcional para edición

  const AddHoyoTeesPage({
    Key? key,
    required this.availableTees,
    required this.onAddHoyoTee,
    required this.cordenada,
    this.hoyoTee, required this.onEditTee, // Puede ser null si estamos creando uno nuevo
  }) : super(key: key);

  @override
  AddHoyoTeesPageState createState() => AddHoyoTeesPageState();
}

class AddHoyoTeesPageState extends State<AddHoyoTeesPage> {
  Tee? selectedTee;
  Cordenada cordenadaActual = Cordenada(id: 0, latitud: 0, longitud: 0);
  TextEditingController distanciaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si estamos editando, inicializamos los valores
    if (widget.hoyoTee != null) {
      selectedTee = widget.availableTees[0];
      cordenadaActual = widget.hoyoTee!.cordenada;
      distanciaController.text = widget.hoyoTee!.distancia.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar:MyCustomAppBar(
        title: widget.hoyoTee == null ? "Agregar Tee" : "Editar Tee",
        automaticallyImplyLeading: true,   
        backgroundColor: kPprimaryColor,
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
        decoration: const BoxDecoration(
          gradient: kFondoGradient
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                 const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                color: Colors.white70,
                child: Center(
                  child: DropdownButton<Tee>(
                    hint: const Text("Seleccione un Tee"),
                    value: selectedTee,
                    onChanged: (Tee? newValue) {
                      setState(() {
                        selectedTee = newValue;
                      });
                    },
                    items: widget.availableTees.map((Tee tee) {
                      return DropdownMenuItem<Tee>(
                        value: tee,
                        child: Text(tee.color),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
               Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        child: ElevatedButton(
                            onPressed:  () => _editarCoordenada(),
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPprimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                            child:  Text(widget.hoyoTee == null ? "Agregar Coordenada" : "Editar Coordenada"),
                          ),
                      ),
        
              const SizedBox(height: 20),
              if (selectedTee != null) _buildTeeEntry(),
               const SizedBox(height: 20),
                  Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        child: ElevatedButton(
                            onPressed:  () => _saveHoyoTee(),
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPprimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                            child:  Text(widget.hoyoTee == null ? 'Agregar Tee' : 'Guardar Cambios'),
                          ),
                      ),
             
            ],
          ),
        ),
      ),
    );
  }

  void _editarCoordenada() async {
    Cordenada myCordena = Cordenada(id: 0, latitud: 0, longitud: 0);
    if(widget.hoyoTee== null){
        myCordena=widget.cordenada;
    } else {
        myCordena=widget.hoyoTee!.cordenada;
    }

     await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCoordenadaScreen(
          titulo: widget.hoyoTee == null ? 'Agregar Cordenada' : 'Editar Cordenada Tee ${widget.hoyoTee!.color}',
          coordenadaInicial: myCordena,
          onCoordenadaActualizada: (nuevaCoordenada) {
            setState(() {
              if(widget.hoyoTee== null){
                 cordenadaActual = nuevaCoordenada;
              } else {
                widget.hoyoTee!.cordenada=nuevaCoordenada;
                 cordenadaActual = nuevaCoordenada;
              }

             
            });
          },
        ),
      ),
    );
   
  }

  Widget _buildTeeEntry() {
    return Center(
      child: Column(
        children: <Widget>[
          Text("Tee Color: ${selectedTee!.color}", style: const TextStyle(color: Colors.white70, fontSize: 18),),
          const SizedBox(height: 5,),
          Text("Coordenada Latitud: ${cordenadaActual.latitud}", style: const TextStyle(color: Colors.white70, fontSize: 18),),
            const SizedBox(height: 5,),
          Text("Coordenada Longitud: ${cordenadaActual.longitud}", style: const TextStyle(color: Colors.white70, fontSize: 18),),
             const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(left: 100, right: 100, top: 5),
            child: TextFormField(
              style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
              controller: distanciaController,
              decoration: buildInputDecoration('Distancia'),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  void _saveHoyoTee() {
    if (selectedTee != null && distanciaController.text.isNotEmpty) {
        if(widget.hoyoTee==null){
          HoyoTee hoyoTee = HoyoTee(
          id: widget.hoyoTee?.id ?? 0, // Si es un nuevo HoyoTee, id será 0
          hoyoId: widget.hoyoTee?.hoyoId ?? 0, // Asigna el HoyoID si ya existe
          cordenada: cordenadaActual,
          color: selectedTee!.color,
          distancia: int.parse(distanciaController.text),
        );
        widget.onAddHoyoTee(hoyoTee);
      
      } else {
        widget.hoyoTee!.distancia = int.parse(distanciaController.text);
        widget.onEditTee(widget.hoyoTee!);
      }
        Navigator.pop(context);
     
    }
  }
}
