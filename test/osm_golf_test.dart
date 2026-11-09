import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Helpers/osm_golf.dart';

// Campo de mentira cerca del ecuador: 0.001° ≈ 111 m en ambos ejes.
const _campo = CampoOsm(
  nombre: 'Club de Prueba',
  descripcion: 'Club de Prueba, Calle 1, Sopó, Cundinamarca, 251001, Colombia',
  sur: 0,
  norte: 0.01,
  oeste: 0,
  este: 0.01,
  osmTipo: 'way',
  osmId: 100,
);

Map<String, dynamic> _nodo(int id, double lat, double lon) => {'type': 'node', 'id': id, 'lat': lat, 'lon': lon};

Map<String, dynamic> _linea(int id, List<int> nodos, Map<String, String> tags) =>
    {'type': 'way', 'id': id, 'nodes': nodos, 'tags': tags};

Map<String, dynamic> _datos() => {
      'elements': [
        // contorno del campo
        _nodo(1, 0, 0), _nodo(2, 0, 0.01), _nodo(3, 0.01, 0.01), _nodo(4, 0.01, 0),
        _linea(100, [1, 2, 3, 4, 1], {'leisure': 'golf_course'}),

        // hoyo 1: par 4 con dogleg, juega hacia el norte y termina dentro de un green dibujado
        _nodo(10, 0.001, 0.002), _nodo(11, 0.003, 0.002), _nodo(12, 0.004, 0.002),
        _linea(200, [10, 11, 12], {'golf': 'hole', 'ref': '1', 'par': '4', 'handicap': '7', 'name': 'El Roble'}),
        // green cuadrado de ~22 m centrado en (0.004, 0.002)
        _nodo(20, 0.0039, 0.0019), _nodo(21, 0.0039, 0.0021), _nodo(22, 0.0041, 0.0021), _nodo(23, 0.0041, 0.0019),
        _linea(201, [20, 21, 22, 23, 20], {'golf': 'green'}),

        // hoyo 2: par 3 recto, sin green dibujado ni handicap
        _nodo(30, 0.006, 0.005), _nodo(31, 0.006, 0.0065),
        _linea(202, [30, 31], {'golf': 'hole', 'ref': '2', 'par': '3'}),

        // no deben entrar: repetido, sin número y de un campo vecino
        _linea(203, [30, 31], {'golf': 'hole', 'ref': '2', 'par': '5'}),
        _linea(204, [30, 31], {'golf': 'hole', 'par': '4'}),
        _nodo(40, 0.02, 0.02), _nodo(41, 0.021, 0.02),
        _linea(205, [40, 41], {'golf': 'hole', 'ref': '3', 'par': '4'}),
      ],
    };

void main() {
  test('arma los hoyos numerados del campo y deja fuera los que no sirven', () {
    final b = armarBorrador(_datos(), _campo);

    expect(b.campo.nombre, 'Club de Prueba');
    expect(b.campo.ubicacion, 'Sopó, Colombia');
    expect(b.campo.hoyos.map((h) => h.numero), [1, 2]);
    expect(b.campo.tees.single.color, 'Blanco');
    expect(b.greensConContorno, 1);
    expect(b.avisos.join('\n'), allOf(contains('repetido'), contains('sin número'), contains('handicap')));
  });

  test('con el green dibujado saca centro, frente y fondo sobre la línea de juego', () {
    final h = armarBorrador(_datos(), _campo).campo.hoyos.first;

    expect(h.nombre, 'El Roble');
    expect(h.par, 4);
    expect(h.handicap, 7);
    expect(h.centroGreen!.latitud, closeTo(0.004, 1e-6));
    expect(h.centroGreen!.longitud, closeTo(0.002, 1e-6));
    // Se juega hacia el norte: el frente es el borde sur del green y el fondo el norte.
    expect(h.frenteGreen!.latitud, closeTo(0.0039, 1e-6));
    expect(h.fondoGreen!.latitud, closeTo(0.0041, 1e-6));
    expect(h.frenteGreen!.longitud, closeTo(0.002, 1e-6));
    // El punto medio es el quiebre del dogleg que traía la línea.
    expect(h.centroHoyo!.latitud, closeTo(0.003, 1e-9));
  });

  test('la salida es el inicio de la línea y la distancia va en yardas', () {
    final h = armarBorrador(_datos(), _campo).campo.hoyos.first;
    final salida = h.hoyotees!.single;

    expect(salida.cordenada.latitud, 0.001);
    expect(salida.color, 'Blanco');
    // 0.003° de latitud ≈ 334 m ≈ 365 yardas.
    expect(salida.distancia, inInclusiveRange(363, 367));
  });

  test('sin green dibujado, frente y fondo quedan en el final de la línea', () {
    final h = armarBorrador(_datos(), _campo).campo.hoyos.last;

    expect(h.par, 3);
    expect(h.handicap, 0);
    expect(h.centroGreen!.longitud, 0.0065);
    expect(h.frenteGreen!.longitud, 0.0065);
    expect(h.fondoGreen!.longitud, 0.0065);
    expect(h.centroHoyo!.longitud, closeTo(0.00575, 1e-9));
  });

  test('un campo con solo el contorno da un borrador sin hoyos', () {
    final b = armarBorrador({
      'elements': [
        _nodo(1, 0, 0), _nodo(2, 0, 0.01), _nodo(3, 0.01, 0.01), _nodo(4, 0.01, 0),
        _linea(100, [1, 2, 3, 4, 1], {'leisure': 'golf_course'}),
      ],
    }, _campo);

    expect(b.sinHoyos, isTrue);
    expect(b.campo.tees, isEmpty);
    expect(b.avisos, isEmpty);
  });

  test('del buscador solo se aceptan campos de golf', () {
    Map<String, dynamic> resultado(String categoria, String tipo) => {
          'category': categoria,
          'type': tipo,
          'osm_type': 'way',
          'osm_id': 5,
          'name': 'Briceño 18',
          'display_name': 'Briceño 18, Variante, Sopó, Colombia',
          'boundingbox': ['4.93', '4.94', '-73.98', '-73.96'],
        };

    final campo = campoDesdeNominatim(resultado('leisure', 'golf_course'))!;
    expect(campo.nombre, 'Briceño 18');
    expect([campo.sur, campo.norte, campo.oeste, campo.este], [4.93, 4.94, -73.98, -73.96]);
    expect(campoDesdeNominatim(resultado('tourism', 'hotel')), isNull);
    expect(campoDesdeNominatim(resultado('highway', 'unclassified')), isNull);
  });
}
