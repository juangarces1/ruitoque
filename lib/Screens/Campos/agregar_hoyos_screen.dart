import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/Providers/cordenada_provider.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Models/tipos_cordenada.dart';
import 'package:ruitoque/Screens/Campos/Components/hoyo_tee_list.dart';
import 'package:ruitoque/Screens/Campos/Components/input_decoration.dart';
import 'package:ruitoque/Screens/Campos/add_hoyo_tee.dart';
import 'package:ruitoque/Screens/Campos/editar_coordenada_screen.dart';
import 'package:ruitoque/constans.dart';

// ignore: must_be_immutable
class AgregarHoyosScreen extends StatefulWidget {
  final List<Tee> tees; 
  final Function(Hoyo) onAgregarHoyo;
   final Function(Hoyo) onUpdateHoyo;
  final Hoyo? hoyo; // Campo opcional, para manejar edición

  const AgregarHoyosScreen({
    super.key,
    required this.onAgregarHoyo,
    required this.tees,   
    this.hoyo,
    required this.onUpdateHoyo, // Para pasar un hoyo si estamos editando
  });

  @override
  State<AgregarHoyosScreen> createState() => _AgregarHoyosScreenState();
}

class _AgregarHoyosScreenState extends State<AgregarHoyosScreen> {
  late Hoyo nuevoHoyo; // late permite inicializar después

  List<TipoCoordenada> tiposCoordenadas = TipoCoordenada.values;
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nombreController = TextEditingController();
  final _parController = TextEditingController();
  final _handicapController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.hoyo != null) {
      // Si es un hoyo existente (edición), prellenamos con sus valores
      nuevoHoyo = widget.hoyo!;
      _numeroController.text = nuevoHoyo.numero.toString();
      _nombreController.text = nuevoHoyo.nombre;
      _parController.text = nuevoHoyo.par.toString();
      _handicapController.text = nuevoHoyo.handicap?.toString() ?? '';
    } else {
      // Si no hay hoyo (agregar), creamos uno nuevo
      nuevoHoyo = Hoyo(
        id: 0,
        nombre: '',
        numero: 0,
        par: 0,
        campoId: 0,
        hoyotees: [],
        fondoGreen: Cordenada(id: 0, latitud: 0, longitud: 0),
        frenteGreen: Cordenada(id: 0, latitud: 0, longitud: 0),
        centroGreen: Cordenada(id: 0, latitud: 0, longitud: 0),
        centroHoyo: Cordenada(id: 0, latitud: 0, longitud: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CordenadaProvider cordenadaProvider = Provider.of<CordenadaProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MyCustomAppBar(
          title: widget.hoyo == null ? 'Agregar Hoyo' : 'Editar Hoyo',
          automaticallyImplyLeading: true,
          backgroundColor: kPprimaryColor,
          elevation: 8.0,
          shadowColor: const Color.fromARGB(255, 38, 38, 75),
          foreColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset(
                'assets/LogoGolf.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
      body: Container(
         decoration: const BoxDecoration(
          gradient: kFondoGradient
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      
                      children: <Widget>[
                        const SizedBox(height: 30,),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          controller: _numeroController,
                          decoration: buildInputDecoration('Numero del Hoyo'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                nuevoHoyo.numero = int.tryParse(value) ?? 0;
                              
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 5,),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          controller: _nombreController,
                          decoration: buildInputDecoration('Nombre'),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                nuevoHoyo.nombre = value;
                              });
                            }
                          },
                        ),
                          const SizedBox(height: 5,),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          controller: _parController,
                          decoration: buildInputDecoration('Par'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                nuevoHoyo.par = int.tryParse(value) ?? 0;
                              });
                            }
                          },
                        ),
                          const SizedBox(height: 5,),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          controller: _handicapController,
                          decoration:buildInputDecoration('Handicao'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                nuevoHoyo.handicap = int.tryParse(value) ?? 0;
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                              // Se ejecuta cuando se presiona Enter
                              FocusScope.of(context).unfocus(); // Quitar el foco
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
           const Divider(color: Colors.white70,),
         
          Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: ElevatedButton(
                    onPressed:   () => _navegarYAgregarHoyoTee(context, cordenadaProvider),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPprimaryColor, // Color de fondo del botón
                      foregroundColor: Colors.white, // Color del texto y iconos del botón
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ), // Estilo del texto
                    ),
                    child: const Text('Agregar Tee'), // Cambiar el texto del botón
                  ),
              ),
           
              const Text('Tees', style: kTextStyleBlancoNuevaFuente20),
              SizedBox(
                height: 130,
                child: HoyoTeesListWidget(
                  tees:  widget.tees,
                  hoyoTees: nuevoHoyo.hoyotees!,
                  onDelete: (HoyoTee hoyoTee) {
                    setState(() {
                      nuevoHoyo.hoyotees!.removeWhere((t) => t.color == hoyoTee.color);
                    });
                  },
                  onAddHoyo: (HoyoTee hoyoTee) {},
                  onUpdate: (HoyoTee hoyo) {
                     setState(() {
                        // Buscar por color ya que cada hoyo solo puede tener un tee de cada color
                        int index = nuevoHoyo.hoyotees!.indexWhere((t) => t.color == hoyo.color);
                        if (index != -1) {
                          nuevoHoyo.hoyotees![index] = hoyo;
                        }
                      });
                  },
                ),
              ),
        
                   const Divider(color: Colors.white70,),
             
             Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 6, 33, 45),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.place, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'Selecciona tipo de coordenada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: TipoCoordenada.values.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.white24,
                        thickness: 1,
                        indent: 12,
                        endIndent: 12,
                      ),
                      itemBuilder: (context, index) {
                        var tipoCoordenada = TipoCoordenada.values[index];
                        final tieneValor = tieneCoordenada(tipoCoordenada);
                   
                            return InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => _editarCoordenada(
                                tipoCoordenada,
                                getTitulo(tipoCoordenada),
                                cordenadaProvider,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                  color: tieneValor
                                      ? const Color(0xFF216C49) // verde cuando ya tiene valor
                                      : const Color(0xFF103041), // color base cuando está vacío
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: tieneValor ? Colors.greenAccent : Colors.white24,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.gps_fixed,
                                        color: tieneValor ? Colors.greenAccent : Colors.white60,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          getTitulo(tipoCoordenada),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        tieneValor ? Icons.check_circle : Icons.chevron_right,
                                        color: tieneValor ? Colors.greenAccent : Colors.white38,
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),

            const Divider(color: Colors.white70,),
              buildCard(),
            const Divider(color: Colors.white70,),
                Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        child: ElevatedButton(
                            onPressed: () {
                                if (_formKey.currentState!.validate()) {
        
                                  if (widget.hoyo != null) {
                                        widget.onUpdateHoyo(widget.hoyo!);
                                  } else {
                                      widget.onAgregarHoyo(nuevoHoyo);
        
                                  }
        
                                
                                  Navigator.pop(context);
                                }
                              },
                            style: ElevatedButton.styleFrom(
                               backgroundColor: kPprimaryColor, // Color de fondo del botón
                              foregroundColor: Colors.white, // Color del texto y iconos del botón
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Espaciado interno opcional
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ), // Estilo del texto
                            ),
                            child: Text(widget.hoyo == null ? 'Guardar Hoyo' : 'Actualizar Hoyo'),// Cambiar el texto del botón
                          ),
                      ),
                      const SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }

  bool tieneCoordenada(TipoCoordenada tipo) {
  switch (tipo) {
    case TipoCoordenada.frenteGreen:
      return nuevoHoyo.frenteGreen != null && (nuevoHoyo.frenteGreen!.latitud != 0 || nuevoHoyo.frenteGreen!.longitud != 0);
    case TipoCoordenada.centroGreen:
      return nuevoHoyo.centroGreen != null && (nuevoHoyo.centroGreen!.latitud != 0 || nuevoHoyo.centroGreen!.longitud != 0);
    case TipoCoordenada.fondoGreen:
      return nuevoHoyo.fondoGreen != null && (nuevoHoyo.fondoGreen!.latitud != 0 || nuevoHoyo.fondoGreen!.longitud != 0);
    case TipoCoordenada.centroHoyo:
      return nuevoHoyo.centroHoyo != null && (nuevoHoyo.centroHoyo!.latitud != 0 || nuevoHoyo.centroHoyo!.longitud != 0);
    default:
      return false; // Si no es un tipo conocido, no tiene coordenada
  }
}

  void _editarCoordenada(TipoCoordenada tipo, String titulo, CordenadaProvider cordenadaProvider) async {
    Cordenada? coordenadaInicial;
   if(widget.hoyo == null){
      switch (tipo) {
       case TipoCoordenada.frenteGreen:
         coordenadaInicial = cordenadaProvider.cordenada;
         break;
       case TipoCoordenada.centroGreen:
         coordenadaInicial = cordenadaProvider.cordenada;
         break;
       case TipoCoordenada.fondoGreen:
         coordenadaInicial = cordenadaProvider.cordenada;
         break;
       case TipoCoordenada.centroHoyo:
         coordenadaInicial = cordenadaProvider.cordenada;
         break;
       default:
         break;
     }}
     else {
        switch (tipo) {
          case TipoCoordenada.frenteGreen:
            coordenadaInicial = (widget.hoyo?.frenteGreen != null && widget.hoyo!.frenteGreen!.latitud != 0.0)
                ? widget.hoyo!.frenteGreen
                : cordenadaProvider.cordenada;
            break;
          case TipoCoordenada.centroGreen:
            coordenadaInicial = (widget.hoyo?.centroGreen != null && widget.hoyo!.centroGreen!.latitud != 0.0)
                ? widget.hoyo!.centroGreen
                : cordenadaProvider.cordenada;
            break;
          case TipoCoordenada.fondoGreen:
            coordenadaInicial = (widget.hoyo?.fondoGreen != null && widget.hoyo!.fondoGreen!.latitud != 0.0)
                ? widget.hoyo!.fondoGreen
                : cordenadaProvider.cordenada;
            break;
          case TipoCoordenada.centroHoyo:
            coordenadaInicial = (widget.hoyo?.centroHoyo != null && widget.hoyo!.centroHoyo!.latitud != 0.0)
                ? widget.hoyo!.centroHoyo
                : cordenadaProvider.cordenada;
            break;
          default:
            coordenadaInicial = cordenadaProvider.cordenada;
            break;
}
     }
     
  
     switch (tipo) {
      
       default:
         break;
     }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCoordenadaScreen(
          titulo: titulo,
          coordenadaInicial: coordenadaInicial!,         
          onCoordenadaActualizada: (nuevaCoordenada) {
            setState(() {
              if(widget.hoyo == null){
                switch (tipo) {
                case TipoCoordenada.frenteGreen:
                  nuevoHoyo.frenteGreen = nuevaCoordenada;
                  break;
                case TipoCoordenada.centroGreen:
                  nuevoHoyo.centroGreen = nuevaCoordenada;
                  break;
                case TipoCoordenada.fondoGreen:
                  nuevoHoyo.fondoGreen = nuevaCoordenada;
                  break;
                case TipoCoordenada.centroHoyo:
                  nuevoHoyo.centroHoyo = nuevaCoordenada;
                  break;
                default:
                  break;
              }

              } else {
                  switch (tipo) {
                    case TipoCoordenada.frenteGreen:
                      widget.hoyo!.frenteGreen = nuevaCoordenada;
                      break;
                    case TipoCoordenada.centroGreen:
                      widget.hoyo!.centroGreen = nuevaCoordenada;
                      break;
                    case TipoCoordenada.fondoGreen:
                      widget.hoyo!.fondoGreen = nuevaCoordenada;
                      break;
                    case TipoCoordenada.centroHoyo:
                      widget.hoyo!.centroHoyo = nuevaCoordenada;
                      break;
                    default:
                      break;
                  }
              }

              
            });
          },
        ),
      ),
    );
  }

  String getTitulo(TipoCoordenada tipo) {
    switch (tipo) {
      case TipoCoordenada.frenteGreen:
        return 'Frente Green';
      case TipoCoordenada.centroGreen:
        return 'Centro Green';
      case TipoCoordenada.fondoGreen:
        return 'Fondo Green';
      case TipoCoordenada.centroHoyo:
        return 'Centro Hoyo';
      default:
        return 'Coordenada'; // Default title
    }
  }

  Widget buildCard() {
    return Card(
       color: const Color.fromARGB(255, 42, 42, 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(child: Text("Detalle del Hoyo", style: TextStyle(color: Colors.white70, fontSize: 20))),
            const Divider(),
            Text("Número: ${nuevoHoyo.numero}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
            Text("Nombre: ${nuevoHoyo.nombre}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
            Text("Par: ${nuevoHoyo.par}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
            Text("Handicap: ${nuevoHoyo.handicap ?? 'No especificado'}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
            _construirTextoCoordenada("Frente Green", nuevoHoyo.frenteGreen),
            _construirTextoCoordenada("Centro Green", nuevoHoyo.centroGreen),
            _construirTextoCoordenada("Fondo Green", nuevoHoyo.fondoGreen),
            _construirTextoCoordenada("Centro Hoyo", nuevoHoyo.centroHoyo),
          ],
        ),
      ),
    );
  }

  Widget _construirTextoCoordenada(String titulo, Cordenada? coordenada) {
    return Text(
        "$titulo: ${coordenada != null ? 'Lat: ${coordenada.latitud}, Long: ${coordenada.longitud}' : 'No especificado'}",
         style: const TextStyle(color: Colors.white70, fontSize: 18));
  }

  void _navegarYAgregarHoyoTee(BuildContext context, CordenadaProvider cordenadaProvider) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHoyoTeesPage(
          cordenada: cordenadaProvider.cordenada,
          onAddHoyoTee: (tee) {
            setState(() {
              nuevoHoyo.hoyotees!.add(tee);
            });
          },
          onEditTee:  (tee) {},
          availableTees: getAvailableTeesByColor(widget.tees, nuevoHoyo.hoyotees!),
        ),
      ),
    );
  }

  List<Tee> getAvailableTeesByColor(List<Tee> campoTees, List<HoyoTee> hoyoTees) {
    Set<String> usedTeeColors = hoyoTees.map((hoyoTee) => hoyoTee.color).toSet();
    return campoTees.where((tee) => !usedTeeColors.contains(tee.color)).toList();
  }
}
