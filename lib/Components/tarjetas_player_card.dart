import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Tarjetas/mapa_golpes.dart';
import 'package:ruitoque/Screens/Tarjetas/stats_card.dart';
import 'package:ruitoque/constans.dart';

class TarjetaPlayer extends StatefulWidget {
  final Tarjeta tarjeta;
  final Jugador? jugador;
  const TarjetaPlayer({super.key, required this.tarjeta, this.jugador});

  @override
  State<TarjetaPlayer> createState() => _TarjetaPlayerState();
}

class _TarjetaPlayerState extends State<TarjetaPlayer> {
   late int mitad;

  @override
  void initState() {
     super.initState();    
      mitad = (widget.tarjeta.hoyos.length / 2).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      child: Column(
        
        children: <Widget>[
           _crearHeader(),
          const Divider(),
          _crearCuerpoEstadisticas(),
          const Divider(),
          _crearFooter(),
          //   const Divider(),
          //  Container(
          //    padding: const EdgeInsets.symmetric(vertical: 3),
          //    height: 100,
          //    child: ListView.builder(
          //      scrollDirection: Axis.horizontal,
          //      itemCount: widget.tarjeta.hoyos.length,
          //      itemBuilder: (BuildContext context, int index) {
          //        return buildCardShotsMap(widget.tarjeta.hoyos[index], widget.tarjeta.teeSalida!);
          //      },
          //    ),
          //  ),  
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
      child: Column(
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fecha: ${widget.tarjeta.fecha}', style : textStyle),
              
            ],),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
               Text('Campo: ${widget.tarjeta.campoNombre}', style : textStyle),
            ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                 
                  Row(
                    children: [
                     widget.tarjeta.jugador != null ? Text('HCP ${widget.tarjeta.handicapPlayer}', style : textStyle) : Text('HCP ${widget.jugador!.handicap}', style : textStyle),
                    ],
          
                  ),
                  Row(
                    children: [
                       widget.tarjeta.jugador != null ? Text(widget.tarjeta.jugador!.nombre, style : textStyle) : Text(widget.jugador!.nombre, style : textStyle),
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
            color: Colors.green, // Color de fondo para toda la fila
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

          TableRow(
              children: <Widget>[
                 Center(child: Text('Mapa', style: styleScore)), // Encabezado de la columna de los botones
                ...List<Widget>.generate(mitad, (index) {
                  // Generar botones para cada hoyo
                  EstadisticaHoyo hoyo = inicioHoyo == 1
                      ? widget.tarjeta.hoyos[index]
                      : widget.tarjeta.hoyos[index + mitad];
                  return Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.golf_course,
                         color:kPprimaryColor,
                         size:20,
                         ),
                      tooltip: 'Ver mapa del hoyo',
                      onPressed: () => goHole(hoyo),
                    ),
                  );
                }),
                const Center(child: Text('')), // Última celda vacía para el total
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
              Text('Par ${widget.tarjeta.parCampo.toString()} ', style: textStyle,),
               Text('Tee ${widget.tarjeta.teeSalida} ', style: textStyle,),
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
      builder: (context) =>  TarjetaStatsWidget(tarjeta: widget.tarjeta,)
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

  goHole(EstadisticaHoyo estadistica) {
    HoyoTee? hoyoTee = _encontrarHoyoTeePorColor(estadistica.hoyo.hoyotees!, widget.tarjeta.teeSalida!);
     Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MapaGolpes(estadisticaHoyo: estadistica, teeSalida: hoyoTee!,),
    ),
  );
  }

  HoyoTee? _encontrarHoyoTeePorColor(List<HoyoTee> hoyos, String color) {
    for (var hoyotee in hoyos) {
      if (hoyotee.color.toLowerCase() == color.toLowerCase()) {
        return hoyotee;
      }
    }
    return null; // Retorna null si no encuentra ninguna coincidencia
  }
}