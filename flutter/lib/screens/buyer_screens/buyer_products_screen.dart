import 'dart:convert';

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BuyerProductsScreen extends StatefulWidget {
  final int userId;

  const BuyerProductsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _BuyerProductsScreenState createState() => _BuyerProductsScreenState();
}

class _BuyerProductsScreenState extends State<BuyerProductsScreen> {
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedCategoryIndex = 0;

  final List<String> categories = [
    "All Products",
    "Fruits",
    "Vegetables",
    "Grains and Cereals",
    "Dairy Products",
    "Meat and Poultry",
    "Seafood",
    "Eggs",
    "Nuts and Seeds",
    "Organic Products",
  ];
  Map<String, String> categories_in_db = {
    "Fruits": "fruits",
    "Vegetables": "vegetables",
    "Grains and Cereals": "grains_and_cereals",
    "Dairy Products": "dairy_products",
    "Meat and Poultry": "meat_and_poultry",
    "Seafood": "seafood",
    "Eggs": "eggs",
    "Nuts and Seeds": "nuts_and_seeds",
    "Organic Products": "organic_products",
  };

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final apiService = ApiService();
      final fetchedProducts = await apiService.getAllProducts();

      setState(() {
        allProducts = fetchedProducts;
        filteredProducts = allProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "No products available in this category.";
        isLoading = false;
      });
    }
  }

  void filterProducts() {
    setState(() {
      if (selectedCategoryIndex == 0) {
        filteredProducts = allProducts;
      } else {
        String selectedCategory = categories[selectedCategoryIndex];
        filteredProducts = allProducts
            .where((product) => product['category'] == categories_in_db[selectedCategory])
            .toList();
      }
    });
  }

  Future<void> addToCart(dynamic product, int quantity) async {
    try {
      final apiService = ApiService();
      print({
        'user_id': widget.userId,
        'product_id': product['id'],
        'quantity': quantity,
      });

      final response = await apiService.addToCart({
        'user_id': widget.userId,
        'product_id': product['id'],
        'quantity': quantity,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add to cart: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add to cart: $e")),
      );
    }
  }



  void showQuantityDialog(dynamic product) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add ${product['name']} to Cart"),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Quantity"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  Navigator.pop(context);
                  addToCart(product, quantity);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid quantity")),
                  );
                }
              },
              child: const Text("Add to Cart"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text("Products"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.asMap().entries.map((entry) {
                int index = entry.key;
                String category = entry.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = index;
                      filterProducts();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedCategoryIndex == index ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selectedCategoryIndex == index ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : filteredProducts.isEmpty
                ? const Center(child: Text("No products available in this category."))
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(dynamic product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: Colors.grey[200],
              ),
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("T${product['price']}", style: const TextStyle(color: Colors.green)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => showQuantityDialog(product),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 30),
              ),
              child: const Text("Add to Cart"),
            ),
          ),
        ],
      ),
    );
  }
}
