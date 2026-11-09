import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/tee.dart';

/// Importa campos desde OpenStreetMap (datos © colaboradores de OpenStreetMap, ODbL).
///
/// Un campo solo trae hoyos si algún voluntario los dibujó: muchos tienen nada
/// más que el contorno. Por eso el resultado es un borrador que se revisa en el
/// editor antes de guardarlo, y [BorradorCampo] dice qué tan completo vino.

/// OpenStreetMap pide que cada app se identifique.
const _cabeceras = {'User-Agent': 'RuitoqueGolfApp/1.0'};

/// Un campo de golf encontrado en el buscador.
class CampoOsm {
  final String nombre;
  final String descripcion;
  final double sur, norte, oeste, este;

  /// 'way' o 'relation'; con [osmId] identifica el contorno del campo.
  final String osmTipo;
  final int osmId;

  const CampoOsm({
    required this.nombre,
    required this.descripcion,
    required this.sur,
    required this.norte,
    required this.oeste,
    required this.este,
    required this.osmTipo,
    required this.osmId,
  });
}

/// Campo armado a partir de lo que había en el mapa, sin guardar todavía.
class BorradorCampo {
  final Campo campo;

  /// Greens que venían dibujados; en los demás, frente y fondo quedan iguales al centro.
  final int greensConContorno;

  /// Cosas que hay que revisar a mano en el editor.
  final List<String> avisos;

  const BorradorCampo({required this.campo, required this.greensConContorno, required this.avisos});

  bool get sinHoyos => campo.hoyos.isEmpty;
}

/// Busca campos de golf por nombre o lugar ("Briceño", "Piedecuesta").
Future<List<CampoOsm>> buscarCamposOsm(String texto, {http.Client? cliente}) async {
  final c = cliente ?? http.Client();
  try {
    final vistos = <String>{};
    final campos = <CampoOsm>[];
    // "golf course X" encuentra por nombre; "golf courses near X", por ciudad.
    for (final consulta in ['golf course $texto', 'golf courses near $texto']) {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': consulta,
        'format': 'jsonv2',
        'limit': '15',
      });
      final r = await c.get(uri, headers: _cabeceras).timeout(const Duration(seconds: 25));
      if (r.statusCode != 200) {
        throw Exception('El buscador respondió ${r.statusCode}.');
      }
      for (final e in jsonDecode(utf8.decode(r.bodyBytes)) as List) {
        final campo = campoDesdeNominatim((e as Map).cast<String, dynamic>());
        if (campo != null && vistos.add('${campo.osmTipo}/${campo.osmId}')) campos.add(campo);
      }
      if (campos.isNotEmpty) break;
      // El buscador admite una consulta por segundo.
      await Future.delayed(const Duration(milliseconds: 1100));
    }
    return campos;
  } finally {
    if (cliente == null) c.close();
  }
}

/// Null si el resultado no es un campo de golf (el buscador también devuelve
/// hoteles, calles y barrios con "golf" en el nombre).
CampoOsm? campoDesdeNominatim(Map<String, dynamic> e) {
  if (e['category'] != 'leisure' || e['type'] != 'golf_course') return null;
  final caja = (e['boundingbox'] as List?)?.map((v) => double.tryParse('$v')).toList();
  final id = e['osm_id'];
  if (caja == null || caja.length != 4 || caja.contains(null) || id is! int) return null;
  final completo = '${e['display_name'] ?? ''}';
  final nombre = '${e['name'] ?? ''}'.trim();
  return CampoOsm(
    nombre: nombre.isNotEmpty ? nombre : 'Campo sin nombre',
    descripcion: completo,
    sur: caja[0]!,
    norte: caja[1]!,
    oeste: caja[2]!,
    este: caja[3]!,
    osmTipo: '${e['osm_type']}',
    osmId: id,
  );
}

/// Descarga lo dibujado dentro del campo y arma el borrador.
Future<BorradorCampo> importarCampoOsm(CampoOsm campo, {http.Client? cliente}) async {
  final c = cliente ?? http.Client();
  try {
    // Margen de ~50 m: los tees a veces quedan justo sobre el borde.
    const m = 0.0005;
    final uri = Uri.https('api.openstreetmap.org', '/api/0.6/map.json', {
      'bbox': '${campo.oeste - m},${campo.sur - m},${campo.este + m},${campo.norte + m}',
    });
    final r = await c.get(uri, headers: _cabeceras).timeout(const Duration(seconds: 60));
    if (r.statusCode != 200) {
      throw Exception('OpenStreetMap respondió ${r.statusCode}.');
    }
    return armarBorrador(jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>, campo);
  } finally {
    if (cliente == null) c.close();
  }
}

/// Convierte la respuesta de OpenStreetMap en un [Campo] con ids en 0.
///
/// En OpenStreetMap un hoyo es una línea del tee al green (`golf=hole`) con su
/// número (`ref`) y par; el green (`golf=green`) es un polígono aparte.
BorradorCampo armarBorrador(Map<String, dynamic> datos, CampoOsm campo, {String colorSalida = 'Blanco'}) {
  final nodos = <int, _P>{};
  final lineas = <Map<String, dynamic>>[];
  for (final e in (datos['elements'] as List? ?? const [])) {
    final el = (e as Map).cast<String, dynamic>();
    if (el['type'] == 'node') {
      nodos[el['id'] as int] = _P((el['lat'] as num).toDouble(), (el['lon'] as num).toDouble());
    } else if (el['type'] == 'way') {
      lineas.add(el);
    }
  }

  List<_P> puntos(Map<String, dynamic> linea) =>
      [for (final id in (linea['nodes'] as List? ?? const [])) if (nodos[id] != null) nodos[id]!];
  Map<String, dynamic> etiquetas(Map<String, dynamic> el) =>
      ((el['tags'] as Map?) ?? const {}).cast<String, dynamic>();

  // Contorno del campo, para no traer hoyos de un campo vecino.
  List<_P>? contorno;
  if (campo.osmTipo == 'way') {
    for (final l in lineas) {
      if (l['id'] == campo.osmId) contorno = puntos(l);
    }
  }
  bool dentro(_P p) {
    if (contorno != null && contorno.length >= 4) return _dentroDe(contorno, p);
    return p.lat >= campo.sur && p.lat <= campo.norte && p.lon >= campo.oeste && p.lon <= campo.este;
  }

  final greens = [
    for (final l in lineas)
      if (etiquetas(l)['golf'] == 'green' && puntos(l).length >= 4) puntos(l),
  ];

  final hoyos = <int, Hoyo>{};
  final avisos = <String>[];
  var sinNumero = 0, repetidos = 0, sinPar = 0, sinHandicap = 0, conContorno = 0;

  for (final l in lineas) {
    final t = etiquetas(l);
    if (t['golf'] != 'hole') continue;
    final ruta = puntos(l);
    if (ruta.length < 2) continue;
    // Un hoyo puede salir del contorno; cuenta si el tee o el green caen dentro.
    if (!dentro(ruta.first) && !dentro(ruta.last)) continue;

    final numero = int.tryParse('${t['ref'] ?? ''}'.trim());
    if (numero == null) {
      sinNumero++;
      continue;
    }
    if (hoyos.containsKey(numero)) {
      repetidos++;
      continue;
    }

    final par = int.tryParse('${t['par'] ?? ''}'.trim());
    if (par == null) sinPar++;
    final handicap = int.tryParse('${t['handicap'] ?? ''}'.trim());
    if (handicap == null) sinHandicap++;

    // Green: el polígono que contiene el final de la línea, o el más cercano.
    final fin = ruta.last;
    List<_P>? green;
    var mejor = 50.0; // metros
    for (final g in greens) {
      if (_dentroDe(g, fin)) {
        green = g;
        break;
      }
      final d = _metros(_centroide(g), fin);
      if (d < mejor) {
        mejor = d;
        green = g;
      }
    }

    var centro = fin, frente = fin, fondo = fin;
    if (green != null) {
      conContorno++;
      centro = _centroide(green);
      // Frente y fondo: donde la línea de llegada al green corta su borde.
      final cortes = _cortesConEje(green, centro, ruta[ruta.length - 2]);
      frente = cortes.$1;
      fondo = cortes.$2;
    }

    final camino = [...ruta.sublist(0, ruta.length - 1), centro];
    final yardas = (_largo(camino) * 1.09361).round();

    hoyos[numero] = Hoyo(
      id: 0,
      numero: numero,
      nombre: '${t['name'] ?? ''}'.trim().isNotEmpty ? '${t['name']}'.trim() : 'Hoyo $numero',
      par: par ?? 4,
      campoId: 0,
      // Sin handicap el cálculo neto falla; 0 es el mismo valor que pone el editor.
      handicap: handicap ?? 0,
      frenteGreen: frente.cordenada,
      centroGreen: centro.cordenada,
      fondoGreen: fondo.cordenada,
      centroHoyo: _centroDelHoyo(camino).cordenada,
      hoyotees: [
        HoyoTee(
          id: 0,
          hoyoId: 0,
          color: colorSalida,
          cordenada: ruta.first.cordenada,
          distancia: yardas,
          cordenadaId: 0,
        ),
      ],
    );
  }

  final lista = hoyos.values.toList()..sort((a, b) => a.numero.compareTo(b.numero));

  if (lista.isNotEmpty) {
    avisos.add('Solo viene una salida por hoyo; se guardó como "$colorSalida". Revisa el color y agrega las demás.');
    final sinContorno = lista.length - conContorno;
    if (sinContorno > 0) {
      avisos.add('$sinContorno hoyos no tienen el green dibujado: frente y fondo quedaron iguales al centro.');
    }
    if (sinPar > 0) avisos.add('$sinPar hoyos no traían par: quedaron en par 4.');
    if (sinHandicap > 0) avisos.add('$sinHandicap hoyos no traían handicap: quedaron en 0.');
    if (repetidos > 0) {
      avisos.add('Se omitieron $repetidos hoyos con número repetido (el campo tiene más de un recorrido).');
    }
    if (sinNumero > 0) avisos.add('Se omitieron $sinNumero hoyos sin número.');
  }

  return BorradorCampo(
    campo: Campo(
      id: 0,
      nombre: campo.nombre,
      ubicacion: _ubicacionCorta(campo.descripcion),
      hoyos: lista,
      tees: lista.isEmpty ? [] : [Tee(id: 0, campoId: 0, color: colorSalida)],
    ),
    greensConContorno: conContorno,
    avisos: avisos,
  );
}

/// "Briceño 18, Variante…, Sopó, Sabana Centro, Cundinamarca, …, Colombia" → "Sopó, Colombia".
String _ubicacionCorta(String descripcion) {
  final partes = descripcion.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  if (partes.length < 3) return partes.join(', ');
  // Se saltan nombre y calle; los códigos postales no sirven como lugar.
  final lugar = partes.skip(2).firstWhere((p) => int.tryParse(p) == null, orElse: () => partes[1]);
  return lugar == partes.last ? lugar : '$lugar, ${partes.last}';
}

// ───────────────────────── geometría ─────────────────────────
// A escala de un campo de golf la Tierra se trata como plana: metros al norte
// y al este de un punto de referencia.

class _P {
  final double lat, lon;
  const _P(this.lat, this.lon);

  Cordenada get cordenada => Cordenada(id: 0, latitud: lat, longitud: lon);
}

const _metrosPorGrado = 111320.0;

(double, double) _xy(_P p, _P ref) => (
      (p.lon - ref.lon) * _metrosPorGrado * math.cos(ref.lat * math.pi / 180),
      (p.lat - ref.lat) * _metrosPorGrado,
    );

_P _desdeXy(double x, double y, _P ref) => _P(
      ref.lat + y / _metrosPorGrado,
      ref.lon + x / (_metrosPorGrado * math.cos(ref.lat * math.pi / 180)),
    );

double _metros(_P a, _P b) {
  final (x, y) = _xy(b, a);
  return math.sqrt(x * x + y * y);
}

double _largo(List<_P> camino) {
  var total = 0.0;
  for (var i = 1; i < camino.length; i++) {
    total += _metros(camino[i - 1], camino[i]);
  }
  return total;
}

_P _centroide(List<_P> poligono) {
  final ref = poligono.first;
  var area = 0.0, cx = 0.0, cy = 0.0;
  for (var i = 0; i < poligono.length - 1; i++) {
    final (x1, y1) = _xy(poligono[i], ref);
    final (x2, y2) = _xy(poligono[i + 1], ref);
    final cruz = x1 * y2 - x2 * y1;
    area += cruz;
    cx += (x1 + x2) * cruz;
    cy += (y1 + y2) * cruz;
  }
  if (area.abs() < 1e-9) return ref;
  return _desdeXy(cx / (3 * area), cy / (3 * area), ref);
}

bool _dentroDe(List<_P> poligono, _P p) {
  var dentro = false;
  for (var i = 0, j = poligono.length - 1; i < poligono.length; j = i++) {
    final a = poligono[i], b = poligono[j];
    if ((a.lat > p.lat) != (b.lat > p.lat) &&
        p.lon < (b.lon - a.lon) * (p.lat - a.lat) / (b.lat - a.lat) + a.lon) {
      dentro = !dentro;
    }
  }
  return dentro;
}

/// Puntos donde la recta [desde]→[centro] corta el borde del polígono: el más
/// cercano a [desde] (frente del green) y el más lejano (fondo).
(_P, _P) _cortesConEje(List<_P> poligono, _P centro, _P desde) {
  final (ax, ay) = _xy(desde, centro);
  final largo = math.sqrt(ax * ax + ay * ay);
  if (largo < 1e-6) return (centro, centro);
  // Dirección de juego: de [desde] hacia el centro, que es el origen.
  final dx = -ax / largo, dy = -ay / largo;

  double? minimo, maximo;
  for (var i = 0; i < poligono.length - 1; i++) {
    final (x1, y1) = _xy(poligono[i], centro);
    final (x2, y2) = _xy(poligono[i + 1], centro);
    final ex = x2 - x1, ey = y2 - y1;
    final det = ex * dy - ey * dx;
    if (det.abs() < 1e-9) continue; // borde paralelo a la línea de juego
    final s = (x1 * dy - y1 * dx) / -det; // posición sobre el borde, 0..1
    if (s < 0 || s > 1) continue;
    final t = (x1 + ex * s) * dx + (y1 + ey * s) * dy; // metros sobre la línea de juego
    if (minimo == null || t < minimo) minimo = t;
    if (maximo == null || t > maximo) maximo = t;
  }
  if (minimo == null || maximo == null) return (centro, centro);
  return (_desdeXy(dx * minimo, dy * minimo, centro), _desdeXy(dx * maximo, dy * maximo, centro));
}

/// Punto de referencia a mitad del hoyo: el quiebre del dogleg si la línea lo
/// trae, o la mitad exacta del recorrido si es recta.
_P _centroDelHoyo(List<_P> camino) {
  final mitad = _largo(camino) / 2;
  if (camino.length > 2) {
    var mejor = camino[1];
    var diferencia = double.infinity;
    var recorrido = 0.0;
    for (var i = 1; i < camino.length - 1; i++) {
      recorrido += _metros(camino[i - 1], camino[i]);
      if ((recorrido - mitad).abs() < diferencia) {
        diferencia = (recorrido - mitad).abs();
        mejor = camino[i];
      }
    }
    return mejor;
  }
  return _P((camino.first.lat + camino.last.lat) / 2, (camino.first.lon + camino.last.lon) / 2);
}
