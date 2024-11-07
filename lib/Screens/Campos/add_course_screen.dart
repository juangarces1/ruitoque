import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/Components/hoyo_list.dart';
import 'package:ruitoque/Screens/Campos/Components/input_decoration.dart';
import 'package:ruitoque/Screens/Campos/Components/tees_list.dart';
import 'package:ruitoque/Screens/Campos/add_edit_teepage.dart';
import 'package:ruitoque/Screens/Campos/agregar_hoyos_screen.dart';
import 'package:ruitoque/Screens/Campos/crear_cordenada_screen.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/constans.dart';

class AddCourseScreen extends StatefulWidget {
  final Campo? campo; // El campo existente que se pasará si estamos editando

  const AddCourseScreen({Key? key, this.campo}) : super(key: key);

  @override
  AddCourseScreenState createState() => AddCourseScreenState();
}

class AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final List<Hoyo> _hoyos = [];
  final List<Tee> _tees = []; 
  bool showLoader = false;

  @override
  void initState() {
    super.initState();

    // Si recibimos un campo existente, rellenar los controladores y las listas con sus datos
    if (widget.campo != null) {
      _idController.text = widget.campo!.id.toString();
      _nombreController.text = widget.campo!.nombre;
      _ubicacionController.text = widget.campo!.ubicacion;
      _hoyos.addAll(widget.campo!.hoyos);
      _tees.addAll(widget.campo!.tees);    
    }
  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(     
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MyCustomAppBar(
          title: widget.campo == null ? 'Agregar Campo' : 'Editar Campo', // Cambiar el título
          automaticallyImplyLeading: true,
          backgroundColor: kPprimaryColor,
          elevation: 8.0,
          shadowColor: const Color.fromARGB(255, 244, 244, 245),
          foreColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset(
                'assets/LogoGolf.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kFondoGradient

        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                     TextFormField(
                        controller: _idController,
                        decoration:  buildInputDecoration('Id'),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Por favor ingresa el ID' : null,
                        enabled: widget.campo == null, // Deshabilitar ID en edición
                      ),
                      const SizedBox(height: 10), // Espaciado entre campos
                      TextFormField(
                        controller: _nombreController,
                        decoration:  buildInputDecoration('Nombre'),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        validator: (value) => value == null || value.isEmpty ? 'Por favor ingresa el nombre del campo' : null,
                      ),
                      const SizedBox(height: 10), // Espaciado entre campos
                      TextFormField(
                        controller: _ubicacionController,
                        decoration: buildInputDecoration('Ubicacion'),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        validator: (value) => value == null || value.isEmpty ? 'Esta ubicación no se va a llenar sola' : null,
                           onFieldSubmitted: (value) {
                              // Se ejecuta cuando se presiona Enter
                              FocusScope.of(context).unfocus(); // Quitar el foco
                            },
                      ),
        
                
                       Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 90),
                        child: ElevatedButton(
                            onPressed: () => _navegarAgregarCoodenadaInicial(context),
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPprimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                            child: const Text('Set Coordenada'),
                          ),
                      ),
                     
                     
                        Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 90),
                        child: ElevatedButton(
                            onPressed: () => _navegarAddTee(context),
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPprimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                            child: const Text('Agregar Tee'),
                          ),
                      ),
                      Container(
                        height: 100,
                       decoration: BoxDecoration(
                        color: kPverdeBienOscuto,
                        borderRadius: BorderRadius.circular(10)
                       ),
                        child: TeesListWidget(
                          tees: _tees,
                           onTeeDelete: _deleteTee,
                           onTeeEdit:  _editTee,                     
                            ),
                      ),
                     
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 90),
                        child: ElevatedButton(
                            onPressed:  () => _navegarYAgregarHoyos(context),
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPprimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                            child: const Text('Agregar Hoyo'),
                          ),
                      ),
                      Container(
                        height: 200,                        
                          decoration: BoxDecoration(
                          color: kPverdeBienOscuto,
                          borderRadius: BorderRadius.circular(10)),
                      
                         child: HoyosListWidget(                         
                          onDelete: (Hoyo hoyo) {
                            setState(() {
                              _hoyos.removeWhere((mihoyo) => mihoyo.nombre == hoyo.nombre);
                            });
                            
                          },
                          tees: _tees,
                          onUpdate: (nuevo) => onUpdateHoyo(nuevo),
                          hoyos: _hoyos,
                        ),
                      ),
                       Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        child: ElevatedButton(
                            onPressed:  _goSave,
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPprimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                            child: Text(widget.campo == null ? 'Guardar Campo' : 'Actualizar Campo'), // Cambiar el texto del botón
                          ),
                      ),
                      const SizedBox(height: 20,),
                      buildGetBark(context),
                    ],
                  ),
                ),
              ),
            ),
            showLoader ? const MyLoader(opacity: 0.8, text: 'Procesando...',): const SizedBox()
          
          ],
        
        ),
      ),
    );
  }

 bool _isTeeAssociatedWithHoyo(Tee tee) {
    for (Hoyo hoyo in _hoyos) {
      for (HoyoTee hoyoTee in hoyo.hoyotees?? []) { // Asegúrate de que `hoyotees` no sea null
        if (hoyoTee.id == tee.id) {
          return true; // El Tee está asociado a este Hoyo
        }
      }
    }
    return false; // No se encontró el Tee en ningún Hoyo
  }

 void _editTee(Tee updatedTee) {
      setState(() {
        int index = _tees.indexWhere((tee) => tee.id == updatedTee.id);
        if (index != -1) {
          _tees[index] = updatedTee; // Actualizar el Tee en la lista
        }
      });
  }

 void _deleteTee(Tee tee) {
    if( _isTeeAssociatedWithHoyo(tee)) {
      return;
    }
    setState(() {
      _tees.remove(tee); // Eliminar el Tee de la lista
    });
  }



  void  onAgregarHoyo (Hoyo nuevoHoyo) {
            setState(() {
              _hoyos.add(nuevoHoyo);
            });
          }

  void  onUpdateHoyo (nuevoHoyo) {
      setState(() {
          int index = _hoyos.indexWhere((hoyo) => hoyo.id == nuevoHoyo.id);
          if (index != -1) {
            widget.campo!.hoyos[index] = nuevoHoyo; // Actualizar el Tee en la lista
          }
      });
    }

  void _navegarYAgregarHoyos(BuildContext context) async {   
  
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgregarHoyosScreen(             
              tees: _tees,
              onAgregarHoyo: (nuevo) => onAgregarHoyo(nuevo),
              onUpdateHoyo: (nuevo) => onAgregarHoyo(nuevo),
              
            ),
          ),
        );
   
    }
   
  void _navegarAgregarCoodenadaInicial(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrearCordenadaScreen(),
    ));
  }

  void _navegarAddTee(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTeePage(
          onTeeAdded: (newTee) {
            setState(() {
              _tees.add(newTee);
            });
          },
          onTeeUpdated: _editTee       
      
        ),
      ),
    );
  }

  Future<void> _goSave() async {
    setState(() {
      showLoader = true;
    });

    var nuevoCampo = Campo(
      id: int.parse(_idController.text),
      nombre: _nombreController.text,
      ubicacion: _ubicacionController.text,
      hoyos: _hoyos,
      tees: _tees,     
    );

    Response response;

    if (widget.campo == null) {
      // Crear nuevo campo
      response = await ApiHelper.post('api/Campos/', nuevoCampo.toJson());
    } else {
      // Actualizar campo existente
        response = await ApiHelper.put('api/Campos/UpdateCampo/${nuevoCampo.id}', nuevoCampo.toJson());
      //   response = await ApiHelper.post('api/Campos/', nuevoCampo.toJson());
    }

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
              content: Text(response.message),
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Todo Good'),
            content: Text(response.message),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {                 
                },
              ),
            ],
          );
        },
      );
    }
  }

 buildGetBark(BuildContext context) {
    return Container(
      height: 40.0,
      width: 100,
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirmación"),
                    content: const Text("¿Realmente quieres salir?"),
                    actions: [
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () {
                          Navigator.of(context).pop(false); // Devuelve "false" si no quieres salir
                        },
                      ),
                      TextButton(
                        child: const Text("Sí"),
                        onPressed: () {
                          Navigator.of(context).pop(true); // Devuelve "true" si quieres salir
                        },
                      ),
                    ],
                  );
                },
              );
      
              if (confirm == true) {
                 Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => const MyHomePage(),
                      ),                   
                    );
              }
            },
             style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(2), // Eliminamos el padding adicional
              backgroundColor: kPsecondaryColor,
            ),
             child: Ink(
              decoration: BoxDecoration(
                gradient: kSecondaryGradient,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0), // Ajustamos el padding
                child: Align(
                  alignment: Alignment.center,
                  child: Text('Salir',style:kTextStyleBlancoNuevaFuente20,), // El texto se centra mejor
                ),
              ),
            ),
          ),
    );
  }
}

