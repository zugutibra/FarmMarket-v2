import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_prdouct_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  final int farmerId;
  final String accountStatus;

  const FarmerProductsScreen({
    Key? key,
    required this.farmerId,
    required this.accountStatus,
  }) : super(key: key);

  @override
  _FarmerProductsScreenState createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
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
      final fetchedProducts = await apiService.getFarmerProducts(widget.farmerId);

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
        // Show all products for "All Products"
        filteredProducts = allProducts;
      } else {
        // Filter by category
        String selectedCategory = categories[selectedCategoryIndex];
        filteredProducts = allProducts
            .where((product) => product['category'] == categories_in_db[selectedCategory])
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,  // Match the image style
          title: const Text("My Products"),
        ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Row
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
                      filterProducts(); // Apply filter when a category is selected
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

          // Body Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : filteredProducts.isEmpty
                ? const Center(child: Text("No products available in this category."))
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(dynamic product) {
    return GestureDetector(
      onTap: () async {
        // Navigate to the EditProductScreen
        final updatedProduct = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProductScreen(product: product),
          ),
        );

        // If the product was updated, update it in the list
        if (updatedProduct != null) {
          setState(() {
            // Find the index of the edited product and update it
            final index = filteredProducts.indexWhere((p) => p['id'] == updatedProduct['id']);
            if (index != -1) {
              filteredProducts[index] = updatedProduct;
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                color: Colors.grey[200],
              ),
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),

            // Product Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Quantity: ${product['quantity']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Product Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "T${product['price']}",
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
