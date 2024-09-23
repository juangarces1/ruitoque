import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Preferences/jugadorpreferences.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
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

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return  SafeArea(      
        child: Material(
          child: Stack(
            children: [
              Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                     
                        const Text(
                        'Bienvenido',
                        textAlign: TextAlign.center,
                        style: kTextStyleBlancoNuevaFuente
                      ),
                       const SizedBox(height: 10.0),
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
                   
                       DefaultButton(
                          text: const Text('Ingresar', style: kTextStyleBlancoNuevaFuente20, textAlign: TextAlign.center ,),
                          press: () => goLogIn(),
                          gradient: kSecondaryGradient,
                          color: kPrimaryColor,
                          
                          ),
                    ],
                  ),
                ),
              ),
              _showLoader ? const Center(child: CircularProgressIndicator()) : Container(),
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
        style:  const TextStyle(color: Colors.white ),  
        obscureText: !_passwordShow,
        
        decoration: InputDecoration(
           labelStyle: const TextStyle(color: Colors.white ),
          hintStyle: const TextStyle(color: Colors.white ),
          errorStyle: const TextStyle(color: Colors.white ),
          suffixStyle:  const TextStyle(color: Colors.white ),
          hintText: 'Ingresa tu Pin...',
          labelText: 'Pin',
          errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: const Icon(Icons.lock,  color: Colors.white,),
          suffixIcon: IconButton(
            icon: _passwordShow ? const Icon(Icons.visibility,  color: Colors.white,) : const Icon(Icons.visibility_off,  color: Colors.white,),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            }, 
          ),
           enabledBorder:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), 
              borderSide: const BorderSide(color: Colors.white, width: 1.0),
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
        title: const Text('Recuerdame', style:  TextStyle(color: Colors.white ),),
        value: _rememberme,
        onChanged: (value) {  
          setState(() {
            _rememberme = value!;
          });
        }, 
      ),
    );
  }

  goHome(){
     Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) =>  const MyHomePage()
      )
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

  Future<void> goLogIn() async {
   if(!_validateFields()) {
      return;
    }

     setState(() {
      _showLoader = true;
    });
     

  
    
    Response response = await ApiHelper.logIn(_password);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
        if (mounted) {       
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content:  const Text('Pin Incorrecto'),
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
     
    if (mounted){
       Provider.of<JugadorProvider>(context, listen: false).setJugador(response.result);

    }
   
    

   
    if (_rememberme) {
     await JugadorPreferences.guardarJugador(response.result, true);
    }

    
    goHome();

  }
}