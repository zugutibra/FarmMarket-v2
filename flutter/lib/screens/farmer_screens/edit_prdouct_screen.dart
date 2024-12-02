import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String name, description, price, quantity, category;
  bool _isLoading = false;
  int selectedCategoryIndex = 0;

  final List<String> categories = [
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

  final Map<String, String> categoriesInDb = {
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
    name = widget.product['name'];
    description = widget.product['description'];
    price = widget.product['price'].toString();
    quantity = widget.product['quantity'].toString();
    category = widget.product['category'];
    selectedCategoryIndex =
        categories.indexWhere((cat) => categoriesInDb[cat] == category);
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final updatedProduct = {
        'id': widget.product['id'],
        'name': name,
        'description': description,
        'price': double.tryParse(price) ?? 0.0,
        'quantity': int.tryParse(quantity) ?? 0,
        'category': categoriesInDb[categories[selectedCategoryIndex]],
      };

      try {
        final response = await ApiService().updateProduct(widget.product['id'], updatedProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Product updated successfully')),
        );

        Navigator.pop(context, response);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Edit Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField("Name", (value) => name = value!, initialValue: name),
                    _buildTextField("Price", (value) => price = value!,
                        keyboardType: TextInputType.number, initialValue: price),
                    _buildTextField("Quantity", (value) => quantity = value!,
                        keyboardType: TextInputType.number, initialValue: quantity),
                    _buildTextField("Description", (value) => description = value!,
                        initialValue: description),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?)? onSaved,
      {TextInputType? keyboardType, required String initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        initialValue: initialValue,
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
