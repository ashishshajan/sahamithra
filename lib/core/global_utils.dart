import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalUtils {
  // Singleton instance
  static final GlobalUtils _instance = GlobalUtils._internal();

  factory GlobalUtils() {
    return _instance;
  }

  GlobalUtils._internal();

  static late SharedPreferences _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String _keyToken = 'token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyParentName = 'parent_name';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyIsLoggedIn = 'is_logged_in';
  
  // Child Details Keys
  static const String _keyChildId = 'child_id';
  static const String _keyChildName = 'child_name';
  static const String _keyChildGender = 'child_gender';
  static const String _keyChildDob = 'child_dob';
  static const String _keyChildAge = 'child_age';
  static const String _keyChildAgeGroup = 'child_age_group';

  // User Data Key (Stores entire init response)
  static const String _keyUserData = 'user_data';

  // Getters
  String? get token => _prefs.getString(_keyToken);
  String? get refreshToken => _prefs.getString(_keyRefreshToken);
  int? get userId => _prefs.getInt(_keyUserId);
  String? get parentName => _prefs.getString(_keyParentName);
  String? get phoneNumber => _prefs.getString(_keyPhoneNumber);
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  
  int? get childId => _prefs.getInt(_keyChildId);
  String? get childName => _prefs.getString(_keyChildName);
  String? get childGender => _prefs.getString(_keyChildGender);
  String? get childDob => _prefs.getString(_keyChildDob);
  int? get childAge => _prefs.getInt(_keyChildAge);
  String? get childAgeGroup => _prefs.getString(_keyChildAgeGroup);

  Map<String, dynamic>? get userData {
    final data = _prefs.getString(_keyUserData);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // Setters
  Future<void> setToken(String value) async => await _prefs.setString(_keyToken, value);
  Future<void> setRefreshToken(String value) async => await _prefs.setString(_keyRefreshToken, value);
  Future<void> setUserId(int value) async => await _prefs.setInt(_keyUserId, value);
  Future<void> setParentName(String value) async => await _prefs.setString(_keyParentName, value);
  Future<void> setPhoneNumber(String value) async => await _prefs.setString(_keyPhoneNumber, value);
  Future<void> setLoggedIn(bool value) async => await _prefs.setBool(_keyIsLoggedIn, value);
  
  Future<void> setChildId(int value) async => await _prefs.setInt(_keyChildId, value);
  Future<void> setChildName(String value) async => await _prefs.setString(_keyChildName, value);
  Future<void> setChildGender(String value) async => await _prefs.setString(_keyChildGender, value);
  Future<void> setChildDob(String value) async => await _prefs.setString(_keyChildDob, value);
  Future<void> setChildAge(int value) async => await _prefs.setInt(_keyChildAge, value);
  Future<void> setChildAgeGroup(String value) async => await _prefs.setString(_keyChildAgeGroup, value);

  Future<void> setUserData(Map<String, dynamic> value) async {
    await _prefs.setString(_keyUserData, jsonEncode(value));
  }

  // Clear session data (Logout)
  Future<void> logout() async {
    await _prefs.clear();
    await _prefs.setBool(_keyIsLoggedIn, false);
  }

  // Generic methods for other keys
  Future<void> setString(String key, String value) async => await _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);
  
  Future<void> setInt(String key, int value) async => await _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setBool(String key, bool value) async => await _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> remove(String key) async => await _prefs.remove(key);
}
