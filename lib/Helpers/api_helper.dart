import 'dart:convert';

import 'package:ruitoque/Helpers/constans.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:http/http.dart' as http;
import 'package:ruitoque/Models/ronda.dart';

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
      var url = Uri.parse('${Constans.getAPIUrl()}/api/Rondas/GetRondasAbiertaByPlayer/$id');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Ronda> rondas = data.map((json) => Ronda.fromJson(json)).toList();
        return Response(isSuccess: true, result: rondas);
      } else {
        return Response(isSuccess: false, message: 'Error fetching Rondas Abiertas');
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

 static Future<Response> getTarjetasById(String id) async {  
     var url = Uri.parse('${Constans.getAPIUrl()}/api/Tarjetas/GetTarjetasByPlayer/$id');
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
 
 } 
