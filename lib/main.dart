import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';

import './screens/products_overview.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/products_overview.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          builder: (context, auth, previousProduct) => Products(
            auth.token,
            auth.userId,
            previousProduct == null ? [] : previousProduct.items
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (context, auth, previousOrder) => Orders(
            auth.token,
            auth.userId,
            previousOrder == null ? [] : previousOrder.orders
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, authData, child) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: authData.isAuth
            ? ProductOverview()
            : FutureBuilder(
              future: authData.tryAutoLogin(),
              builder: (context, authResult) => (authResult.connectionState == ConnectionState.waiting)
                ? SplashScreen()
                : AuthScreen()
            ),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
            AuthScreen.routeName: (context) => AuthScreen(),
          },
        ),
      )
    );
  }
}