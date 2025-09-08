import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/constans.dart';

class JugadoresScreen extends StatefulWidget {
  const JugadoresScreen({super.key});

  @override
  State<JugadoresScreen> createState() => _JugadoresScreenState();
}

class _JugadoresScreenState extends State<JugadoresScreen> {
  final TextEditingController _searchCtr = TextEditingController();
  bool _loading = false;
  List<Jugador> _jugadores = [];
  List<Jugador> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtr.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final Response resp = await ApiHelper.getPlayers();
    setState(() => _loading = false);

    if (!resp.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message)),
        );
      }
      return;
    }

    final List<Jugador> list = List<Jugador>.from(resp.result as List);
    list.sort((a, b) => (a.nombre).toLowerCase().compareTo((b.nombre).toLowerCase()));

    setState(() {
      _jugadores = list;
      _filtered = list;
    });
  }

  void _applyFilter() {
    final q = _searchCtr.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.of(_jugadores));
      return;
    }
    setState(() {
      _filtered = _jugadores
          .where((j) => j.nombre.toLowerCase().contains(q))
          .toList()
        ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    });
  }

  Future<void> _onEdit(Jugador j) async {
    final Jugador? updated = await showModalBottomSheet<Jugador>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _EditJugadorSheet(jugador: j, todos: _jugadores),
    );

    if (updated == null) return;

    final resp = await ApiHelper.put("/api/players/${updated.id}", updated.toJson());

    if (!resp.isSuccess) {
      Fluttertoast.showToast(
        msg: resp.message,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      final idx = _jugadores.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _jugadores[idx] = updated;
      _applyFilter();
    });

    Fluttertoast.showToast(
      msg: 'Jugador actualizado',
      backgroundColor: kPcontrastMoradoColor,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
           leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: kPprimaryColor,
          title: const Text('Jugadores', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refrescar',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                controller: _searchCtr,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  hintText: 'Buscar por nombre...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPprimaryColor),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: kPprimaryColor))
            : RefreshIndicator(
                color: kPprimaryColor,
                onRefresh: _load,
                child: _filtered.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No hay jugadores', style: TextStyle(color: Colors.white70))),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final j = _filtered[i];
                          return _JugadorTile(
                            jugador: j,
                            onEdit: () => _onEdit(j),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}

class _JugadorTile extends StatelessWidget {
  final Jugador jugador;
  final VoidCallback onEdit;

  const _JugadorTile({required this.jugador, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final init = (jugador.nombre.isNotEmpty ? jugador.nombre[0] : '?').toUpperCase();

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPprimaryColor,
          child: Text(init, style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          jugador.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        subtitle: Text(
          'HCP: ${jugador.handicap ?? 0}   •   PIN: ${jugador.pin}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.edit, color: Colors.white70),
        onTap: onEdit,
      ),
    );
  }
}

class _EditJugadorSheet extends StatefulWidget {
  final Jugador jugador;
  final List<Jugador> todos;
  const _EditJugadorSheet({required this.jugador, required this.todos});

  @override
  State<_EditJugadorSheet> createState() => _EditJugadorSheetState();
}

class _EditJugadorSheetState extends State<_EditJugadorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtr;
  late TextEditingController _hcpCtr;
  late TextEditingController _pinCtr;

  @override
  void initState() {
    super.initState();
    _nombreCtr = TextEditingController(text: widget.jugador.nombre);
    _hcpCtr    = TextEditingController(text: (widget.jugador.handicap ?? 0).toString());
    _pinCtr    = TextEditingController(text: widget.jugador.pin.toString());
  }

  @override
  void dispose() {
    _nombreCtr.dispose();
    _hcpCtr.dispose();
    _pinCtr.dispose();
    super.dispose();
  }

  int _rndPin() => 1000 + Random().nextInt(9000);

  void _genPin() {
    _pinCtr.text = _rndPin().toString();
    setState(() {});
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newNombre = _nombreCtr.text.trim();
    final newHcp    = int.parse(_hcpCtr.text.trim());
    final newPin    = int.parse(_pinCtr.text.trim());

    final updated = widget.jugador.copyWithAll(
      nombre: newNombre,
      handicap: newHcp,
      pin: newPin,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 48,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.person, color: kPprimaryColor),
                    SizedBox(width: 8),
                    Text('Editar jugador',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),

                // Nombre
                TextFormField(
                  controller: _nombreCtr,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Nombre'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa un nombre';
                    if (v.trim().length < 2) return 'Muy corto';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Handicap
                TextFormField(
                  controller: _hcpCtr,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Handicap'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa el handicap';
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Valor inválido';
                    if (n < 0 || n > 54) return 'Rango válido: 0–54';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // PIN
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pinCtr,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('PIN (4 dígitos)'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Ingresa el PIN';
                            final n = int.tryParse(v.trim());
                            if (n == null) return 'PIN inválido';
                            if (n < 1000 || n > 9999) return 'Debe ser de 4 dígitos';

                            // 🔒 validación extra: que no exista en otro jugador
                            final exists = widget.todos.any(
                              (other) => other.id != widget.jugador.id && other.pin == n,
                            );
                            if (exists) return 'Este PIN ya está en uso';

                            return null;
                          },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _genPin,
                      icon: const Icon(Icons.casino),
                      label: const Text('Generar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPprimaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPprimaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPprimaryColor),
      ),
    );
  }
}

extension JugadorCopyAll on Jugador {
  Jugador copyWithAll({
    int? id,
    int? handicap,
    String? nombre,
    int? pin,
    List<Tarjeta>? tarjetas,
  }) {
    return Jugador(
      id: id ?? this.id,
      handicap: handicap ?? this.handicap,
      nombre: nombre ?? this.nombre,
      pin: pin ?? this.pin,
      tarjetas: tarjetas ?? this.tarjetas,
    );
  }
}
