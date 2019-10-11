import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/routes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).getOrders(),
        builder: (context, response) {
          if (response.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Consumer<Orders> (
            builder: (context, orders, child) => ListView.builder(
              itemCount: orders.orders.length,
              itemBuilder: (context, index) {
                return OrderItem(orders.orders[index]);
              },
            ),
          );
        },
      ),
    );
  }
}