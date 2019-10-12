import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  final String baseUrl = 'https://study-flutter.firebaseio.com/products';
  final String favoriteUrl = 'https://study-flutter.firebaseio.com/userFavorites';
  final String url = 'https://study-flutter.firebaseio.com/products.json';
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  String addAuth(String url)
  {
    return '${url}?auth=${authToken}';
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> deleteProduct(String id) async {
    final deleteUrl = '${baseUrl}/${id}.json';
    final existingProductIndex = _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];
    
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(addAuth(deleteUrl));

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);

      notifyListeners();

      throw HttpException('Could not delete product');
    }

    existingProduct = null;

    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((product) => product.id == id);

    if (productIndex >= 0) {
      final patchUrl = '${baseUrl}/${id}.json';
      
      await http.patch(
        addAuth(patchUrl),
        body: json.encode({
          'title': newProduct.title,
          'price': newProduct.price,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
        }),
      );

      _items[productIndex] = newProduct;

      notifyListeners();
    }
  }

  Future<void> getProducts({bool filterByUser = false}) async {
    final filterString = filterByUser ? '&orderBy="creatorId"&equalTo="${userId}"' : '';

    try {
      final response = await http.get(addAuth(url) + filterString);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      if (extractedData == null) {
        return;
      }
      
      final favoriteResponse = await http.get(addAuth('${favoriteUrl}/${userId}.json'));
      final favoriteData = json.decode(favoriteResponse.body);
      
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: (favoriteData == null) ? false : favoriteData[productId] ?? false,
        ));
      });

      _items = loadedProducts;

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        addAuth(url),
        body: json.encode({
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
          'creatorId': userId,
        })
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}