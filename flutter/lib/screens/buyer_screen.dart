import 'package:flutter/material.dart';

import '../services/api_service.dart';

class BuyerScreen extends StatefulWidget {
  final int userId;

  const BuyerScreen({Key? key, required this.userId}) : super(key: key);
  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  List products = []; // To store fetched products

  Future<void> _fetchProducts() async {
    // Call API to fetch all products
    final response = await ApiService().getAllProducts();
    if (response != null && response['success']) {
      setState(() {
        // Filter products where quantity is 100 or more
        products = response['products']
            .where((product) => product['quantity'] != null && product['quantity'] >= 100)
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching products")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: products.isEmpty
          ? Center(child: Text("No products available."))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              title: Text(product['name']),
              subtitle: Text(product['description']),
              trailing: Text("${product['price']} tenge"),
            ),
          );
        },
      ),
    );
  }
}
