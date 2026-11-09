import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/botones.dart';
import 'package:ruitoque/Helpers/osm_golf.dart';
import 'package:ruitoque/Screens/Campos/add_course_screen.dart';

/// Busca un campo en OpenStreetMap y lo abre en el editor como borrador.
///
/// Devuelve `true` al cerrarse si se guardó un campo.
class BuscarCampoOsmScreen extends StatefulWidget {
  /// Configurables para tests; por defecto consultan OpenStreetMap.
  final Future<List<CampoOsm>> Function(String texto) buscar;
  final Future<BorradorCampo> Function(CampoOsm campo) importar;

  const BuscarCampoOsmScreen({
    super.key,
    this.buscar = buscarCamposOsm,
    this.importar = importarCampoOsm,
  });

  @override
  State<BuscarCampoOsmScreen> createState() => _BuscarCampoOsmScreenState();
}

class _BuscarCampoOsmScreenState extends State<BuscarCampoOsmScreen> {
  final _texto = TextEditingController();

  bool _buscando = false;
  String? _error;

  /// Null hasta la primera búsqueda.
  List<CampoOsm>? _resultados;

  /// Campo cuyo detalle se está descargando.
  CampoOsm? _descargando;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final texto = _texto.text.trim();
    if (texto.length < 3 || _buscando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _buscando = true;
      _error = null;
    });
    try {
      final campos = await widget.buscar(texto);
      if (!mounted) return;
      setState(() => _resultados = campos);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo consultar OpenStreetMap. Revisa la conexión e intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _elegir(CampoOsm campo) async {
    if (_descargando != null) return;
    HapticFeedback.selectionClick();
    setState(() => _descargando = campo);
    BorradorCampo borrador;
    try {
      borrador = await widget.importar(campo);
    } catch (_) {
      if (!mounted) return;
      setState(() => _descargando = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo descargar el campo. Intenta de nuevo.')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _descargando = null);

    final abrir = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _VistaPrevia(borrador: borrador),
    );
    if (abrir != true || !mounted) return;

    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddCourseScreen(borrador: borrador.campo)),
    );
    if (guardado == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: const MyCustomAppBar(title: 'Buscar campo'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _texto,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _buscar(),
                decoration: InputDecoration(
                  hintText: 'Nombre del campo o ciudad',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _buscando
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          tooltip: 'Buscar',
                          icon: const Icon(Icons.arrow_forward_rounded),
                          onPressed: _buscar,
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(child: _contenido(tema)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Datos © colaboradores de OpenStreetMap',
                style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(ThemeData tema) {
    if (_error != null) {
      return _Mensaje(
        icono: Icons.cloud_off_rounded,
        titulo: _error!,
        accion: BotonApp(texto: 'Reintentar', compacto: true, variante: VarianteBoton.tonal, onPressed: _buscar),
      );
    }
    final resultados = _resultados;
    if (resultados == null) {
      return const _Mensaje(
        icono: Icons.travel_explore_rounded,
        titulo: 'Busca un campo para traer sus hoyos del mapa',
        detalle: 'No todos los campos tienen los hoyos dibujados: antes de guardar verás qué tan completo viene.',
      );
    }
    if (resultados.isEmpty) {
      return const _Mensaje(
        icono: Icons.search_off_rounded,
        titulo: 'No apareció ningún campo de golf',
        detalle: 'Prueba con la ciudad o con otro nombre. Si no está en el mapa, créalo a mano desde Campos.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: resultados.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (_, i) {
        final campo = resultados[i];
        final cargando = identical(campo, _descargando);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: tema.colorScheme.primaryContainer,
            foregroundColor: tema.colorScheme.onPrimaryContainer,
            child: const Icon(Icons.golf_course_rounded),
          ),
          title: Text(campo.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(campo.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: cargando
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right_rounded),
          enabled: _descargando == null || cargando,
          onTap: () => _elegir(campo),
        );
      },
    );
  }
}

/// Aviso centrado para los estados sin lista (inicio, sin resultados, error).
class _Mensaje extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? detalle;
  final Widget? accion;

  const _Mensaje({required this.icono, required this.titulo, this.detalle, this.accion});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: tema.colorScheme.primary),
            const SizedBox(height: 16),
            Text(titulo, textAlign: TextAlign.center, style: tema.textTheme.titleMedium),
            if (detalle != null) ...[
              const SizedBox(height: 8),
              Text(
                detalle!,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
              ),
            ],
            if (accion != null) ...[const SizedBox(height: 16), accion!],
          ],
        ),
      ),
    );
  }
}

/// Qué tan completo vino el campo, antes de abrirlo en el editor.
class _VistaPrevia extends StatelessWidget {
  final BorradorCampo borrador;

  const _VistaPrevia({required this.borrador});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final campo = borrador.campo;
    final gris = tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(campo.nombre, style: tema.textTheme.titleLarge),
            if (campo.ubicacion.isNotEmpty) Text(campo.ubicacion, style: gris),
            const SizedBox(height: 16),
            if (borrador.sinHoyos) ...[
              Text('Este campo solo tiene el contorno en el mapa.', style: tema.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('No trae hoyos ni greens. Puedes crearlo a mano con el nombre y la ubicación ya puestos.',
                  style: gris),
            ] else ...[
              Text(
                '${campo.hoyos.length} hoyos · par ${campo.par} · ${borrador.greensConContorno} greens dibujados',
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              for (final aviso in borrador.avisos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: tema.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(child: Text(aviso, style: gris)),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 16),
            BotonApp(
              texto: borrador.sinHoyos ? 'Crear a mano' : 'Revisar y guardar',
              icono: borrador.sinHoyos ? Icons.edit_rounded : Icons.checklist_rounded,
              expandido: true,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
  }
}
