import 'package:flutter/material.dart';
import 'package:untitled/screens/login_screen.dart';
import '../../services/api_service.dart';

class FarmerProfileScreen extends StatefulWidget {
  final int farmerId;
  final String accountStatus;

  const FarmerProfileScreen({Key? key, required this.farmerId, required this.accountStatus}) : super(key: key);

  @override
  _FarmerProfileScreenState createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  late Future<Map<String, dynamic>> farmerData;
  final _formKey = GlobalKey<FormState>();
  String _name = '', _email = '', _farmName = '', _farmLocation = '', _status = '';

  @override
  void initState() {
    super.initState();
    // Fetch farmer data from API
    farmerData = ApiService().getFarmer(farmerId: widget.farmerId);
  }

  // Method to handle profile update
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final response = await ApiService().updateFarmerProfile({
        'id': widget.farmerId,
        'name': _name,
        'email': _email,
        'farm_name': _farmName,
        'farm_location': _farmLocation,
        'account_status': widget.accountStatus,
      });

      // Debug the response
      print('Response: $response');

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['message']}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: (

                ) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LoginScreen(),
                ),
              );
              // Handle logout functionality here
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: farmerData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final farmer = snapshot.data!;
            _name = farmer['name'];
            _email = farmer['email'];
            _farmName = farmer['farm_name'];
            _farmLocation = farmer['farm_location'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/default_avatar.jpg', // Replace with farmer image URL if available
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name, Email, Farm Name, and Farm Location as Editable Fields
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) {
                        _name = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _email,
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (value) {
                        _email = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        // You can add more validations for email format here
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _farmName,
                      decoration: InputDecoration(labelText: 'Farm Name'),
                      onChanged: (value) {
                        _farmName = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a farm name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _farmLocation,
                      decoration: InputDecoration(labelText: 'Farm Location'),
                      onChanged: (value) {
                        _farmLocation = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a farm location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Account Status Section
                    if (widget.accountStatus != 'approved')
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.red[50],
                        child: Text(
                          'Account Status: ${widget.accountStatus}',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      Text(
                        'Account Status: ${widget.accountStatus}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 20),

                    // Submit Changes Button
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Submit Changes'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
