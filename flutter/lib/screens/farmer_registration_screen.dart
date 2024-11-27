import 'package:flutter/material.dart';
import 'package:untitled/screens/farmer_screen.dart';
import '../services/api_service.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  @override
  _FarmerRegistrationScreenState createState() => _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final ApiService apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = '', email = '', password = '', farmName = '', farmLocation = '';

  Future<void> _registerFarmer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "password": password,
        "farm_name": farmName,
        "farm_location": farmLocation,
      };
      try {
        final response = await apiService.registerFarmer(data);
        if (response.containsKey('id')) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Registration Successful!"))
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FarmerScreen(userId: response['id'], accountStatus: response['account_status'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${response['error']}"))
          );
        }
      } catch (e) {
        print("Error: $e"); // Debugging: Print any exceptions
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred: $e"))
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Farmer Registration")),
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
              TextFormField(
                decoration: InputDecoration(labelText: "Farm Name"),
                onSaved: (value) => farmName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Farm Location"),
                onSaved: (value) => farmLocation = value!,
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
