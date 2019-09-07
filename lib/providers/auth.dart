import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/exceptions.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId = '';
  Timer _authTimer;

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

  String get userId{
    return _userId;
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
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
     
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);

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
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);

    } catch (error){
      //Aqui tratamos erros da API, diferentes de status 200
      throw error;
    }

  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(_authTimer != null) { 
      _authTimer.cancel(); 
      _authTimer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();

  }

  void _autoLogout(){
    if(_authTimer != null) { _authTimer.cancel(); }

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);

  }

  Future<bool> tryAutoLogin() async {
    
    //Procura por token armazenado, e verifica se o mesmo é válido.
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())){
      return false;
    }

    //Se for válido, restaura os dados de login
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();

    return true;
  }

}
