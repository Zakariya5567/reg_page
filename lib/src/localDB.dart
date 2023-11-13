import 'package:shared_preferences/shared_preferences.dart';

class LocalDB{

  static String bearerTokenKey = "BearerToken";
  static String endDateKey = "endDateKey";
  static String firstTimeLoginKey = "firstTimerLogin";

  static Future<SharedPreferences?> get getPref async {
    // Initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences;
  }

  // Set bearer token
  static Future<void> storeEndDate(String value) async {
    // initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Store bearer token in shared preferences
    sharedPreferences.setString(endDateKey, value);
  }

  // Get bearer token
  static Future<String?> get getEndDate async {
    // Initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Get the bearer token which we have stored in sharedPreferences before
    String? bearerToken = sharedPreferences.getString(endDateKey);
    return bearerToken;
  }


  // Set bearer token
  static Future<void> storeBearerToken(String value) async {
    // initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Store bearer token in shared preferences
    sharedPreferences.setString(bearerTokenKey, value);
  }

  // Get bearer token
  static Future<String?> get getBearerToken async {
    // Initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Get the bearer token which we have stored in sharedPreferences before
    String? bearerToken = sharedPreferences.getString(bearerTokenKey);
    return bearerToken;
  }



  // Set bearer token
  static Future<void> storeFirstTimeLogin(bool value) async {
    // initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Store bearer token in shared preferences
    sharedPreferences.setBool(firstTimeLoginKey, value);
  }

  // Get bearer token
  static Future<bool?> get getFirstTimeLogin async {
    // Initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Get the bearer token which we have stored in sharedPreferences before
    bool? login = sharedPreferences.getBool(firstTimeLoginKey);
    return login;
  }


  // Clear bearer token
  static Future<void> clearLocalDB() async {
    // Initialized shared preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Get the bearer token which we have stored in sharedPreferences before
    await  sharedPreferences.clear();
  }

}