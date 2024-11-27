import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<Map<String, dynamic>> registerFarmer(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/farmers/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Error during POST request: $e");
      throw e;
    }
  }
  Future<Map<String, dynamic>> updateProduct(int productId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$productId/update/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("Request URL: $baseUrl/products/$productId/update/");
      print("Request Body: ${jsonEncode(data)}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print("Error updating product: $e");
      throw Exception('Error updating product');
    }
  }

  Future<List<dynamic>> getFarmerProducts(int farmerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/farmer/products/$farmerId/'),
        headers: {"Content-Type": "application/json"},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Parse the JSON data from the response
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("Error fetching products: $e");
      throw Exception('Failed to load products for the farmer.');
    }
  }


  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_product/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAllProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
      headers: {"Content-Type": "application/json"},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> registerBuyer(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buyers/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print("Making POST request to $baseUrl/login/ with data: $email, $password");
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    print("Response body: ${response.body}");
    print("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['role'] == 'farmer') {
        print("Logged in as Farmer with ID: ${data['id']}");
        // Store account status
        return data;  // Return user data including account_status
      } else if (data['role'] == 'buyer') {
        print("Logged in as Buyer with ID: ${data['id']}");
      }
      return data;  // Return user data
    } else if (response.statusCode == 401) {
      throw Exception("Invalid credentials");
    } else {
      throw Exception("Failed to login. Status code: ${response.statusCode}");
    }
  }
}

