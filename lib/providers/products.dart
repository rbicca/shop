import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop/models/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  //var _showFavoritesOnly = false;

  var _authToken = '';
  var _userId = '';

  set authToken(String value){
    _authToken = value;
  }

  set userId(String value){
    _userId = value;
  }

  List<Product> get items {
    //if(_showFavoritesOnly){
    //  return _items.where((p) => p.isFavorite).toList();
    //} else {
    return [..._items];
    //}
  }

  List<Product> get favoriteItems {
    return _items.where((p) => p.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }


  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    print('O parametr é' + filterByUser.toString());
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"': '';
    var url = 'https://sktodo.firebaseio.com/products.json?auth=$_authToken&$filterString';
    print('O filtro é $filterString');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if(data == null) { return; }

      url = 'https://sktodo.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];


      data.forEach((key, value){
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          isFavorite:  favoriteData == null ? false : favoriteData[key] ?? false,
          imageUrl: value['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();

    } catch (error){
      throw (error);
    }
  }

  Future<void> addProduct(Product value) async {
    final url = 'https://sktodo.firebaseio.com/products.json?auth=$_authToken';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': value.title,
          'description': value.description,
          'imageUrl': value.imageUrl,
          'price': value.price,
          'creatorId': _userId,
        }),
      );

      print(json.decode(response.body));
      // {name: -LmqpfCQVHW_KJ2MEBnS}

      final newProduct = Product(
        title: value.title,
        description: value.description,
        price: value.price,
        imageUrl: value.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
      
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {

      final url = 'https://sktodo.firebaseio.com/products/$id.json?auth=$_authToken';

      http.patch(url, body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,                 
      }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('Isso não deveria ter acontecido');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://sktodo.firebaseio.com/products/$id.json?auth=$_authToken';

    //Exemplo de delete otimista
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    print(response.statusCode);
    if(response.statusCode >= 400){
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
  
  // void showFavoritesOnly(){
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

}
