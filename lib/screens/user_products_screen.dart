import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import '../screens/edit_product_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_product.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshProducts(BuildContext context) async {
      await Provider.of<Products>(context, listen: false).getProducts(filterByUser: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yours Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, response) => response.connectionState == ConnectionState.waiting
          ? Center(
            child: CircularProgressIndicator(),
          ) : RefreshIndicator(
            onRefresh: () {
              return _refreshProducts(context);
            },
            child: Consumer<Products>(
              builder: (context, products, child) => Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: products.items.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        UserProduct(products.items[index]),
                        Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
      ),
    );
  }
}