import 'package:flutter/material.dart';
import 'package:untitled/screens/farmer_screens/farmer_registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/buyer_screens/buyer_registration_screen.dart';

void main() {
  runApp(FarmerBuyerApp());
}

class FarmerBuyerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer & Buyer App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register/farmer': (context) => FarmerRegistrationScreen(),
        '/register/buyer': (context) => BuyerRegistrationScreen(),
      },
    );
  }
}
