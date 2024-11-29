import 'package:flutter/material.dart';
import 'package:untitled/screens/buyer_screens/buyer_products_screen.dart';

import 'buyer_cart_screen.dart';
import 'buyer_profile_screen.dart';


class BuyerScreen extends StatefulWidget {
  final int userId;

  const BuyerScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  int _currentIndex = 0; // Current tab index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        backgroundColor: Colors.white, // Background color of the navigation bar
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Products";
      case 1:
        return "Cart";
      case 2:
        return "Orders";
      case 3:
        return "Profile";
      default:
        return "Farmer Screen";
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return BuyerProductsScreen(
          userId: widget.userId,
        );
      case 1:
        return CartPage(
          userId: widget.userId,
        );
      case 2:
        return CartPage(
          userId: widget.userId,
        );
      case 3:
      return BuyerProfileScreen(
        userId: widget.userId,
      );
      default:
        return Center(child: Text("Error loading page"));
    }
  }
}
