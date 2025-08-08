import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_jugador.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Screens/Home/Components/card_join.dart';
import 'package:ruitoque/Screens/Home/Components/golf_drawer.dart';
import 'package:ruitoque/Screens/Home/Components/ronda_card.dart';
import 'package:ruitoque/Screens/Ronda/select_screen.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showLoader = false;
  late Jugador jugador;
  List<Ronda> rondasIncompletas = [];

  @override
  void initState() {
    super.initState();
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
    WidgetsBinding.instance.addPostFrameCallback((_) => _obtenerRondasIncompletas());
  }

  Future<void> _obtenerRondasIncompletas() async {
    if (!mounted) return;
    setState(() => showLoader = true);

    final resp = await ApiHelper.getRondasAbiertas(jugador.id);

    if (!mounted) return;
    setState(() => showLoader = false);

    if (!resp.isSuccess) {
      Fluttertoast.showToast(msg: 'Error: ${resp.message}', backgroundColor: Colors.red);
      return;
    }
    setState(() => rondasIncompletas = resp.result);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final double posJugar = SizeConfig.screenWidth / 2 - 40;

    return Scaffold(
      drawer: GolfDrawer(jugador: jugador),          // ←  Drawer tradicional
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MyCustomAppBar(
          title: 'Golf Colombia',
          backgroundColor: const Color(0xFF00472C),
          foreColor: Colors.white,
          automaticallyImplyLeading: true,
          shadowColor: Colors.red,
          elevation: 4.0,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset('assets/LogoGolf.png', width: 30, height: 30),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/Fondo.png'), fit: BoxFit.fill))),
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CardJugador(),
                rondasIncompletas.isNotEmpty
                    ? Expanded(
                      child: ListView.builder(
                          itemCount: rondasIncompletas.length,
                          itemBuilder: (context, index) {
                            final ronda = rondasIncompletas[index];
                            return Dismissible(
                              key: ValueKey(ronda.id),
                              direction: DismissDirection.endToStart,        // ←  swipe horizontal para borrar
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                color: Colors.red[600],
                                child: const Icon(Icons.delete, color: Colors.white, size: 36),
                              ),
                              confirmDismiss: (d) => _confirmar(context),
                              onDismissed: (direction) async {
                                  // 1️⃣  Copia y quita YA
                                  final removed = rondasIncompletas[index];
                                  setState(() => rondasIncompletas.removeAt(index));

                                  // 2️⃣  Llama al backend
                                  final resp = await ApiHelper.delete('/api/rondas/${removed.id}');

                                  if (resp.isSuccess) {
                                    Fluttertoast.showToast(
                                      msg: 'Ronda eliminada',
                                      backgroundColor: Colors.green[700],
                                      textColor: Colors.white,
                                    );
                                  } else {
                                    // 3️⃣  Rollback visual si falló
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
                              child: RondaCard(ronda: ronda),
                            );
                          },
                        ),
                    )
                    : UnirseARondaCard(onTap: _obtenerRondasIncompletas),
              ],
            ),
          ),
          if (showLoader) const Center(child: MyLoader(text: 'Cargando...', opacity: 1)),
          Positioned(
            bottom: 3,
            left: posJugar,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectCampoScreen())),
              child: ClipOval(
                child: Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  color: kPcontrastMoradoColor,
                  child: const Text('Jugar', style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
            ),
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
            TextButton(child: const Text('Eliminar', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
          ],
        ),
      );


}
