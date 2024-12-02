import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CartItem {
  final int id;
  final String productName;
  final int amount;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.productName,
    required this.amount,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productName: json['product_name'],
      amount: json['amount'],
      totalPrice: json['total_price'] is String
          ? double.parse(json['total_price'])
          : json['total_price'],
    );
  }
}

class CartPage extends StatefulWidget {
  final int userId;

  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItem>> _carts;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _carts = _fetchBuyerCarts(widget.userId);
  }

  Future<List<CartItem>> _fetchBuyerCarts(int userId) async {
    final ApiService apiService = ApiService();
    final List<dynamic> cartData = await apiService.getBuyerCarts(userId);
    final cartItems = cartData.map((data) => CartItem.fromJson(data)).toList();
    setState(() {
      totalPrice = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    });

    return cartItems;
  }

  Future<void> _deleteCartItem(int cartItemId) async {
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.deleteCartItem(cartItemId);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully!")),
        );
        setState(() {
          _carts = _fetchBuyerCarts(widget.userId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete item: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting item: $e")),
      );
    }
  }

  Future<void> placeOrderForAll() async {
      try {
        final ApiService apiService = ApiService();
        final response = await apiService.placeOrderForAll({'user_id': widget.userId});

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("All orders placed successfully!")),
          );

          setState(() {
            _carts = _fetchBuyerCarts(widget.userId);
            totalPrice = 0.0;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to place orders: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error placing orders: $e")),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text('Your Cart'),
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _carts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final carts = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: carts.length,
                  itemBuilder: (context, index) {
                    final cart = carts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cart.productName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Amount: ${cart.amount}",
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    "Price: T${cart.totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteCartItem(cart.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Price:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "T${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: placeOrderForAll,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Order All"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
