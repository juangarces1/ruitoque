import 'package:flutter/material.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Estadisticas/golf_score_screen.dart';
import 'package:ruitoque/constans.dart';

class NewTarjetaCard extends StatefulWidget {
  final Tarjeta tarjeta;
  final Future<void> Function() onSave;
   final Future<void> Function() onBack;
  const NewTarjetaCard({super.key, required this.tarjeta, required this.onSave, required this.onBack});

  @override
  State<NewTarjetaCard> createState() => _NewTarjetaCardState();
}

class _NewTarjetaCardState extends State<NewTarjetaCard> {
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
    List<EstadisticaHoyo> idaHoyos = [];
    List<EstadisticaHoyo> vueltaHoyos = [];
    int totalHoyos = widget.tarjeta.hoyos.length;

    if (totalHoyos == 6 || totalHoyos == 18) {
      int mitad = (totalHoyos / 2).floor();
      idaHoyos = widget.tarjeta.hoyos.sublist(0, mitad);
      vueltaHoyos = widget.tarjeta.hoyos.sublist(mitad, totalHoyos);
    } else if (totalHoyos == 9) {
      idaHoyos = widget.tarjeta.hoyos;
      vueltaHoyos = widget.tarjeta.hoyos;
    } else {
      int mitad = (totalHoyos / 2).ceil();
      idaHoyos = widget.tarjeta.hoyos.sublist(0, mitad);
      vueltaHoyos = widget.tarjeta.hoyos.sublist(mitad, totalHoyos);
    }

    return Column(
      children: [
        _crearTablaEstadisticas('Ida', idaHoyos, 0),
        _crearTablaEstadisticas('Vuelta', vueltaHoyos, vueltaHoyos.length),
      ],
    );
  }

 Widget _crearTablaEstadisticas(String titulo, List<EstadisticaHoyo> hoyos, int cantHoyos) {
    double espacio = 24;
    TextStyle styleFirstRow = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
    TextStyle styleScore = const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);

    Map<int, TableColumnWidth> columnWidths = {
      0: const FlexColumnWidth(1),
    };
    for (int i = 1; i <= hoyos.length; i++) {
      columnWidths[i] = FixedColumnWidth(espacio);
    }
    columnWidths[hoyos.length + 1] = const FixedColumnWidth(50);

    return Column(
      children: [
        Table(
          columnWidths: columnWidths,
          children: [
            TableRow(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              children: <Widget>[
                Center(child: Text('Hoyo', style: styleFirstRow)),
                ...List<Widget>.generate(hoyos.length, (index) {
                  return Center(child: Text('${index + 1 + cantHoyos}', style: styleFirstRow));
                }),
                Center(child: Text(titulo, style: styleFirstRow)),
              ],
            ),
            TableRow(
              children: <Widget>[
                const Center(child: Text('Handicap')),
                ...hoyos.map((hoyo) => Center(child: Text('${hoyo.hoyo.handicap}'))).toList(),
                const Center(child: Text('')),
              ],
            ),
            TableRow(
              children: <Widget>[
                const Center(child: Text('Par')),
                ...hoyos.map((hoyo) => Center(child: Text('${hoyo.hoyo.par}'))).toList(),
                Center(child: Text(computeTotalPar(hoyos).toString())),
              ],
            ),
            TableRow(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Center(child: Text('Score', style: styleScore)),
                ),
                ...hoyos.map((hoyo) => celdaTarjeta(hoyo.pontajeVsPar, hoyo.golpes)).toList(),
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Center(
                    child: Text(
                      computeTotalScore(hoyos) == 0 ? '' : computeTotalScore(hoyos).toString(),
                      style: styleScore,
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: <Widget>[
                const Center(child: Text('Neto')),
                ...hoyos.map((hoyo) => calcularNeto(hoyo)).toList(),
                Center(
                  child: Text(
                    computeTotalNeto(hoyos) == 0 ? '' : computeTotalNeto(hoyos).toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

   int computeTotalPar(List<EstadisticaHoyo> hoyos) {
    return hoyos.fold(0, (sum, estadisticaHoyo) => sum + estadisticaHoyo.hoyo.par);
  }

  int computeTotalScore(List<EstadisticaHoyo> hoyos) {
    return hoyos.fold(0, (sum, estadisticaHoyo) => sum + estadisticaHoyo.golpes);
  }

int computeTotalNeto(List<EstadisticaHoyo> hoyos) {
  // if (hoyos.contains(null)) {
  //   hoyos = hoyos.where((hoyo) => hoyo != null).toList();
  // }
  return hoyos.fold(0, (sum, estadisticaHoyo) => sum + (estadisticaHoyo.neto ?? 0));
}

Widget calcularNeto(EstadisticaHoyo estadisticaHoyo) {
  if (estadisticaHoyo.golpes == 0 || estadisticaHoyo.neto == null) {
    return const Text('');
  }
  return Center(child: Text(estadisticaHoyo.neto.toString()));
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
               Text('Tee ${widget.tarjeta.teeSalida!.toString()} ', style: textStyle,),
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
                  onPressed:   widget.onSave,
                ),
              ),
              // Botón 'Comentar' con fondo circular
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.comment),
                  color: Colors.blue,
                  onPressed: (){},
                ),
              ),
              // Botón 'Estadísticas' con fondo circular
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, weight: 20,),
                  color: kPcontrastMoradoColor,
                  onPressed: widget.onBack,
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



 

getTarjeta() {
  

  
}
}