import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_item_campo.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Screens/Ronda/select_players_sceen.dart';
import 'package:ruitoque/constans.dart';

class SelectCampoScreen extends StatefulWidget {
  const SelectCampoScreen({Key? key}) : super(key: key);

  @override
  State<SelectCampoScreen> createState() => _SelectCampoScreenState();
}

class _SelectCampoScreenState extends State<SelectCampoScreen> {
  bool showLoader = false;
  List<Campo>? campos = [];
  int campoIdSelected = 0;
  Campo? campoSeleccionado;
  String? teeSeleccionado;
  int handicapPorcentaje = 0;

  @override
  void initState() {
    super.initState();
    getCampos();
  }

  Future<void> getCampos() async {
    setState(() => showLoader = true);

    Response response = await ApiHelper.getCampos();

    setState(() => showLoader = false);

    if (!response.isSuccess) {
      if (mounted) {
        _showError(response.message);
      }
      return;
    }

    setState(() {
      campos = response.result;
      teeSeleccionado = null;
    });
  }

  Future<void> getCampoSeleccionado(int id) async {
    setState(() => showLoader = true);

    Response response = await ApiHelper.getCampo(id.toString());

    setState(() => showLoader = false);

    if (!response.isSuccess) {
      if (mounted) {
        _showError(response.message);
      }
      return;
    }

    setState(() {
      campoSeleccionado = response.result;
      teeSeleccionado = null;
      handicapPorcentaje = 0;
    });
  }

  void _setCampoSelect(int id) {
    setState(() {
      campoIdSelected = id;
      campoSeleccionado = null; // Mientras carga
    });
    getCampoSeleccionado(campoIdSelected);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(context),
          ),
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
        elevation: 4.0,
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
        decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
        child: Center(
          child: showLoader
              ? const MyLoader(opacity: 0.8, text: 'Cargando...')
              : _getContent(),
        ),
      ),
    );
  }

  Widget _getContent() {
    if (campos == null || campos!.isEmpty) {
      return _noContent();
    } else {
      return _getBody();
    }
  }

  Widget _noContent() {
    return const Center(
      child: Text(
        'No hay Campos.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getBody() {
    if (campoSeleccionado == null) {
      // Lista completa para seleccionar
      return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: campos!.length,
        itemBuilder: (context, index) {
          Campo campo = campos![index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: CardItemCampo(
              campo: campo,
              isSelected: campo.id == campoIdSelected,
              onTap: () => _setCampoSelect(campo.id),
            ),
          );
        },
      );
    } else {
      // Mostrar solo el campo seleccionado
      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: CardItemCampo(
                campo: campoSeleccionado!,
                isSelected: true,
                onTap: () {},
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  campoSeleccionado = null;
                  campoIdSelected = 0;
                  teeSeleccionado = null;
                  handicapPorcentaje = 0;
                });
              },
              icon: const Icon(Icons.list_alt, color: Colors.white),
              label: const Text(
                "Ver todos los campos",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _SelectorTee(
              campoSeleccionado: campoSeleccionado!,
              teeSeleccionado: teeSeleccionado,
              onChanged: (nuevo) =>
                  setState(() => teeSeleccionado = nuevo),
            ),
            const SizedBox(height: 20),
            _SelectorHandicap(
              porcentaje: handicapPorcentaje,
              onChanged: (nuevo) =>
                  setState(() => handicapPorcentaje = nuevo),
            ),
            const SizedBox(height: 20),
            DefaultButton(
              text: const Text(
                'Siguiente',
                style: kTextStyleBlancoNuevaFuente20,
                textAlign: TextAlign.center,
              ),
              press: _validarYContinuar,
              gradient: kPrimaryGradientColor,
              color: kPsecondaryColor,
            ),
          ],
        ),
      );
    }
  }

  void _validarYContinuar() {
    if (teeSeleccionado == null && handicapPorcentaje == 0) {
      _toastError("Seleccione un tee y el porcentaje de handicap.");
    } else if (teeSeleccionado == null) {
      _toastError("Seleccione un tee para continuar.");
    } else if (handicapPorcentaje == 0) {
      _toastError("Seleccione el porcentaje de handicap.");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectPlayersScreen(
            porcentajeHandicap: handicapPorcentaje,
            campoSeleccionado: campoSeleccionado!,
            teeSeleccionado: teeSeleccionado!,
          ),
        ),
      );
    }
  }

  void _toastError(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.red[700],
      textColor: Colors.white,
      gravity: ToastGravity.CENTER,
      fontSize: 16,
    );
  }
}

class _SelectorTee extends StatelessWidget {
  final Campo campoSeleccionado;
  final String? teeSeleccionado;
  final ValueChanged<String> onChanged;

  const _SelectorTee({
    required this.campoSeleccionado,
    required this.teeSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tees = campoSeleccionado.tees.map((t) => t.color).toList();
    final currentValue =
        teeSeleccionado != null && tees.contains(teeSeleccionado)
            ? teeSeleccionado
            : null;

    return Padding(
      padding:
          const EdgeInsets.only(top: 10, left: 22, right: 22, bottom: 2),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        hint: const Text("Seleccione un tee..."),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w600),
        items: tees
            .map((color) => DropdownMenuItem<String>(
                  value: color,
                  child: Text(color),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _SelectorHandicap extends StatelessWidget {
  final int porcentaje;
  final ValueChanged<int> onChanged;

  const _SelectorHandicap({
    required this.porcentaje,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          Center(
            child: Text(
              porcentaje == 0
                  ? 'Seleccione porcentaje de Handicap'
                  : 'Porcentaje de Handicap: $porcentaje%',
              style: kTextStyleBlancoNuevaFuente20,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: Slider(
              value: porcentaje.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: porcentaje == 0 ? "Seleccione %" : "$porcentaje%",
              activeColor: porcentaje > 0 ? Colors.black : Colors.grey,
              inactiveColor: Colors.grey[300],
              onChanged: (double value) {
                onChanged(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}
