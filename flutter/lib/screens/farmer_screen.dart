import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'farmer_products_screen.dart';

class FarmerScreen extends StatefulWidget {
  final int userId;
  final String accountStatus;  // Account status passed from login

  const FarmerScreen({Key? key, required this.userId, required this.accountStatus}) : super(key: key);

  @override
  _FarmerScreenState createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = '', description = '', price = '', quantity = '', category = '';
  bool _isLoading = false;

  // The method to add a product
  Future<void> _addProduct() async {
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
          'farmer_id': widget.userId,  // Pass the userId (farmer's id)
        });

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Error: ${response['error']}")),
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
    // Disable the form if the account is pending or rejected
    bool isAccountAllowed = widget.accountStatus != 'pending' && widget.accountStatus != 'rejected';

    return Scaffold(
      appBar: AppBar(title: Text("Add Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Product Name"),
                  onSaved: (value) => name = value!,
                  validator: (value) =>
                  value!.isEmpty ? "Please enter product name" : null,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Description"),
                  onSaved: (value) => description = value!,
                  validator: (value) =>
                  value!.isEmpty ? "Please enter description" : null,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => price = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter price";
                    if (double.tryParse(value) == null) return "Enter a valid number";
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Quantity"),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => quantity = value!,
                  validator: (value) =>
                  value!.isEmpty ? "Please enter quantity" : null,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Category"),
                  onSaved: (value) => category = value!,
                ),
              ),
              // Add similar checks for the other fields
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading || !isAccountAllowed ? null : _addProduct,  // Disable button if account is not allowed
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text("Add Product"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FarmerProductsScreen(farmerId: widget.userId),
                    ),
                  );
                },
                child: Text("My products"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


