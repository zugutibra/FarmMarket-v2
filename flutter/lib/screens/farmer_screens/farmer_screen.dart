import 'package:flutter/material.dart';

import 'farmer_add_product_screen.dart';
import 'farmer_products_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerScreen extends StatefulWidget {
  final int farmerId;
  final String accountStatus; // Account status passed from login

  const FarmerScreen({Key? key, required this.farmerId, required this.accountStatus}) : super(key: key);

  @override
  _FarmerScreenState createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
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
            label: 'My Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Product',
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
        return "My Products";
      case 1:
        return "Add Product";
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
        return FarmerProductsScreen(
          farmerId: widget.farmerId,
          accountStatus: widget.accountStatus,
        );
      case 1:
        return FarmerAddProductScreen(
          farmerId: widget.farmerId,
          accountStatus: widget.accountStatus,
        );
      case 2:
        return FarmerProductsScreen(
          farmerId: widget.farmerId,
          accountStatus: widget.accountStatus,
        );
      case 3:
        return FarmerProfileScreen(
          farmerId: widget.farmerId,
          accountStatus: widget.accountStatus,
        );
      default:
        return Center(child: Text("Error loading page"));
    }
  }
}
