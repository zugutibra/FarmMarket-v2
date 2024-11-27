import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  bool isSaving = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product['name']);
    descriptionController = TextEditingController(text: widget.product['description']);
    priceController = TextEditingController(text: widget.product['price'].toString());
    quantityController = TextEditingController(text: widget.product['quantity'].toString());
  }

  Future<void> saveProduct() async {
    setState(() => isSaving = true);

    final updatedProduct = {
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'quantity': quantityController.text, // Optional if you have this field
      'category': widget.product['category'], // Optional if you have this field
    };

    try {
      final apiService = ApiService();
      final response = await apiService.updateProduct(widget.product['id'], updatedProduct);

      Navigator.pop(context, response); // Pass updated product back
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSaving ? null : saveProduct,
              child: isSaving ? CircularProgressIndicator() : Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
