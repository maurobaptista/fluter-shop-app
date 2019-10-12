import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String baseUrl = 'https://study-flutter.firebaseio.com/orders';
  final String authToken;

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  String addAuth(String url)
  {
    return '${url}?auth=${authToken}';
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();

    final response = await http.post(
      addAuth('${baseUrl}.json'),
      body: json.encode({
        'amount': total,
        'products': cartProducts.map((product) => {
          'id': product.id,
          'title': product.title,
          'quantity': product.quantity,
          'price': product.price,
        }).toList(),
        'dateTime': timestamp.toIso8601String(),
      }),
    );

    _orders.insert(0, OrderItem(
      id: json.decode(response.body)['name'],
      amount: total,
      products: cartProducts,
      dateTime: timestamp,
    ));

    notifyListeners();
  }

  Future<void> getOrders() async {
    try {
      final response = await http.get(addAuth('${baseUrl}.json',));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];

      if (extractedData == null) {
        return;
      }

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
            .map((item) => CartItem(
              id: item['id'],
              title: item['title'],
              price: item['prices'],
              quantity: item['quantity'],
            )).toList(),
        ));
      });

      _orders = loadedOrders.reversed.toList();

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
