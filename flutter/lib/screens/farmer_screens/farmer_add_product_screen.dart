import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FarmerAddProductScreen extends StatefulWidget {
  final int farmerId;
  final String accountStatus;


  const FarmerAddProductScreen({super.key, required this.accountStatus, required this.farmerId});

  @override
  _FarmerAddProductScreenState createState() => _FarmerAddProductScreenState();
}

class _FarmerAddProductScreenState extends State<FarmerAddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = '', description = '', price = '', quantity = '', category = '';
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

  Future<void> _addProduct() async {
    category = categories_in_db[categories[selectedCategoryIndex]]!;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        final response = await ApiService().addProduct({
          'name': name,
          'description': description,
          'price': price,
          'quantity': quantity,
          'category': category,
          'farmer': widget.farmerId,
        });

        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );

        if (response['success']) {
          _formKey.currentState!.reset();
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAccountAllowed = widget.accountStatus != 'pending' && widget.accountStatus != 'rejected';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text("Add New Product"),
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
                    if (!isAccountAllowed)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Your account is ${widget.accountStatus}. You cannot add products until it is approved.",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    _buildTextField("Name", (value) => name = value!),
                    _buildTextField("Price", (value) => price = value!, keyboardType: TextInputType.number),
                    _buildTextField("Quantity", (value) => quantity = value!, keyboardType: TextInputType.number),
                    _buildTextField("Description", (value) => description = value!),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading || !isAccountAllowed ? null : _addProduct,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50), backgroundColor: Colors.blue,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Add Product"),
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
  Widget _buildTextField(String label, Function(String?)? onSaved, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
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
