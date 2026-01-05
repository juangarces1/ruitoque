class Constans {
    static String get remoteApi => 'http://kilosmedellin.com';
    static String get localAPI => 'http://10.0.2.2:5000';  // Para emulador Android
  //  static String get localAPI => 'http://192.168.1.165:5000';  // Para dispositivo físico
   //  static String get localAPI => 'http://localhost:5000';  // Para Windows desktop
    static String  getAPIUrl () {
      return localAPI;
    }
}