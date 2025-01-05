import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_item_campo.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Ronda/select_players_sceen.dart';

import 'package:ruitoque/constans.dart';

class SelectCampoScreen extends StatefulWidget {
  const SelectCampoScreen({Key? key}) : super(key: key);

  @override
  SelectCampoScreenState createState() => SelectCampoScreenState();
}

class SelectCampoScreenState extends State<SelectCampoScreen> {
  bool showLoader = false;
  List<Campo>? campos = [];
  int campoIdSelected = 0;
  String _seleccionado = '';
  late Campo campoSeleccionado;
  bool _isCampoSeleccionadoInitialized = false;
  int handicapPorcentaje = 0;

  @override
  void initState() {
    super.initState();
    getCampos();
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
      return;
    }

    setState(() {
      campos = response.result;
    });
  }

  Future<void> getCampoSeleccionado(int id) async {
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
      return;
    }

    setState(() {
      campoSeleccionado = response.result;
      _seleccionado = campoSeleccionado.tees[0].color;
      _isCampoSeleccionadoInitialized = true;
    });
  }

  void _setCampoSelect(int id) {
    setState(() {
      campoIdSelected = id;
    });
    getCampoSeleccionado(campoIdSelected);
  }

  void mostrarSnackBar(BuildContext context, String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _noContent() {
    return Center(
      child: Container(
        decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
        margin: const EdgeInsets.all(20),
        child: const Text(
          'No hay Campos.',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getContent() {
    return campos!.isEmpty ? _noContent() : _getBody();
  }

  Widget _getBody() {
    return Container(
      decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: ListView.builder(
                itemCount: campos!.length,
                itemBuilder: (context, index) {
                  Campo campo = campos![index];
                  return CardItemCampo(
                      campo: campo,
                      onTap: () => _setCampoSelect(campo.id));
                },
              ),
            ),
          ),
          if (_isCampoSeleccionadoInitialized) ...[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Tee de Salida:',
                  style: kTextStyleBlancoNuevaFuente20,
                ),
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
                      _seleccionado =
                          campoSeleccionado.tees[index].color;
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
            //crea un campo control para el porcentaje de handicap que sea algo mas facil de manejar que un textbox 
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Porcentaje de Handicap:',
                  style: kTextStyleBlancoNuevaFuente20,
                ),
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
                  handicapPorcentaje = 100 - (index * 5);
                });
                },
                children: List<Widget>.generate(21, (int index) {
                return Center(
                  child: Text('${100 - (index * 5)}%'),
                );
                }),
              ),
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: DefaultButton(
                text: const Text(
                  'Siguiente',
                  style: kTextStyleBlancoNuevaFuente20,
                  textAlign: TextAlign.center,
                ),
                press: () {
                  if(handicapPorcentaje == 0){
                    mostrarSnackBar(context, 'Por favor, seleccione el porcentaje de Handicap.');
                    return;
                  }
                  if (_isCampoSeleccionadoInitialized) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectPlayersScreen(
                          porcentajeHandicap: handicapPorcentaje,
                          campoSeleccionado: campoSeleccionado,
                          teeSeleccionado: _seleccionado,
                        ),
                      ),
                    );
                  } else {
                    mostrarSnackBar(
                        context, 'Por favor, seleccione Campo y Tee.');
                  }
                },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title: 'Iniciar Ronda',
        automaticallyImplyLeading: true,
        backgroundColor: kPprimaryColor,
        elevation: 8.0,
        shadowColor: const Color.fromARGB(255, 2, 44, 68),
        foreColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipOval(
              child: Image.asset(
                'assets/LogoGolf.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kFondoGradient),
        child: Center(
          child: showLoader
              ? const MyLoader(
                  opacity: 0.8,
                  text: 'Cargando...',
                )
              : _getContent(),
        ),
      ),
    );
  }
}
