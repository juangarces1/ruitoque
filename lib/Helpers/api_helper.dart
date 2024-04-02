import 'dart:convert';

import 'package:ruitoque/Helpers/constans.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:http/http.dart' as http;

class ApiHelper {

 static Future<Response> getCampo(String id) async {  
     var url = Uri.parse('${Constans.getAPIUrl()}/api/Hoyos/GetCampo/$id');
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
  } 
