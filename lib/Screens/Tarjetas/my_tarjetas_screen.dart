import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/loader_component.dart';
import 'package:ruitoque/Components/tarjetas_player_card.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MyTarjetasScreen extends StatefulWidget {

  final Jugador jugador;
  // ignore: use_key_in_widget_constructors
  const MyTarjetasScreen({ required this.jugador});

  @override
  State<MyTarjetasScreen> createState() => _MyTarjetasScreenState();
}

class _MyTarjetasScreenState extends State<MyTarjetasScreen> {
  List<Tarjeta> tarjetas = []; 
  // Variables de paginación
  int _currentPage = 1; 
  final int _pageSize = 5; 
  bool showLoader = false;      // Loader global (pantalla completa) al inicio  
  bool _isLastPage = false;     // Indica si ya no hay más datos que cargar
  // Controlador de pull_to_refresh
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  
  @override

  void initState() {
    super.initState();
    _getTarjetas();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          title: 'Mis Tarjetas',
          elevation: 3.0,
          shadowColor: Colors.red,
          automaticallyImplyLeading: true,
          foreColor: Colors.white,
          backgroundColor: kPprimaryColor,
          actions: <Widget>[
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipOval(child:  Image.asset(
                  'assets/LogoGolf.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),), // Ícono de perfil de usuario
            ),
          ],      
        ),
     body: showLoader
            ? const LoaderComponent(loadingText: 'Cargando...')
            : Container(
                decoration: const BoxDecoration(
                  gradient: kPrimaryGradientColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(3),
                    vertical: getProportionateScreenHeight(5),
                  ),
                  // Usamos ListView.builder y le sumamos 1 al itemCount 
                  // para mostrar un widget "Load More" al final
                  child: SmartRefresher(
                
                      // Desactivamos "pull-down" y activamos "pull-up"
                    enablePullDown: false,
                    enablePullUp: true,
                    controller: _refreshController,
                    // Se llama cuando se hace “pull-up” al final de la lista
                    onLoading: _onLoading,
                    header: const WaterDropHeader(),
                    footer: CustomFooter(
                      builder: (context, mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = const Text('Arrastra para Cargar más', style: TextStyle(color: Colors.white),);
                        } else if (mode == LoadStatus.loading) {
                          body = const CircularProgressIndicator(color: Colors.white,);
                        } else if (mode == LoadStatus.failed) {
                          body = const Text('La carga fallo vuelve a intentarlo!');
                        } else if (mode == LoadStatus.canLoading) {
                          body = const Text('Libera para cargar más');
                        } else {
                          body = const Text('No hay mas Tarjetas', style: TextStyle(color: Colors.white),);
                        }
                        return SizedBox(
                          height: 55.0,
                          child: Center(child: body),
                        );
                      },
                    ),
                   
                   child: ListView.builder(
                      itemCount: tarjetas.length,
                      itemBuilder: (context, index) {
                        final item = tarjetas[index];
                        return TarjetaPlayer(
                          tarjeta: item,
                          jugador: widget.jugador,
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }

 void _onLoading() {
    // Si ya no hay más páginas, avisa a pull_to_refresh que no hay más data
    if (_isLastPage) {
      _refreshController.loadNoData(); 
      return;
    }

    _loadMore();
  }

 // Carga la primera página o recarga
  Future<void> _getTarjetas() async {
    setState(() => showLoader = true);

    Response response = await ApiHelper.getTarjetasById(
      widget.jugador.id.toString(),
      page: _currentPage,
      pageSize: _pageSize,
    );

    setState(() => showLoader = false);

    if (!response.isSuccess) {
      if (!mounted) return;
      _showErrorDialog(response.message);
      return;
    }

    final Jugador aux = response.result;
    if (aux.tarjetas == null || aux.tarjetas!.isEmpty) {
      // No hay tarjetas => ya no hay más
      setState(() => _isLastPage = true);
      return;
    }

    setState(() {
      tarjetas = aux.tarjetas!;
      if (aux.tarjetas!.length < _pageSize) {
        // Si la cantidad de tarjetas es menor al pageSize, ya no hay más
        _isLastPage = true;
      }
      _currentPage++;
    });
  }


  // Método para cargar más tarjetas (siguiente página)
  // Carga la siguiente página (cuando detectamos overscroll)
   Future<void> _loadMore() async {
    final response = await ApiHelper.getTarjetasById(
      widget.jugador.id.toString(),
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!response.isSuccess) {
      if (!mounted) return;
      _showErrorDialog(response.message);
      // Indica a pull_to_refresh que termine la animación de loading
      _refreshController.loadComplete();
      return;
    }

    final Jugador aux = response.result;
    final newTarjetas = aux.tarjetas ?? [];

    if (newTarjetas.isEmpty) {
      // No hay más datos
      setState(() => _isLastPage = true);
      // Indica a pull_to_refresh que ya no hay data (para que no siga intentando cargar)
      _refreshController.loadNoData();
    } else {
      setState(() {
        tarjetas.addAll(newTarjetas);
        if (newTarjetas.length < _pageSize) {
          // Si la cantidad de tarjetas es menor al pageSize, ya no hay más
          _isLastPage = true;
        }
        _currentPage++;
      });
      // Indica a pull_to_refresh que termine la animación de loading
      _refreshController.loadComplete();
    }
  }

  // Muestra un diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

 
}