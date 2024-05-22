import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';

import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Estadisticas/golf_score_screen.dart';
import 'package:ruitoque/constans.dart';

class TarjetaRonda extends StatefulWidget {
  final Tarjeta tarjeta;
  const TarjetaRonda({super.key, required this.tarjeta});

  @override
  State<TarjetaRonda> createState() => _TarjetaRondaState();
}

class _TarjetaRondaState extends State<TarjetaRonda> {
  late int mitad;

  @override
  void initState() {
     super.initState();    
      mitad = (widget.tarjeta.hoyos.length / 2).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      child: ExpansionTile(
        title: _crearHeader(),
        children: <Widget>[
          const Divider(),
          _crearCuerpoEstadisticas(),
          const Divider(),
          _crearFooter(),
        ],
      ),
    );
  }

  Widget _crearHeader() {
    // Header de la tarjeta con el nombre y el handicap
    TextStyle textStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black);
    TextStyle textStyleRed = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text( widget.tarjeta.jugador!.nombre , style: textStyle),
                ],
              ),
              Row(
                children: [
                  Text('HCP ${widget.tarjeta.jugador!.handicap}', style : textStyle),
                ],
      
              ),
      
      
      
            ],
          ),
           Column(
               crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Row(
                children: <Widget>[
                  Text('Score: ', style: textStyle,),
                  Text(widget.tarjeta.puntuacionTotal.toString(), style: textStyle,),
                  const SizedBox(width: 8),
                 
                  const SizedBox(width: 8),
                  // Aquí agregarías los botones o iconos para cambiar idioma/pantalla
                ],
                         ),
                          Row(
                    children: [
                      Text('Score Par: ', style: textStyle,),
                      Text(widget.tarjeta.scoreParString, style:  widget.tarjeta.scorePar < 0 ? textStyleRed : textStyle),
                    ],
                  ),
             ],
           ),
        ],
      ),
    );
  }

Widget _crearCuerpoEstadisticas() {
  // Definiendo las columnas para 'Ida' y 'Vuelta' por separado
  return Column(
    children: [
      _crearTablaEstadisticas('Ida', 1, mitad), // Tabla para los hoyos 1-9
     
      _crearTablaEstadisticas('Vuelta', mitad + 1, widget.tarjeta.hoyos.length), // Tabla para los hoyos 10-18
    ],
  );
}

Widget _crearTablaEstadisticas(String titulo, int inicioHoyo, int finHoyo) {
   double espacio = 24;
  
   TextStyle styleFirstRow = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
   TextStyle styleScore = const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
  return Column(
    children: [
     
      Table(
       
        columnWidths:  {
          0: const FlexColumnWidth(1),
          1: FixedColumnWidth(espacio), // Para el handicap
          2: FixedColumnWidth(espacio), // Para el par
          3: FixedColumnWidth(espacio), // Para el handicap
          4: FixedColumnWidth(espacio), // Para el par
          5: FixedColumnWidth(espacio), // Para el handicap
          6: FixedColumnWidth(espacio), // Para el par
          7: FixedColumnWidth(espacio), // Para el handicap
          8: FixedColumnWidth(espacio), // Para el par
          9: FixedColumnWidth(espacio),
          10: const FixedColumnWidth(50),
          // Para el par
         
          // ... otras definiciones de ancho para tus columnas
        },
      //  border: TableBorder.all(color: Colors.grey),
        children: [
          // Encabezado de hoyos
        TableRow(
                    decoration: const BoxDecoration(
            color: kSecondaryColor, // Color de fondo para toda la fila
            // Aquí puedes agregar más estilos como bordes, sombras, etc.
          ),
          children: <Widget>[
             Center(child: Text('Hoyo', style: styleFirstRow)), ...List<Widget>.generate(finHoyo - inicioHoyo + 1, (index) {
                return Center(child: Text('${inicioHoyo + index}', style:  styleFirstRow ));
              }), Center(child: Text(titulo, style: styleFirstRow,)), // Título al inicio de la fila
          ],
        ),
        TableRow(
          children: <Widget>[
            const Center(child: Text('Handicap')), ...List<Widget>.generate(mitad, (index) {
                return inicioHoyo == 1 ? Center(child: Text('${widget.tarjeta.hoyos[index].hoyo.handicap}')) : Center(child: Text('${widget.tarjeta.hoyos[index + mitad].hoyo.handicap}'));
              }), const Center(child: Text('')), // Título al inicio de la fila
          ],
        ),

        TableRow(
          children: <Widget>[
            const Center(child: Text('Par')), ...List<Widget>.generate(mitad, (index) {
                return inicioHoyo == 1 ? Center(child: Text('${widget.tarjeta.hoyos[index].hoyo.par}')) : Center(child: Text('${widget.tarjeta.hoyos[index + mitad].hoyo.par}'));
              }),  Center(child: Text(inicioHoyo ==1 ?  widget.tarjeta.parIda.toString(): widget.tarjeta.parVuelta.toString() ))  , // Título al inicio de la fila
          ],
        ),

         TableRow(
          children: <Widget>[
            Container(
               padding: const EdgeInsets.all(4), 
              child: Center(child: Text('Score', style: styleScore,))), ...List<Widget>.generate(mitad, (index) {
                return inicioHoyo == 1 ?
                celdaTarjeta(widget.tarjeta.hoyos[index].pontajeVsPar, widget.tarjeta.hoyos[index].golpes)  
                  : celdaTarjeta(widget.tarjeta.hoyos[index + mitad].pontajeVsPar, widget.tarjeta.hoyos[index + mitad].golpes);  
              }),  Container(
                  padding: const EdgeInsets.all(4), 
                child: Center(child: Text(inicioHoyo == 1 ? 
                 widget.tarjeta.scoreIda == 0 ?  ''
                  : widget.tarjeta.scoreIda.toString()
                   : widget.tarjeta.scoreVuelta == 0 ? '' 
                   : widget.tarjeta.scoreVuelta.toString(), style: styleScore, )),
              )  , // Título al inicio de la fila
          ],
        ),

         TableRow(
            children: <Widget>[
               const Center(child: Text('Neto')), ...List<Widget>.generate(mitad, (index) {
                  return inicioHoyo == 1 ?
                  calcularNeto(widget.tarjeta.hoyos[index])  
                    : calcularNeto(widget.tarjeta.hoyos[index + mitad]);  
                }),  Center(child: Text(inicioHoyo == 1 ? 
                 widget.tarjeta.netoIda == 0 ?  ''
                  : widget.tarjeta.netoIda.toString()
                   : widget.tarjeta.netoVuelta == 0 ? '' 
                   : widget.tarjeta.netoVuelta.toString() ))  , // Título al inicio de la fila
            ],
          ),

      
          // Las siguientes filas para handicap, par, score, y neto
          // Generar dinámicamente usando los datos que tengas para cada una de estas categorías
          // ...
        ],
      ),
    ],
  );
}

Widget calcularNeto(EstadisticaHoyo estadisticaHoyo){
 
  if(estadisticaHoyo.golpes==0){
      return const Text('',);
  }
 
   return Center(child: Text(estadisticaHoyo.neto.toString(),));
}

 Widget celdaTarjeta(int scorePar, int golpes){
     TextStyle styleScore = const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
     TextStyle styleScoreDiferente = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
     if(golpes == 0){
      return Text('', style: styleScore,);
     }
     switch (scorePar) {
      case -1:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
          padding: const EdgeInsets.all(2), // Ajusta este valor para cambiar el tamaño del círculo
          decoration: const BoxDecoration(
            color: kBerdieColor, // Color de fondo del círculo
            shape: BoxShape.circle, // Hace que el Container sea circular
          ),
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
                ),
        );
    
    case -2:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), // Ajusta este valor para cambiar el tamaño del círculo
          decoration: const BoxDecoration(
            color: kEagleColor, // Color de fondo del círculo
            shape: BoxShape.circle, // Hace que el Container sea circular
          ),
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
      );

     case -3:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), // Ajusta este valor para cambiar el tamaño del círculo
          decoration: const BoxDecoration(
            color: kAlvatrosColor, // Color de fondo del círculo
            shape: BoxShape.circle, // Hace que el Container sea circular
          ),
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
      );

    case 0:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), 
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScore,
            ),
          ),
         ),
      );
    case 1:
     return Padding(
       padding: const EdgeInsets.all(2),
       child: Container(
          padding: const EdgeInsets.all(2), 
          color: kBogeyColor,
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
     );
     case 2:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), 
          color: kDoubleBogueColor,
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
      );
    default:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), 
          color: kDoubleBogueColor,
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
      );
  }
  
  }

  Widget _crearFooter() {
    // Footer de la tarjeta con acciones como 'Me gusta', 'Comentar', 'Estadísticas'
   
    TextStyle textStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
         Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Par ${widget.tarjeta.campo!.par.toString()} ', style: textStyle,),
               Text('Tee ${widget.tarjeta.teeSalida!.substring(3)} ', style: textStyle,),
              Text(' ${widget.tarjeta.puntuacionTotal.toString()}/${widget.tarjeta.totalNeto.toString()}', style: textStyle,),
            ],
         ),
                         const Divider(thickness: 2,),
                       
         Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Botón 'Me gusta' con fondo circular
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.save),
                  color: Colors.green,
                  onPressed: () => writeJsonToFile(),
                ),
              ),
              // Botón 'Comentar' con fondo circular
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.comment),
                  color: Colors.blue,
                  onPressed: () => getTarjeta(),
                ),
              ),
              // Botón 'Estadísticas' con fondo circular
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.bar_chart),
                  color: Colors.purple,
                  onPressed: () => goEstadisticas(),
                        ),
            ),
          ],
        ),

        ],
      ),
    );
  }
  
  goEstadisticas() {
    Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) =>  GolfScoreScreen(tarjeta: widget.tarjeta,)
    )
   );
  }

  Future<void> writeJsonToFile() async {
    final directory = await getApplicationDocumentsDirectory();
     String fechaSinEspacios = DateTime.now().toString().replaceAll(" ", "");
    
      final file = File('${directory.path}/mitarjeta_$fechaSinEspacios.json');
      Map<String, dynamic> objeto = widget.tarjeta.toJson();
      String jsonString = jsonEncode(objeto);
      file.writeAsString(jsonString);
   if(mounted){
       Navigator.pop(context);
   }
    
}

  Future<Map<String, dynamic>> readJsonFromFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/mitarjeta.json');

    // Verifica si el archivo existe antes de intentar leerlo
    if (await file.exists()) {
      String jsonString = await file.readAsString();
      // Decodifica el string JSON a un objeto Map
      Map<String, dynamic> jsonObject = jsonDecode(jsonString);
      return jsonObject;
    } else {
    
      return {};
    }
  } catch (e) {
   
    return {};
  }
}

getTarjeta() {
  

  
}
}