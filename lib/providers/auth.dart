import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> signup(String email, String password) async {
    const url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=[API_KEY]';
    
    http.post(url, json.parse({

    }));
  }
}