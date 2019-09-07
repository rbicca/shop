import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken = '';
  String userId;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://sktodo.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);

    //print(json.decode(response.body));

    final List<OrderItem> loadedOrders = [];
    final data = json.decode(response.body) as Map<String, dynamic>;

    if(data == null) { 
      _orders = loadedOrders;
      notifyListeners();
      return; 
    }

    data.forEach((id, fields) {
      loadedOrders.add(OrderItem(
        id: id,
        amount: fields['amount'],
        dateTime: DateTime.parse(fields['dateTime']),
        products: (fields['products'] as List<dynamic>).map( (item) => 
          CartItem(id:item['id'],
            price: item['price'],
            quantity: item['quantity'],
            title: item['title'],
          )
        ).toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final url = 'https://sktodo.firebaseio.com/orders/$userId.json?auth=$authToken';

    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp),
    );
    notifyListeners();
  }
}
