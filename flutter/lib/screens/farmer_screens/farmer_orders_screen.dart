import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

import '../buyer_screens/buyer_orders_screen.dart';


class Product {
  final int id;
  final String name;
  final int quantity;

  Product({required this.id, required this.name, required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }
}
class FarmerOrdersScreen extends StatefulWidget {
  final int farmerId;

  const FarmerOrdersScreen({Key? key, required this.farmerId}) : super(key: key);

  @override
  _FarmerOrdersScreenState createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  late Future<List<Order>> _orders;
  List<Order> allOrders = [];
  List<Order> filteredOrders = [];
  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    _orders = ApiService().getFarmerOrders(widget.farmerId);
    _orders.then((orders) {
      setState(() {
        allOrders = orders;
        filteredOrders = orders;
      });
    });
  }

  void filterOrders(String status) {
    setState(() {
      selectedFilter = status;
      if (status == "all") {
        filteredOrders = allOrders;
      } else {
        filteredOrders = allOrders.where((order) => order.status == status).toList();
      }
    });
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
      case "accepted":
        return Colors.blue;
      case "delivery":
        return Colors.green;
      case "completed":
        return Colors.grey;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case "awaiting":
        return "accepted";
      case "accepted":
        return "delivery";
      case "delivery":
        return "completed";
      default:
        return "";
    }
  }


  Future<void> updateOrderStatus(
      int orderId, String newStatus, List<Product> orderedProducts) async {
    try {await ApiService().updateOrderStatus(orderId, newStatus);
    _fetchOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text("Farmer Orders"),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton("All", "all"),
                _buildFilterButton("Awaiting", "awaiting"),
                _buildFilterButton("Accepted", "accepted"),
                _buildFilterButton("Delivery", "delivery"),
                _buildFilterButton("Completed", "completed"),
                _buildFilterButton("Cancelled", "cancelled"),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _orders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (filteredOrders.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }

                return ListView.builder(
                  itemCount: filteredOrders.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildOrderCard(Order order) {
    String nextStatus = getNextStatus(order.status);

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
            Text(
              "Status: ${order.status}",
              style: TextStyle(
                color: getStatusColor(order.status),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

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
            if(order.status != 'cancelled')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => updateOrderStatus(order.id, 'cancelled', order.products.cast<Product>()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("Mark as Cancelled".toUpperCase()),
                  ),
                ],
              ),
            if (nextStatus.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => updateOrderStatus(order.id, nextStatus, order.products.cast<Product>()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getStatusColor(nextStatus),
                    ),
                    child: Text("Mark as $nextStatus".toUpperCase()),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterButton(String label, String status) {
    return GestureDetector(
      onTap: () => filterOrders(status),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selectedFilter == status ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectedFilter == status ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
