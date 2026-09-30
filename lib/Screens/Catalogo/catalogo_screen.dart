import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/botones.dart';
import 'package:ruitoque/constans.dart';

/// Vitrina de los componentes con el tema de la app, para revisarlos en el teléfono
/// antes de migrar las pantallas. Solo se muestra en modo debug (ver PerfilScreen).
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
          const _Nota('Mantén presionado para ver cómo se hunde y cuadra las esquinas.'),
          BotonApp(texto: 'Iniciar ronda', icono: Icons.golf_course, expandido: true, onPressed: () {}),
          const SizedBox(height: 12),
          BotonApp(
            texto: 'Guardar (simula 1,5 s)',
            icono: Icons.save_rounded,
            expandido: true,
            onPressed: () => Future.delayed(const Duration(milliseconds: 1500)),
          ),
          const SizedBox(height: 12),
          BotonApp(
            texto: 'Guardar con error',
            variante: VarianteBoton.tonal,
            expandido: true,
            onPressed: () async {
              await Future.delayed(const Duration(seconds: 1));
              throw Exception('Simulación de error');
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BotonApp(texto: 'Tonal', variante: VarianteBoton.tonal, onPressed: () {}),
              BotonApp(texto: 'Texto', variante: VarianteBoton.texto, onPressed: () {}),
              BotonApp(texto: 'Eliminar', icono: Icons.delete_outline, variante: VarianteBoton.peligro, onPressed: () {}),
              const BotonApp(texto: 'Deshabilitado', onPressed: null),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BotonApp(texto: 'Cancelar', variante: VarianteBoton.tonal, compacto: true, expandido: true, onPressed: () {}),
              ),
              const SizedBox(width: 12),
              Expanded(child: BotonApp(texto: 'Aceptar', compacto: true, expandido: true, onPressed: () {})),
            ],
          ),
          const SizedBox(height: 16),
          const _Nota('Sobre fondos oscuros, fotos o el mapa:'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: kPrimaryGradientColor, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                BotonApp(texto: 'Continuar', expandido: true, onPressed: () {}),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: BotonApp(
                        texto: 'Tarjetas',
                        icono: Icons.scoreboard_outlined,
                        variante: VarianteBoton.cristal,
                        expandido: true,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BotonApp(
                        texto: 'Mapa',
                        icono: Icons.map_outlined,
                        variante: VarianteBoton.cristal,
                        expandido: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BotonApp(
            texto: 'Ver acción fija abajo',
            variante: VarianteBoton.tonal,
            expandido: true,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _EjemploAccionInferior())),
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

class _Nota extends StatelessWidget {
  final String texto;

  const _Nota(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(texto, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

/// Como quedaría el inicio: fondo oscuro y "Jugar" fijo abajo en la zona del pulgar.
class _EjemploAccionInferior extends StatelessWidget {
  const _EjemploAccionInferior();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MyCustomAppBar(title: 'Golf Colombia', actions: [LogoAppBar()]),
      body: Container(
        decoration: const BoxDecoration(gradient: kFondoGradient),
        child: const SafeArea(
          bottom: false,
          child: Center(
            child: Text('Contenido de la pantalla', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: kPverdeBienOscuto,
        child: BarraAccionInferior(
          child: BotonApp(
            texto: 'Jugar',
            icono: Icons.sports_golf,
            expandido: true,
            onPressed: () => Future.delayed(const Duration(seconds: 1)),
          ),
        ),
      ),
    );
  }
}
