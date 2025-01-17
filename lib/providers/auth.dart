import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'dart:async';

import 'dart:convert';
import '../config/credentials.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  final String _api = Credentials.FIREBASE_WEB_API_KEY;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null
      && _expiryDate.isAfter(DateTime.now())
      && _token != null
    ) {
      return _token;
    }

    return null;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    final timeToExpiry =_expiryDate.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(
      Duration(
        seconds: timeToExpiry,
      ),
      logout
    );
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:${urlSegment}?key=${_api}';
    
    try {
      final response = await http.post(
        url,
        body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn'])
        ),
      );

      _autoLogout();

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });

      prefs.setString('userData', userData);
    } catch(error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (! prefs.containsKey('userData')) {
      return false;
    }

    final userData = json.decode(prefs.getString('userData')) as Map<String, Object>;

    if (DateTime.parse(userData['expiryDate']).isBefore(DateTime.now())) {
      return false;
    }

    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = DateTime.parse(userData['expiryDate']);

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');  
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}