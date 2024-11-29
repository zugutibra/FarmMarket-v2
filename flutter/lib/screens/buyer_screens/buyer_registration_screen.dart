import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'buyer_screen.dart';

class BuyerRegistrationScreen extends StatefulWidget {
  @override
  _BuyerRegistrationScreenState createState() => _BuyerRegistrationScreenState();
}

class _BuyerRegistrationScreenState extends State<BuyerRegistrationScreen> {
  final ApiService apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers to manage input fields
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String name = '', email = '', password = '';
  bool agreeToTerms = false;
  bool isPasswordVisible = false;
  bool isPasswordVisible2 = false;

  Future<void> _registerBuyer() async {
    if (_formKey.currentState!.validate() && agreeToTerms) {
      _formKey.currentState!.save();
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "password": _passwordController.text,
      };
      try {
        final response = await apiService.registerBuyer(data);
        if (response.containsKey('id')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration Successful!")),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerScreen(
                userId: response['id'],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response['error']}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } else if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must agree to the terms and conditions.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sign up",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Create an account to get started",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter your name" : null,
                  onSaved: (value) => name = value!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter your email" : null,
                  onSaved: (value) => email = value!,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible, // Toggle visibility
                  validator: (value) =>
                  value!.isEmpty ? "Please create a password" : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible2
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible2 = !isPasswordVisible2;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible2,
                  validator: (value) => value != _passwordController.text
                      ? "Passwords do not match"
                      : null,
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          agreeToTerms = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "I’ve read and agree with the ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Terms and Conditions",
                              style: TextStyle(color: Colors.blue),
                            ),
                            TextSpan(text: " and the "),
                            TextSpan(
                              text: "Privacy Policy.",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerBuyer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
