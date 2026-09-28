import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';

/// Vitrina de los componentes con el tema de la app, para revisarlos en el teléfono
/// antes de migrar las pantallas. Solo se muestra en modo debug (ver GolfDrawer).
class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyCustomAppBar(
        title: 'Catálogo',
        subtitle: 'Componentes de la app',
        actions: [LogoAppBar()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          const _Seccion('App bar'),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _EjemploAppBar()),
            ),
            child: const Text('Ver pantalla de ejemplo'),
          ),
          const _Seccion('Botones'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Guardar')),
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              OutlinedButton(onPressed: () {}, child: const Text('Cancelar')),
              TextButton(onPressed: () {}, child: const Text('Ver más')),
              const ElevatedButton(onPressed: null, child: Text('Deshabilitado')),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.golf_course),
                label: const Text('Iniciar ronda'),
              ),
            ],
          ),
          const _Seccion('Diálogos y avisos'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(onPressed: () => _dialogoError(context), child: const Text('Error')),
              OutlinedButton(onPressed: () => _dialogoConfirmar(context), child: const Text('Confirmar')),
              OutlinedButton(onPressed: () => _aviso(context), child: const Text('SnackBar')),
              OutlinedButton(onPressed: () => _hoja(context), child: const Text('Bottom sheet')),
            ],
          ),
          const _Seccion('Campos de texto'),
          const TextField(decoration: InputDecoration(labelText: 'Nombre', hintText: 'Ej. Juank')),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'PIN',
              prefixIcon: Icon(Icons.lock),
              errorText: 'PIN incorrecto',
            ),
          ),
          const _Seccion('Tarjetas y chips'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.flag),
              title: Text('Hoyo 1 · Par 5'),
              subtitle: Text('502 yardas · Hándicap 3'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              const Chip(label: Text('Blanco')),
              FilterChip(label: const Text('Azul'), selected: true, onSelected: (_) {}),
              ChoiceChip(label: const Text('Rojo'), selected: false, onSelected: (_) {}),
            ],
          ),
          const _Seccion('Progreso'),
          const LinearProgressIndicator(value: 0.6),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _dialogoError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('No hay conexión con el servidor. Revisa tu internet e intenta de nuevo.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar'))],
      ),
    );
  }

  void _dialogoConfirmar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ronda'),
        content: const Text('¿Seguro que quieres eliminar esta ronda? No se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Eliminar')),
        ],
      ),
    );
  }

  void _aviso(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ronda guardada'),
        action: SnackBarAction(label: 'Deshacer', onPressed: () {}),
      ),
    );
  }

  void _hoja(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Text('Contenido de una hoja inferior'),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;

  const _Seccion(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(titulo, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

/// Pantalla de muestra: barra sin subtítulo, con pestañas (bottom) y lista debajo.
class _EjemploAppBar extends StatelessWidget {
  const _EjemploAppBar();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const MyCustomAppBar(
          title: 'Mis Tarjetas',
          actions: [LogoAppBar()],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Recientes'), Tab(text: 'Mejores')],
          ),
        ),
        body: ListView.builder(
          itemCount: 12,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.scoreboard_outlined),
            title: Text('Tarjeta ${i + 1}'),
            subtitle: const Text('Los Sueños Marriot · 25 jul 2026'),
          ),
        ),
      ),
    );
  }
}
