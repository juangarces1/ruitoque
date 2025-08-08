import 'package:flutter/material.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/campo.dart';

import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/constans.dart';

class CreateTorneoScreen extends StatefulWidget {
  const CreateTorneoScreen({Key? key}) : super(key: key);

  @override
  State<CreateTorneoScreen> createState() => _CreateTorneoScreenState();
}

class _CreateTorneoScreenState extends State<CreateTorneoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final TextEditingController _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  Campo? _selectedCampo;
  List<Campo> _campos = [];

  @override
  void initState() {
    super.initState();
    _fetchCampos();
  }

  Future<void> _fetchCampos() async {
    setState(() => _loading = true);
    final resp = await ApiHelper.getCampos();
    if (resp.isSuccess) {
      setState(() {
        _campos = (resp.result as List).map((j) => Campo.fromJson(j)).toList();
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedCampo == null || _startDate == null || _endDate == null) {
      // show error
      return;
    }
    // Navegar a asignación de rondas
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     // builder: (_) => AssignRoundsScreen(
    //     //   nombre: _nameController.text,
    //     //   campo: _selectedCampo!,
    //     //   fechaInicio: _startDate!,
    //     //   fechaFin: _endDate!,
    //     // ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const MyCustomAppBar(
          title: 'Crear Torneo',
          backgroundColor: kPprimaryColor,
          foreColor: Colors.white,
          automaticallyImplyLeading: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del torneo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Campo>(
                      decoration: const InputDecoration(
                        labelText: 'Campo',
                        border: OutlineInputBorder(),
                      ),
                      items: _campos.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.nombre),
                        );
                      }).toList(),
                      onChanged: (c) => setState(() => _selectedCampo = c),
                      validator: (_) => _selectedCampo == null ? 'Selecciona un campo' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isStart: true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha inicio',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _startDate == null
                                    ? 'Seleccionar'
                                    : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _startDate == null ? null : () => _pickDate(isStart: false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha fin',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _endDate == null
                                    ? 'Seleccionar'
                                    : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: kPcontrastMoradoColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Siguiente: Rondas', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading) const Center(child: MyLoader(text: 'Cargando campos...', opacity: 0.8)),
          ],
        ),
      ),
    );
  }
}
