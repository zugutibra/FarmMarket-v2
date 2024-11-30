import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';


class Product {
  final int quantity;
  final String name;
  final double price;

  Product({
    required this.quantity,
    required this.name,
    required this.price,
  });

  // Update the fromJson constructor to handle id
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      quantity: json['quantity'],
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
}


class Order {
  final int id;
  final String orderDate;
  final double totalPrice;
  late final String status;
  final List<Product> products;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var productsJson = json['products'] as List;
    List<Product> productList = productsJson.map((i) => Product.fromJson(i)).toList();

    return Order(
      id: json['id'],
      orderDate: json['order_date'],
      totalPrice: json['total_price'].toDouble(),
      status: json['status'],
      products: productList,
    );
  }
}

class BuyerOrdersScreen extends StatefulWidget {
  final int userId;

  const BuyerOrdersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _BuyerOrdersScreenState createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  late Future<List<Order>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = ApiService().getBuyerOrders(widget.userId);
  }

  String formatDate(String dateString) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final DateTime dateTime = DateTime.parse(dateString);
    return formatter.format(dateTime);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "awaiting":
        return Colors.orange;
      case "delivery":
        return Colors.blue;
      case "delivered":
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Your Orders"),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Date
                      Text(
                        "Order ID: ${order.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Order Date: ${formatDate(order.orderDate)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Price: T${order.totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Order Status
                      Text(
                        "Status: ${order.status}",
                        style: TextStyle(
                          color: getStatusColor(order.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Products Section
                      const Text(
                        "Products:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: order.products.map((product) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${product.quantity}x ${product.name}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "T${(product.price * product.quantity).toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 14, color: Colors.green),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
