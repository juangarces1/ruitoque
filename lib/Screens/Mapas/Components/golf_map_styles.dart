import 'package:flutter/services.dart' show rootBundle;

class GolfMapStyles {
  
  // ============================================
  // OPCIÓN 1: Estilo Minimalista (RECOMENDADO)
  // Vista limpia, solo lo esencial del campo
  // ============================================
  static String getMinimalistGolfStyle() {
    return '''
    [
      {
        "featureType": "poi",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.business",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.government",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.medical",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.place_of_worship",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.school",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.sports_complex",
        "elementType": "geometry",
        "stylers": [{ "visibility": "on" }]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road.local",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "transit",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "administrative",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "administrative.locality",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "administrative.neighborhood",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "landscape.man_made",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "water",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      }
    ]
    ''';
  }

  // ============================================
  // OPCIÓN 2: Estilo Ultra Limpio (EXTREMO)
  // Solo césped, agua y árboles, nada más
  // ============================================
  static String getUltraCleanGolfStyle() {
    return '''
    [
      {
        "featureType": "all",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "transit",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "administrative",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [{ "visibility": "on" }]
      },
      {
        "featureType": "landscape.natural",
        "elementType": "geometry",
        "stylers": [{ "visibility": "on" }]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{ "visibility": "on" }]
      }
    ]
    ''';
  }

  // ============================================
  // OPCIÓN 3: Estilo Profesional con caminos
  // Muestra caminos de golf cart sutilmente
  // ============================================
  static String getProfessionalGolfStyle() {
    return '''
    [
      {
        "featureType": "poi",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [{ "visibility": "on" }]
      },
      {
        "featureType": "road",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road.highway",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          { "visibility": "simplified" },
          { "color": "#e8e8e8" },
          { "weight": 1 }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [
          { "visibility": "on" },
          { "color": "#f0f0f0" },
          { "weight": 0.5 }
        ]
      },
      {
        "featureType": "transit",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "administrative",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "landscape.natural.terrain",
        "elementType": "geometry",
        "stylers": [
          { "visibility": "on" },
          { "saturation": 20 },
          { "lightness": 5 }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          { "color": "#4a9fd8" },
          { "visibility": "on" }
        ]
      }
    ]
    ''';
  }

  // ============================================
  // OPCIÓN 4: Modo Nocturno para golf
  // ============================================
  static String getNightGolfStyle() {
    return '''
    [
      {
        "featureType": "all",
        "elementType": "labels",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          { "color": "#2c2c2c" },
          { "visibility": "simplified" }
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [
          { "color": "#1a3d1a" },
          { "lightness": -20 }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          { "color": "#0a1f3d" }
        ]
      },
      {
        "featureType": "transit",
        "stylers": [{ "visibility": "off" }]
      }
    ]
    ''';
  }
}