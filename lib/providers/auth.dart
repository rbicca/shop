import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/exceptions.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId = '';

  final String _key = 'AIzaSyCtDZQUMVwc9DyFL5UMhz2hRyJYswJbpqs';


  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null){
      return _token;
    }
    return null;
  }

  Future<void> signup(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_key';

    try {
      final response = await http.post(url, body: json.encode(
            {'email': email, 'password': password, 'returnSecureToken': true} ));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null){
        throw HtpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
     
    } catch(error){
      throw error;
    }


  }

 Future<void> login(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_key';

    try {
      final response = await http.post(url, body: json.encode(
            {'email': email, 'password': password, 'returnSecureToken': true} ));
      //O Firebase retorna status code 200, e eventuais erros dentro do corpo da resposta
      final responseData = json.decode(response.body);
      //print(responseData);
      if (responseData['error'] != null){
        throw HtpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();

    } catch (error){
      //Aqui tratamos erros da API, diferentes de status 200
      throw error;
    }

  }

}
