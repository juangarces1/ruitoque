
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
        title: 'Eliga el campo',
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.golf_course_outlined, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Campos disponibles (${campos!.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12, top: 4),
              physics: const BouncingScrollPhysics(),
              itemCount: campos!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final campo = campos![index];
                return CardItemCampo(
                  campo: campo,
                  isSelected: campo.id == campoIdSelected,
                  onTap: () => _setCampoSelect(campo.id),
                );
              },
            ),
          ),
        ],
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
            _SelectorTeeChips(
              campoSeleccionado: campoSeleccionado!,
              teeSeleccionado: teeSeleccionado,
              onChanged: (nuevo) =>
                  setState(() => teeSeleccionado = nuevo),
            ),
            const SizedBox(height: 20),
           _SelectorHandicapPlus(
                porcentaje: handicapPorcentaje,
                enabled: teeSeleccionado != null, // ← desactiva hasta elegir tee
                onChanged: (v) => setState(() => handicapPorcentaje = v),
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

// ──────────────────────────────────────────────────────────────
// NUEVO: Selector de Tee con ChoiceChips y color contextual
// Sustituye _SelectorTee por _SelectorTeeChips en tu _getBody()
// ──────────────────────────────────────────────────────────────
class _SelectorTeeChips extends StatelessWidget {
  final Campo campoSeleccionado;
  final String? teeSeleccionado;
  final ValueChanged<String> onChanged;

  const _SelectorTeeChips({
    required this.campoSeleccionado,
    required this.teeSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Extrae nombres de tees (p. ej. "Azul", "Blanco"...)
    final List<String> tees = campoSeleccionado.tees
        .map((t) => t.color)
        .where((c) => c.toString().trim().isNotEmpty)
        .cast<String>()
        .toList();

    // Asegura valor actual si existe
    final String? current = (teeSeleccionado != null && tees.contains(teeSeleccionado))
        ? teeSeleccionado
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // tarjeta clara para contraste con tu gradiente
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(
                children: [
                  Icon(Icons.emoji_flags_outlined, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Seleccione un tee',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tees.map((name) {
                  final bool selected = name == current;
                  final Color base = _teeColorFromName(name);
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ColorDot(color: base),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.black : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    selected: selected,
                    onSelected: (_) => onChanged(name),
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: base.withOpacity(0.28), // resaltado suave
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: selected ? base : Colors.black26,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    pressElevation: 0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // Ayuda/estado
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: current == null
                    ? const Text(
                        'Tip: elige el tee acorde a tu hándicap o a la distancia que prefieras.',
                        key: ValueKey('hint'),
                        style: TextStyle(color: Colors.black54),
                      )
                    : Row(
                        key: const ValueKey('selected'),
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Tee seleccionado: $current',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Punto de color para el chip
class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26),
      ),
    );
  }
}

// Mapea el nombre del tee a un color aproximado
Color _teeColorFromName(String name) {
  final n = name.toLowerCase().trim();
  if (n.contains('azul')    || n.contains('blue'))   return Colors.blue;
  if (n.contains('blanco')  || n.contains('white'))  return Colors.white;
  if (n.contains('rojo')    || n.contains('red') || n.contains('rojas') )    return Colors.redAccent;
  if (n.contains('amarillo')|| n.contains('yellow')) return Colors.amber;
  if (n.contains('negro')   || n.contains('black'))  return Colors.black87;
  if (n.contains('verde')   || n.contains('green'))  return Colors.green;
  if (n.contains('dorado')  || n.contains('gold'))   return const Color(0xFFFFD54F);
  if (n.contains('naranja') || n.contains('orange')) return Colors.orange;
  if (n.contains('plata')   || n.contains('silver')) return Colors.blueGrey.shade200;
  // fallback morado por si nos tiran un “Arcoíris Pro Max”
  return const Color(0xFF7C4DFF);
}

class _SelectorHandicapPlus extends StatelessWidget {
  final int porcentaje;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _SelectorHandicapPlus({
    required this.porcentaje,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const presets = [50, 75, 85, 90, 95, 100];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Opacity(
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
            border: Border.all(color: Colors.black12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.percent, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        porcentaje == 0
                            ? 'Seleccione porcentaje de hándicap'
                            : 'Porcentaje de hándicap: $porcentaje%',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                   
                    if (!enabled)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Seleccione un tee',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Presets
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((p) {
                    final sel = p == porcentaje;
                    return ChoiceChip(
                      label: Text(
                        '$p%',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.black : Colors.black87,
                        ),
                      ),
                      selected: sel,
                      onSelected: enabled ? (_) => onChanged(p) : null,
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.amber.withOpacity(0.28),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: sel ? Colors.amber : Colors.black26,
                          width: sel ? 2 : 1,
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // Slider con marcas
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    showValueIndicator: ShowValueIndicator.always,
                    activeTrackColor: enabled ? Colors.black : Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: enabled ? Colors.black : Colors.grey,
                    valueIndicatorColor: Colors.black,
                    valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: Slider(
                    value: porcentaje.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20, // cada 5%
                    label: '$porcentaje%',
                    onChanged: enabled
                        ? (double v) => onChanged(v.round())
                        : null,
                  ),
                ),

                // Marcas visuales 0–25–50–75–100
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TickLabel('0%'),
                      _TickLabel('25%'),
                      _TickLabel('50%'),
                      _TickLabel('75%'),
                      _TickLabel('100%'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Ayuda/Tip
                Text(
                  porcentaje == 0
                      ? 'Tip: comunes en juego: 85% (match play), 100% (stroke).'
                      : (porcentaje == 85
                          ? '85%: típico en match play (equilibrado).'
                          : (porcentaje == 100
                              ? '100%: uso completo del hándicap (stroke).'
                              : 'Ajusta según la modalidad del juego.')),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TickLabel extends StatelessWidget {
  final String text;
  const _TickLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black54, fontSize: 12),
    );
  }
}

