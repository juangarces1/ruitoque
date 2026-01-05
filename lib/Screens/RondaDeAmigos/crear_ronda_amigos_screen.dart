import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:ruitoque/Models/ronda_de_amigos.dart';
import 'package:ruitoque/Screens/RondaDeAmigos/crear_grupos_screen.dart';
import 'package:ruitoque/constans.dart';

class CrearRondaDeAmigosScreen extends StatefulWidget {
  const CrearRondaDeAmigosScreen({Key? key}) : super(key: key);

  @override
  State<CrearRondaDeAmigosScreen> createState() => _CrearRondaDeAmigosScreenState();
}

class _CrearRondaDeAmigosScreenState extends State<CrearRondaDeAmigosScreen> {
  bool showLoader = false;
  List<Campo>? campos = [];
  int campoIdSelected = 0;
  Campo? campoSeleccionado;
  String? teeSeleccionado;
  int handicapPorcentaje = 0;

  final TextEditingController _nombreController = TextEditingController();
  DateTime fechaSeleccionada = DateTime.now();
  late Jugador jugador;

  @override
  void initState() {
    super.initState();
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
    getCampos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
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
      campoSeleccionado = null;
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

  Future<void> _selectFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != fechaSeleccionada) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title: 'Crear Ronda de Amigos',
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
        'No hay Campos disponibles.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre del evento
            _buildNombreSection(),
            const SizedBox(height: 16),

            // Fecha
            _buildFechaSection(),
            const SizedBox(height: 16),

            // Selección de campo
            _buildCampoSection(),

            // Si hay campo seleccionado, mostrar tee y handicap
            if (campoSeleccionado != null) ...[
              const SizedBox(height: 16),
              _buildTeeSection(),
              const SizedBox(height: 16),
              _buildHandicapSection(),
              const SizedBox(height: 24),
              _buildContinuarButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNombreSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.group, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Nombre del evento',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                hintText: 'Ej: Sábado con los parceros',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechaSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Fecha del evento',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectFecha,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.golf_course, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  campoSeleccionado == null
                      ? 'Seleccione el campo'
                      : 'Campo seleccionado',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (campoSeleccionado == null)
              SizedBox(
                height: 200,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: campos!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final campo = campos![index];
                    return CardItemCampo(
                      campo: campo,
                      isSelected: campo.id == campoIdSelected,
                      onTap: () => _setCampoSelect(campo.id),
                    );
                  },
                ),
              )
            else
              Column(
                children: [
                  CardItemCampo(
                    campo: campoSeleccionado!,
                    isSelected: true,
                    onTap: () {},
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
                    icon: const Icon(Icons.change_circle, color: kPprimaryColor),
                    label: const Text(
                      "Cambiar campo",
                      style: TextStyle(
                        color: kPprimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeeSection() {
    final List<String> tees = campoSeleccionado!.tees
        .map((t) => t.color)
        .where((c) => c.toString().trim().isNotEmpty)
        .cast<String>()
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_flags, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Tee de salida',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tees.map((name) {
                final bool selected = name == teeSeleccionado;
                final Color base = _teeColorFromName(name);
                return ChoiceChip(
                  label: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.black : Colors.black87,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() => teeSeleccionado = name),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: base.withOpacity(0.28),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selected ? base : Colors.black26,
                      width: selected ? 2 : 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandicapSection() {
    const presets = [50, 75, 85, 90, 95, 100];
    final bool enabled = teeSeleccionado != null;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.percent, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    handicapPorcentaje == 0
                        ? 'Porcentaje de handicap'
                        : 'Handicap: $handicapPorcentaje%',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((p) {
                  final sel = p == handicapPorcentaje;
                  return ChoiceChip(
                    label: Text(
                      '$p%',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.black : Colors.black87,
                      ),
                    ),
                    selected: sel,
                    onSelected: enabled ? (_) => setState(() => handicapPorcentaje = p) : null,
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.amber.withOpacity(0.28),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: sel ? Colors.amber : Colors.black26,
                        width: sel ? 2 : 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (!enabled)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Seleccione un tee primero',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinuarButton() {
    return DefaultButton(
      text: const Text(
        'Crear Grupos',
        style: kTextStyleBlancoNuevaFuente20,
        textAlign: TextAlign.center,
      ),
      press: _validarYContinuar,
      gradient: kPrimaryGradientColor,
      color: kPsecondaryColor,
    );
  }

  void _validarYContinuar() {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      _toastError("Ingrese un nombre para el evento.");
      return;
    }

    if (teeSeleccionado == null) {
      _toastError("Seleccione un tee.");
      return;
    }

    if (handicapPorcentaje == 0) {
      _toastError("Seleccione el porcentaje de handicap.");
      return;
    }

    // Crear objeto RondaDeAmigos parcial
    final rondaDeAmigos = RondaDeAmigos(
      id: 0,
      nombre: nombre,
      fecha: fechaSeleccionada,
      creatorId: jugador.id,
      campoId: campoSeleccionado!.id,
      campo: campoSeleccionado,
      teeSeleccionado: teeSeleccionado!,
      handicapPorcentaje: handicapPorcentaje,
      rondas: [],
      isComplete: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearGruposScreen(
          rondaDeAmigos: rondaDeAmigos,
        ),
      ),
    );
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

  Color _teeColorFromName(String name) {
    final n = name.toLowerCase().trim();
    if (n.contains('azul') || n.contains('blue')) return Colors.blue;
    if (n.contains('blanco') || n.contains('white')) return Colors.grey;
    if (n.contains('rojo') || n.contains('red') || n.contains('rojas')) return Colors.redAccent;
    if (n.contains('amarillo') || n.contains('yellow')) return Colors.amber;
    if (n.contains('negro') || n.contains('black')) return Colors.black87;
    if (n.contains('verde') || n.contains('green')) return Colors.green;
    return const Color(0xFF7C4DFF);
  }
}
