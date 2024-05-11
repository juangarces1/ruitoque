import 'dart:convert';

import 'package:ruitoque/Helpers/constans.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  
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
 
 } 
