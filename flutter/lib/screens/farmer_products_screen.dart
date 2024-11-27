import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import 'edit_prdouct_screen.dart'; // Import your ApiService

class FarmerProductsScreen extends StatefulWidget {
  final int farmerId;

  const FarmerProductsScreen({Key? key, required this.farmerId}) : super(key: key);

  @override
  _FarmerProductsScreenState createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Fetch products using ApiService
  Future<void> fetchProducts() async {
    try {
      final apiService = ApiService();
      final fetchedProducts = await apiService.getFarmerProducts(widget.farmerId);
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Products")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Show error message
              : products.isEmpty
                  ? Center(child: Text("No products available.")) // Show message when no products are available
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        print(product);
                        return ListTile(
                          title: Text(product['name']),
                          subtitle: Text(product['description']),
                          trailing: Text("₹${product['price']}"), // Display product price
                          onTap: () async {
                            final updatedProduct = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(product: product),
                              ),
                            );

                            if (updatedProduct != null) {
                              setState(() {
                                products[index] = updatedProduct; // Update the product in the list
                              });
                            }
                          },

                        );
                      },
                    ),
    );
  }
}
