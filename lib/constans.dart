
import 'package:flutter/material.dart';
import 'package:ruitoque/sizeconfig.dart';

const kAlvatrosColor = Color.fromARGB(255, 208, 180, 27);
const kBerdieColor = Colors.red;
const kBogeyColor = Colors.blue;
const kEagleColor = Colors.green;
const kDoubleBogueColor = Colors.deepPurple;

const Color kAmarilloColombia = Color.fromARGB(255, 252, 209, 22);
const kPprimaryColor =Color.fromRGBO(54, 118, 100,1);
const kPsecondaryColor = Color(0xFF363b76);
const kPcontrastAzulColor = Color(0xFF363b76);
const kPcontrastMoradoColor = Color(0xFF443676);
const kPmarronConstrats = Color(0xFF764a36);
const kPverdeMasClaro = Color(0xFF5dcbac);
const kPverdeBienOscuto = Color(0xFF0f211c);
const kPOcre = Color(0xFF763648);
const kPVerdeMedio = Color(0xFF2b5e50);


const kTextColorBlanco = Color(0xFFF5F5F5);
const kAzulCielo =Color(0xFF81D4FA);
const kOroMetalico = Color.fromARGB(174, 135, 118, 25);

const kAzulBanderaColombia = Color(0xFF0033A0);
const kRojoBanderaColombia = Color(0xFFCE1126);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kTextColorBlack = Colors.black87;
const kTextColorWhite= Color.fromARGB(204, 236, 231, 231);
const kColorMenu= Color.fromARGB(251, 251, 245, 245);


const kTextStyleBlancoNuevaFuente = TextStyle(
                      fontFamily: 'RobotoCondensed',
                      // Puedes especificar el peso y el estilo si es necesario
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,
                       // Para un estilo en negrita
                       // Para un estilo en cursiva
                    );

const kTextStyleBlancoNuevaFuente20 = TextStyle(
  fontFamily: 'RobotoCondensed',
  // Puedes especificar el peso y el estilo si es necesario
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: Colors.white,
    // Para un estilo en negrita
    // Para un estilo en cursiva
);

const kTextStyleNegroRobotoSize20 = TextStyle(
  fontFamily: 'RobotoCondensed', 
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: Colors.black,  
);

const kTextStyleNegroRobotoSize20Normal = TextStyle(
  fontFamily: 'RobotoCondensed',
  // Puedes especificar el peso y el estilo si es necesario
  fontWeight: FontWeight.normal,
  fontSize: 20,
  color: Colors.black,
    // Para un estilo en negrita
    // Para un estilo en cursiva
);

const kTextStyleBlancoRobotoSize20Normal = TextStyle(
  fontFamily: 'RobotoCondensed',
  // Puedes especificar el peso y el estilo si es necesario
  fontWeight: FontWeight.normal,
  fontSize: 20,
  color: Colors.white,
    // Para un estilo en negrita
    // Para un estilo en cursiva
);

const kGradientHome = LinearGradient(colors: [kPprimaryColor, kPcontrastMoradoColor ]);
const kGradientHomeReverse = LinearGradient(colors: [kPcontrastMoradoColor, kPprimaryColor ]);
const kGradiantBandera = LinearGradient(
  colors: [    
    kAzulBanderaColombia, 
     kRojoBanderaColombia,
    kAmarilloColombia,
  ],
  stops: [
    0.4,  // El primer color ocupa el 50% del gradiente
    0.6, // El segundo color comienza desde el 50% hasta el 75%
    1.0,  // El tercer color ocupa del 75% al 100%
  ],
  begin: Alignment.topLeft,  // Punto de inicio del gradiente
  end: Alignment.bottomRight, // Punto final del gradiente
);

const kFondoGradient = LinearGradient(
              colors:[kPverdeBienOscuto ,kPprimaryColor, ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

const LinearGradient kPrimaryGradientColor = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  colors: [kPprimaryColor, kPcontrastMoradoColor],
);
const LinearGradient kSecondaryGradient =  LinearGradient(
                 colors: [kPcontrastMoradoColor, kPOcre],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );



const kBlueColorLogo =Color(0xFF175fb1);
const inActiveIconColor =  Color(0xFFB6B6B6);
const kColorFondoOscuro = Color.fromARGB(255, 70, 72, 77);
const kContrateFondoOscuro = Color.fromARGB(255, 22, 49, 77);
const kPrimaryText = Color(0xFFFF7643);

const kAnimationDuration = Duration(milliseconds: 200);

final myHeadingStyleBlack = TextStyle(
  fontSize: getProportionateScreenWidth(22),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

final myHeadingStylePrymary = TextStyle(
  fontSize: getProportionateScreenWidth(22),
  fontWeight: FontWeight.bold,
  color: kPprimaryColor,
  height: 1.5,
);

final mySubHeadingStyleWhite = TextStyle(
  fontSize: getProportionateScreenWidth(20),
  fontWeight: FontWeight.bold,
  color: Colors.white,
  height: 1.5,
);

final mySubHeadingStyleBlacb = TextStyle(
  fontSize: getProportionateScreenWidth(18),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

final myEnfasisBlack = TextStyle(
  fontSize: getProportionateScreenWidth(16),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

final headingStyleKprimary = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: kPprimaryColor,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

final otpInputDecoration = InputDecoration(
  contentPadding:
      const EdgeInsets.all(30),
  border: outlineInputBorderColor(),
  focusedBorder: outlineInputBorderColor(),
  enabledBorder: outlineInputBorderColor(),
);



OutlineInputBorder outlineInputBorderColor() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: const BorderSide(color: kPprimaryColor),
  );
}