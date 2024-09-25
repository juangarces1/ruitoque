import 'package:flutter/services.dart';

class WearCommunication {
  static const platform = MethodChannel('com.example.golf_app/communication');

  static Future<void> sendMessageToWatch(String message) async {
    try {
      await platform.invokeMethod('sendMessage', {'message': message});
    } on PlatformException catch (e) {
      print("Error al enviar mensaje: ${e.message}");
    }
  }
}
