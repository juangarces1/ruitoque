import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/Providers/cordenada_provider.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Screens/Campos/Components/input_decoration.dart';
import 'package:ruitoque/constans.dart';


class CrearCordenadaScreen extends StatefulWidget {
  final Cordenada? cordenada;
 
  const CrearCordenadaScreen({super.key, this.cordenada, });

  @override
  CrearCordenadaScreenState createState() => CrearCordenadaScreenState();
}

class CrearCordenadaScreenState extends State<CrearCordenadaScreen> {
  final _formKey = GlobalKey<FormState>();
  Cordenada cordenadaActual = Cordenada(id: 0, latitud: 0, longitud: 0);

  // Controladores para los TextFormFields
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  

  @override
  void initState() {
    super.initState();
    
    // Inicializar cordenadaActual con los valores pasados o con valores predeterminados
    cordenadaActual = widget.cordenada ?? Cordenada(id: 0, latitud: 0, longitud: 0);
    
    // Inicializar controladores con los valores actuales
    _latitudController = TextEditingController(text: cordenadaActual.latitud.toString());
    _longitudController = TextEditingController(text: cordenadaActual.longitud.toString());
  }

  // Función para manejar el cambio en los campos de texto
  void _onChanged(String value, String name) {
    setState(() {
      switch (name) {
        case 'latitud':
          double? latitudValue = double.tryParse(value);
          if (latitudValue != null) {
            cordenadaActual.latitud = latitudValue;
          }
          break;
        case 'longitud':
          double? longitudValue = double.tryParse(value);
          if (longitudValue != null && longitudValue >= -180 && longitudValue <= 180) {
            cordenadaActual.longitud = longitudValue;
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CordenadaProvider cordenadaProvider = Provider.of<CordenadaProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MyCustomAppBar(
          title: 'Crear Coordenada Inicial',
          automaticallyImplyLeading: true,
          backgroundColor: kPprimaryColor,
           elevation: 4.5,
          shadowColor: Colors.red,
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              const SizedBox(height: 20,),
           
              TextFormField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                keyboardType: TextInputType.number,
                controller: _latitudController,
                decoration:  buildInputDecoration('Latitud'),
                onChanged: (value) => _onChanged(value, 'latitud'),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                  style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                 keyboardType: TextInputType.number,
                controller: _longitudController,
                decoration:  buildInputDecoration('Longitud'),
                onChanged: (value) => _onChanged(value, 'longitud'),
              ),
                const SizedBox(height: 10,),
               Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: ElevatedButton(
                  onPressed:  () => _goBack(cordenadaProvider),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPprimaryColor, // Color de fondo del botón
                    foregroundColor: Colors.white, // Color del texto y iconos del botón
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ), // Estilo del texto
                  ),
                   child: const Text('Guardar'),
                ),
            ),  

                  const SizedBox(height: 10,),
               Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: ElevatedButton(
                  onPressed:  () {
                      setState(() {
                         _latitudController.text =cordenadaProvider.cordenada.latitud.toString();
                          _longitudController.text =cordenadaProvider.cordenada.longitud.toString();
                      });
  
                     

                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPprimaryColor, // Color de fondo del botón
                    foregroundColor: Colors.white, // Color del texto y iconos del botón
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ), // Estilo del texto
                  ),
                   child: const Text('Mostrar Coordenada'),
                ),
            ),  
             
             
            ],
          ),
        ),
      ),
    );
  }

  void _goBack(CordenadaProvider cordenadaProvider) {
    if (_formKey.currentState!.validate()) {      
      cordenadaProvider.actualizarCordenada(cordenadaActual.latitud, cordenadaActual.longitud);
      Navigator.pop(context); // Cerrar pantalla después de guardar
    }
  }

 

  @override
  void dispose() {
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }
}
