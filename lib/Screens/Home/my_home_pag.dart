import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/avatar_perfil.dart';
import 'package:ruitoque/Components/card_jugador.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Screens/Home/Components/card_join.dart';
import 'package:ruitoque/Screens/Home/Components/ronda_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool showLoader = false;
  late Jugador jugador;
  List<Ronda> rondasIncompletas = [];

  late final AnimationController _fadeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

  @override
  void initState() {
    super.initState();
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
    WidgetsBinding.instance.addPostFrameCallback((_) => _obtenerRondasIncompletas());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _obtenerRondasIncompletas() async {
    if (!mounted) return;
    setState(() => showLoader = true);
    _fadeCtrl.forward(from: 0);

    final resp = await ApiHelper.getRondasAbiertas(jugador.id);

    if (!mounted) return;
    setState(() => showLoader = false);

    if (!resp.isSuccess) {
      Fluttertoast.showToast(
        msg: 'Error: ${resp.message}',
        backgroundColor: Colors.red,
      );
      return;
    }
    setState(() => rondasIncompletas = resp.result);
  }

  Future<void> _refresh() => _obtenerRondasIncompletas();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // El fondo de montañas sigue detrás de la barra (se ve en sus esquinas redondeadas);
      // el SafeArea del contenido ya descuenta el alto de la barra.
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MyCustomAppBar(
          title: 'Golf Colombia',
          backgroundColor: const Color(0xFF00472C),
          foreColor: Colors.white,
          automaticallyImplyLeading: true,
          shadowColor: Colors.black54,
          elevation: 4.0,
          actions: const [AvatarPerfil()],
        ),
      ),
      body: Stack(
        children: [
          // Fondo con overlay para mejorar legibilidad
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/Fondo.png', fit: BoxFit.fill),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.10),
                        Colors.black.withOpacity(0.20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 10, left: 10),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const CardJugador(),
                  const SizedBox(height: 8),
                  // Lista / Vacío con pull-to-refresh
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: rondasIncompletas.isNotEmpty
                            ? ListView.builder(
                                key: const ValueKey('list'),
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: rondasIncompletas.length,
                                itemBuilder: (context, index) {
                                  final ronda = rondasIncompletas[index];
                                  return Dismissible(
                                    key: ValueKey(ronda.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(horizontal: 25),
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red[600],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.delete, color: Colors.white, size: 32),
                                    ),
                                    confirmDismiss: (d) => _confirmar(context),
                                    onDismissed: (direction) async {
                                      final removed = ronda;
                                      setState(() => rondasIncompletas.removeAt(index));

                                      final resp = await ApiHelper.delete('/api/rondas/${removed.id}');
                                      if (resp.isSuccess) {
                                        Fluttertoast.showToast(
                                          msg: 'Ronda eliminada',
                                          backgroundColor: Colors.green[700],
                                          textColor: Colors.white,
                                        );
                                      } else {
                                        if (mounted) {
                                          setState(() => rondasIncompletas.insert(index, removed));
                                        }
                                        Fluttertoast.showToast(
                                          msg: 'Error: ${resp.message}',
                                          backgroundColor: Colors.red[700],
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: RondaCard(ronda: ronda),
                                    ),
                                  );
                                },
                              )
                            : ListView(
                                key: const ValueKey('empty'),
                                padding: const EdgeInsets.only(bottom: 120),
                                children: [
                                  const SizedBox(height: 8),
                                  // Estado vacío existente, centrado
                                  UnirseARondaCard(onTap: _obtenerRondasIncompletas),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loader con fade (sin bloquear gestos del RefreshIndicator)
          if (showLoader)
            FadeTransition(
              opacity: _fadeCtrl,
              child: const Center(child: MyLoader(text: 'Cargando...', opacity: 1)),
            ),
        ],
      ),
    );
  }

  /* ---------- helpers de borrado ---------- */
  Future<bool?> _confirmar(BuildContext ctx) => showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          title: const Text('Eliminar ronda'),
          content: const Text('¿Deseas eliminar esta ronda? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx, false)),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );
}
