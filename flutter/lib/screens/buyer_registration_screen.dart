import 'package:flutter/material.dart';
import 'package:untitled/screens/buyer_screen.dart';
import '../services/api_service.dart';

class BuyerRegistrationScreen extends StatefulWidget {
  @override
  _BuyerRegistrationScreenState createState() => _BuyerRegistrationScreenState();
}

class _BuyerRegistrationScreenState extends State<BuyerRegistrationScreen> {
  final ApiService apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = '', email = '', password = '';

  Future<void> _registerFarmer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "password": password,
      };

      final response = await apiService.registerBuyer(data);
      if (response.containsKey('id')) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration Successful!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BuyerScreen(userId: response['id'],)),
        );
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response['error']}"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buyer Registration")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Name"),
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (value) => password = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerFarmer,
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
