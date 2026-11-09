import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/botones.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _password = '';
   String _passwordError = '';
   bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordShow = false;


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return  SafeArea(      
        child: Material(
          child: Stack(
            children: [
              Container(                
                decoration: const BoxDecoration(
                       image: DecorationImage(
                        image: AssetImage('assets/Fondo.png'),
                        fit: BoxFit.fill, // Ajusta la imagen para que cubra el área de 4:3
                      ),),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                     
                  SizedBox(
                      width: 150.0, // Ajusta el ancho según tus necesidades
                      height: 150.0, // Ajusta la altura según tus necesidades
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0), // Ajusta el radio según tus necesidades
                        child: Image.asset(
                          'assets/LogoGolf.png',
                          fit: BoxFit.cover, // Ajusta esto para asegurarte de que la imagen llena el contenedor
                        ),
                      ),
                    ),
                
                      const SizedBox(height: 40.0),
                     _showPassword(),
                     _showRememberme(),
                      const SizedBox(height: 40.0),
                   
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        // El botón muestra la carga mientras se valida el PIN.
                        child: BotonApp(
                          texto: 'Ingresar',
                          icono: Icons.login_rounded,
                          expandido: true,
                          onPressed: goLogIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

   Widget _showPassword() {
    return Container(
     padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: TextField(
        keyboardType: TextInputType.number,
        obscureText: !_passwordShow,
        
        decoration: InputDecoration(
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
    
            ),
        
                    filled: true, // Habilita el color de fondo
        fillColor: Colors.white, // Establece el color de fondo a blanco
          hintText: 'Ingresa tu Pin...',
        
          errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: const Icon(Icons.lock,  color: Colors.black,),
          suffixIcon: IconButton(
            icon: _passwordShow ? const Icon(Icons.visibility,  color: Colors.black,) : const Icon(Icons.visibility_off,  color: Colors.black,),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            }, 
          ),
         
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRememberme() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 5),
      child: CheckboxListTile(
        title:   Text('Recuerdame', style: mySubHeadingStyleWhite ),
        value: _rememberme,
        onChanged: (value) {  
          setState(() {
            _rememberme = value!;
          });
        }, 
      ),
    );
  }

   bool _validateFields() {
    bool isValid = true;

  

    if (_password.isEmpty) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu Pin.';
    }  else {
      _passwordShowError = false;
    }

    setState(() { });
    return isValid;
  }

  /// Devuelve si se pudo ingresar (el botón muestra ✓ solo en ese caso).
  Future<bool> goLogIn() async {
    FocusScope.of(context).unfocus();
    if (!_validateFields()) return false;

    Response response = await ApiHelper.logIn(_password);
    if (!mounted) return false;

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
        }  
       return false;
     }
     
    if (!mounted) return false;
    // No se navega desde aquí: main.dart muestra el inicio en cuanto hay jugador.
    // (Navegar además dejaba el inicio abierto dos veces.) Solo se recuerda la
    // sesión si el usuario marcó "Recuérdame".
    await Provider.of<JugadorProvider>(context, listen: false)
        .setJugador(response.result, isRemembered: _rememberme);
    return true;
  }
}