import 'dart:convert';
import 'package:http/http.dart' as http;

import '../screens/buyer_screens/buyer_orders_screen.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<List<Order>> getFarmerOrders(int farmerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/farmer/$farmerId/orders'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['orders'];
        return data.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            "Failed to update order status: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating order status: $e");
    }
  }

  Future<Map<String, dynamic>> registerFarmer(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/farmers/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateFarmerProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/farmer/${data['id']}/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBuyerProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/buyer/${data['id']}/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<Map<String, dynamic>> updateProduct(int productId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$productId/update/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      throw Exception('Error updating product');
    }
  }
  Future<Map<String, dynamic>> getBuyer({int? userId, String? email}) async {
    try {
      final Uri url = Uri.parse(userId != null
          ? '$baseUrl/buyer/$userId/'
          : '$baseUrl/buyer/?email=$email');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load buyer data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }


  Future<Map<String, dynamic>> getFarmer({int? farmerId, String? email}) async {
    try {
      final Uri url = Uri.parse(farmerId != null
          ? '$baseUrl/farmer/$farmerId/'
          : '$baseUrl/farmer/?email=$email');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load farmer data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<List<dynamic>> getFarmerProducts(int farmerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/farmer/products/$farmerId/'),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('No products available in this category..');
    }
  }

  Future<http.Response> placeOrderForAll(Map<String, dynamic> requestBody) async {
    final url = Uri.parse('$baseUrl/make-order/${requestBody['user_id']}/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to place orders: $e');
    }
  }
  Future<List<Order>> getBuyerOrders(int buyerId) async {
    final url = Uri.parse('$baseUrl/orders/$buyerId/');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> orderData = jsonDecode(response.body);
        List<Order> orders = (orderData['orders'] as List)
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
        return orders;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_product/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        responseBody['success'] = responseBody.containsKey('id');
        return responseBody;
      } else {
        return {
          'success': false,
          'message': 'Failed to add product. Status code: ${response.statusCode}.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
  Future<http.Response> deleteCartItem(int cartItemId) async {
    final url = Uri.parse('$baseUrl/cart/delete/$cartItemId/');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete cart item: ${response.body}');
    }
    return response;
  }
  Future<http.Response> addToCart(Map<String, dynamic> cartData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_to_cart/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(cartData),
      );
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to add to cart: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }
  Future<List<dynamic>> getBuyerCarts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carts/$userId/'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch carts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching carts: $e');
    }
  }


  Future<dynamic> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/'),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch products. Status code: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Error fetching products: $error");
    }
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
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception("Invalid credentials");
    } else {
      throw Exception("Failed to login. Status code: ${response.statusCode}");
    }
  }
}

