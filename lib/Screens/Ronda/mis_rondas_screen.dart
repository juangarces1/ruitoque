import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_ronda.dart';
import 'package:ruitoque/Components/loader_component.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MisRondasScreen extends StatefulWidget {
  const MisRondasScreen({Key? key}) : super(key: key);

  @override
  State<MisRondasScreen> createState() => _MisRondasScreenState();
}

class _MisRondasScreenState extends State<MisRondasScreen> {
  final List<Ronda> _rondas = [];
  final _scrollCtl = ScrollController();

  bool _showLoader = false;
  bool _isLoadingMore = false;
  bool _hasMore = true; // si quedan páginas por cargar
  int _page = 1;
  final int _pageSize = 5;

  late Jugador _jugador;

  /*───────────────────────────────────────────────*/
  @override
  void initState() {
    super.initState();
    _jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;

    _scrollCtl.addListener(_onScroll);
    _getFirstPage();
  }

  @override
  void dispose() {
    _scrollCtl.dispose();
    super.dispose();
  }

  /*───────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          title: 'Mis Rondas',
          elevation: 4,
          shadowColor: Colors.red,
          automaticallyImplyLeading: true,
          foreColor: Colors.white,
          backgroundColor: kPprimaryColor,
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
        body: _showLoader
            ? const MyLoader(opacity: 1, text: 'Cargando...')
            : Container(
                decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(3),
                    vertical: getProportionateScreenHeight(5),
                  ),
                  child: ListView.builder(
                    controller: _scrollCtl,
                    itemCount: _rondas.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _rondas.length) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final item = _rondas[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Eliminar ronda'),
                              content: const Text('¿Estás seguro de que quieres eliminar esta ronda?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          return confirmed == true;
                        },
                        onDismissed: (direction) async {
                            // 1. Guarda copia y quita YA de la lista
                            final removed = _rondas[index];
                            setState(() => _rondas.removeAt(index));

                            // 2. Llama al backend
                            final resp = await ApiHelper.delete('/api/rondas/${removed.id}');

                            if (resp.isSuccess) {
                              Fluttertoast.showToast(
                                msg: 'Ronda eliminada',
                                backgroundColor: Colors.green[700],
                                textColor: Colors.white,
                              );
                            } else {
                              // 3. Rollback visual
                              if (mounted) {
                                setState(() => _rondas.insert(index, removed));
                              }
                              Fluttertoast.showToast(
                                msg: 'Error: ${resp.message}',
                                backgroundColor: Colors.red[700],
                                textColor: Colors.white,
                              );
                            }
                          },
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: CardRonda(ronda: item),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }


  /*───────────────────────────────────────────────*/
  Future<void> _getFirstPage() async {
    setState(() => _showLoader = true);
    await _loadPage(1);
    setState(() => _showLoader = false);
  }

  Future<void> _loadPage(int page) async {
    _isLoadingMore = true;
    setState(() {});

    final Response res = await ApiHelper.getFinishedRoundsByPlayer(
      playerId: _jugador.id,
      page: page,
      pageSize: _pageSize,
    );

    _isLoadingMore = false;

    if (!mounted) return;

    if (!res.isSuccess) {
      _showError(res.message);
      return;
    }

    final List<Ronda> nuevas = res.result;
    for (final r in nuevas) {
      r.calcularYAsignarPosiciones();
    }

    setState(() {
      _rondas.addAll(nuevas);
      _hasMore = _rondas.length < res.totalCount; // si usas totalCount
      _page = page + 1;
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollCtl.position.pixels >=
        _scrollCtl.position.maxScrollExtent - 200) {
      _loadPage(_page);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
