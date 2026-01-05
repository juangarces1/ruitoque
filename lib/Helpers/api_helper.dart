import 'dart:convert';

import 'package:ruitoque/Helpers/constans.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:http/http.dart' as http;
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/ronda_de_amigos.dart';

class ApiHelper {

 static Future<Response> updateHandicap(int id, int handicap) async {
  
  var url = Uri.parse('${Constans.getAPIUrl()}/api/Players/UpdateHandicap/$id');

  try {
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json', // Especificamos que el contenido es JSON
        'Accept': 'application/json',
      },
      body: json.encode(handicap), // Codificamos el handicap como JSON
    );

   if (response.statusCode == 200) {
          return Response(isSuccess: true);
    } else if (response.statusCode == 404) {
      // Jugador no encontrado
        return Response(isSuccess: false, message: 'Jugador No Encontrado', result: response.body);
    } else {
      // Otros errores
     Response(isSuccess: false, message: 'Error al actualizar el handicap: ${response.reasonPhrase}',result: response.body);
    }
       return Response(isSuccess: false);
  } catch (e) {
    // En caso de error, muestra el error
     return Response(isSuccess: false, message: "Exception: ${e.toString()}");
  }
}

   static Future<Response> getPlayers() async {
      var url = Uri.parse('${Constans.getAPIUrl()}/api/Players/GetPlayers');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Jugador> players = data.map((json) => Jugador.fromJson(json)).toList();
        return Response(isSuccess: true, result: players);
      } else {
        return Response(isSuccess: false, message: 'Error fetching players');
      }
    }

  

  static Future<Response> getRondasAbiertas(int id) async {
  final url = Uri.parse('${Constans.getAPIUrl()}/api/Rondas/GetRondasAbiertaByPlayer/$id');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<Ronda> rondas = data.map((json) => Ronda.fromJson(json)).toList();
    return Response(isSuccess: true, result: rondas);
  } else if (response.statusCode == 204) {
    // No Content: simplemente regresa lista vacía, no es error.
    return Response(isSuccess: true, result: <Ronda>[]);
  } else {
    return Response(isSuccess: false, message: 'Error fetching Rondas Abiertas: ${response.statusCode}');
  }
}

    
    static Future<Response> getFinishedRoundsByPlayer({
  required int playerId,
  required int page,
  int pageSize = 5,
}) async {
  final base = Constans.getAPIUrl();
  final uri  = Uri.parse(
    '$base/api/rondas/GetRondaTerminadasByPlayer/$playerId'
    '?page=$page&pageSize=$pageSize',
  );

  try {
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});

    if (resp.statusCode == 204) {
      return Response(isSuccess: true, result: <Ronda>[], totalCount: 0);
    }
    if (resp.statusCode != 200) {
      return Response(isSuccess: false, message: 'Error ${resp.statusCode}');
    }

    final total = int.tryParse(resp.headers['x-total-count'] ?? '') ?? 0;
    final list  = (jsonDecode(resp.body) as List)
        .map((e) => Ronda.fromJson(e))
        .toList();

    return Response(isSuccess: true, result: list, totalCount: total);
  } catch (e) {
    return Response(isSuccess: false, message: e.toString());
  }
}
  
 static Future<Response> post(String controller, Map<String, dynamic> request) async {        
    var url = Uri.parse('${Constans.getAPIUrl()}/$controller');
    var response = await http.post(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',       
      },
      body: jsonEncode(request)
    );    

    if(response.statusCode >= 400){
      return Response(isSuccess: false, message: response.body);
    }     
     return Response(isSuccess: true, result: response.body, );
  }

 static Future<Response> getCampo(String id) async {  
     var url = Uri.parse('${Constans.getAPIUrl()}/api/Campos/GetCampo/$id');
     try {
        var response = await http.get(
          url,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
          },
        );
      
         // Check for 200 OK response
           var body = response.body;
            if (response.statusCode >= 400) {
              return Response(isSuccess: false, message: body);
            }
           
            var decodedJson = jsonDecode(body);
               return Response(isSuccess: true, result: Campo.fromJson(decodedJson));  
                       
          
            

      } catch (e) {
        // Catch any other errors, like JSON parsing errors
       
        return Response(isSuccess: false, message: "Exception: ${e.toString()}");
      }
    
 } 

 static Future<Response> logIn(String id) async {  
     var url = Uri.parse('${Constans.getAPIUrl()}/api/Players/GetPlayerByPin/$id');
     try {
        var response = await http.get(
          url,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
          },
        );
      
         // Check for 200 OK response
           var body = response.body;
            if (response.statusCode >= 400) {
              return Response(isSuccess: false, message: body);
            }
           
            var decodedJson = jsonDecode(body);
               return Response(isSuccess: true, result: Jugador.fromJson(decodedJson));  
                       
          
            

      } catch (e) {
        // Catch any other errors, like JSON parsing errors
       
        return Response(isSuccess: false, message: "Exception: ${e.toString()}");
      }
    
 } 

static Future<Response> getTarjetasById(
  String id, {
  int page = 1,
  int pageSize = 5,
}) async {
  // Construye la URL con query parameters ?page=&pageSize=
  var url = Uri.parse(
    '${Constans.getAPIUrl()}/api/Tarjetas/GetTarjetasByPlayer/$id?page=$page&pageSize=$pageSize',
  );

  try {
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    var decodedJson = jsonDecode(body);

    return Response(
      isSuccess: true,
      result: Jugador.fromJson(decodedJson),
    );

  } catch (e) {
    return Response(
      isSuccess: false,
      message: "Exception: ${e.toString()}",
    );
  }
}

 static Future<Response> put(String controller, Map<String, dynamic> request) async {        
    var url = Uri.parse('${Constans.getAPIUrl()}/$controller');
    var response = await http.put(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }
    return Response(isSuccess: true, result: response.body);
  }

 static Future<Response> getCampos() async {  

    var url = Uri.parse('${Constans.getAPIUrl()}/api/Campos/GetCampos/');
     try {
        var response = await http.get(
          url,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
          },
        );
      
        // Check for 200 OK response
        if (response.statusCode == 200) {

          var decodedJson = jsonDecode(response.body);
          List<Campo> campos = [];
          for (var item in decodedJson){
            campos.add(Campo.fromJson(item));
          }
          return Response(isSuccess: true, result: campos);
        } else if (response.statusCode == 204) {
          // No content
          return Response(isSuccess: true, message: '', result: []);
        } else {
          // Handle other statuses, maybe something went wrong
          return Response(isSuccess: false, message: "Error: ${response.body}");
        }
      } catch (e) {
        // Catch any other errors, like JSON parsing errors
       
        return Response(isSuccess: false, message: "Exception: ${e.toString()}");
      }
 }


   static Future<Response> getRondaById(int id) async {  
     var url = Uri.parse('${Constans.getAPIUrl()}/api/Rondas/GetRonda/$id');
     try {
        var response = await http.get(
          url,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
          },
        );
      
         // Check for 200 OK response
           var body = response.body;
            if (response.statusCode >= 400) {
              return Response(isSuccess: false, message: body);
            }
           
            var decodedJson = jsonDecode(body);
             
            
             
               return Response(isSuccess: true, result: Ronda.fromJson(decodedJson));  
                       
          
            

      } catch (e) {
        // Catch any other errors, like JSON parsing errors
       
        return Response(isSuccess: false, message: "Exception: ${e.toString()}");
      }
    
 } 
 
static Future<Response> delete(String controller) async {
    final url = Uri.parse('${Constans.getAPIUrl()}$controller');
    try {
      final response = await http.delete(
        url,
        headers: {
          'accept': 'application/json',
        },
      );

      if (response.statusCode >= 400) {
        return Response(isSuccess: false, message: response.body);
      }
      return Response(isSuccess: true, result: response.body);
    } catch (e) {
      return Response(isSuccess: false, message: 'Error: $e');
    }
  }

  /*──────────────────────────────────────────────────────────────
   * RONDAS DE AMIGOS
   *─────────────────────────────────────────────────────────────*/

  /// Obtiene una RondaDeAmigos por ID con todos sus grupos
  static Future<Response> getRondaDeAmigosById(int id) async {
    var url = Uri.parse('${Constans.getAPIUrl()}/api/rondasdeamigos/$id');
    try {
      var response = await http.get(
        url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
      );

      var body = response.body;
      if (response.statusCode >= 400) {
        return Response(isSuccess: false, message: body);
      }

      var decodedJson = jsonDecode(body);
      return Response(isSuccess: true, result: RondaDeAmigos.fromJson(decodedJson));
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  /// Obtiene todas las RondasDeAmigos donde el jugador participa
  static Future<Response> getRondasDeAmigosByPlayer(int playerId) async {
    var url = Uri.parse('${Constans.getAPIUrl()}/api/rondasdeamigos/player/$playerId');
    try {
      var response = await http.get(
        url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return Response(isSuccess: true, result: <RondaDeAmigos>[]);
      }

      if (response.statusCode >= 400) {
        return Response(isSuccess: false, message: response.body);
      }

      var decodedJson = jsonDecode(response.body) as List;
      List<RondaDeAmigos> rondasDeAmigos =
          decodedJson.map((json) => RondaDeAmigos.fromJson(json)).toList();
      return Response(isSuccess: true, result: rondasDeAmigos);
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  /// Obtiene RondasDeAmigos abiertas (no completadas) donde el jugador participa
  static Future<Response> getRondasDeAmigosAbiertas(int playerId) async {
    var url = Uri.parse('${Constans.getAPIUrl()}/api/rondasdeamigos/abiertas/player/$playerId');
    try {
      var response = await http.get(
        url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return Response(isSuccess: true, result: <RondaDeAmigos>[]);
      }

      if (response.statusCode >= 400) {
        return Response(isSuccess: false, message: response.body);
      }

      var decodedJson = jsonDecode(response.body) as List;
      List<RondaDeAmigos> rondasDeAmigos =
          decodedJson.map((json) => RondaDeAmigos.fromJson(json)).toList();
      return Response(isSuccess: true, result: rondasDeAmigos);
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  /// Crea una nueva RondaDeAmigos
  static Future<Response> createRondaDeAmigos(RondaDeAmigos rondaDeAmigos) async {
    var url = Uri.parse('${Constans.getAPIUrl()}/api/rondasdeamigos');
    try {
      var response = await http.post(
        url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(rondaDeAmigos.toJson()),
      );

      if (response.statusCode >= 400) {
        return Response(isSuccess: false, message: response.body);
      }

      var decodedJson = jsonDecode(response.body);
      return Response(isSuccess: true, result: RondaDeAmigos.fromJson(decodedJson));
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  /// Actualiza una RondaDeAmigos existente
  static Future<Response> updateRondaDeAmigos(RondaDeAmigos rondaDeAmigos) async {
    var url = Uri.parse('${Constans.getAPIUrl()}/api/rondasdeamigos/${rondaDeAmigos.id}');
    try {
      var response = await http.put(
        url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(rondaDeAmigos.toJson()),
      );

      if (response.statusCode >= 400) {
        return Response(isSuccess: false, message: response.body);
      }

      return Response(isSuccess: true);
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  /// Elimina una RondaDeAmigos
  static Future<Response> deleteRondaDeAmigos(int id) async {
    var url = Uri.parse('${Constans.getAPIUrl()}/api/rondasdeamigos/$id');
    try {
      var response = await http.delete(
        url,
        headers: {
          'accept': 'application/json',
        },
      );

      if (response.statusCode >= 400) {
        return Response(isSuccess: false, message: response.body);
      }

      return Response(isSuccess: true);
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

 } 
