import 'package:flutter/foundation.dart';

import './product.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;

    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });

    return total;
  }

  void removeItem(String productId) {
    _items.remove(productId);

    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId].quantity > 1) {
      _items.update(productId, (cart) => CartItem(
        id: cart.id,
        title: cart.title,
        price: cart.price,
        quantity: cart.quantity - 1,
      ));
      notifyListeners();
      
      return;
    }

    _items.remove(productId);
    notifyListeners();
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (cart) => CartItem(
        id: cart.id,
        title: cart.title,
        price: cart.price,
        quantity: cart.quantity + 1,
      ));

      notifyListeners();
      return;
    }

    _items.putIfAbsent(product.id, () => CartItem(
      id: DateTime.now().toString(),
      title: product.title,
      price: product.price,
      quantity: 1,
    ));

    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}