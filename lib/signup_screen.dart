import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create the user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Update the user's displayName to include First and Last Name
      await userCredential.user?.updateDisplayName(
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}");

      // Navigate to Dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up Failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purple[700], // Purple AppBar color
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Avatar for Logo
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                    'images/RH.jpg', // Replace with your app logo path
                  ),
                  backgroundColor:
                      Colors.purple[100], // Light purple background
                ),
                SizedBox(height: 20),

                // App tagline
                Text(
                  'Uniting for Solutions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700], // Purple color for the text
                    fontStyle: FontStyle.normal,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // First Name input
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(
                        color: Colors.purple[700]), // Purple text color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple[700]!),
                    ),
                    border: UnderlineInputBorder(),
                    filled: true,
                    fillColor: Colors.purple[50],
                  ),
                ),
                SizedBox(height: 20),

                // Last Name input
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(
                        color: Colors.purple[700]), // Purple text color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple[700]!),
                    ),
                    border: UnderlineInputBorder(),
                    filled: true,
                    fillColor: Colors.purple[50],
                  ),
                ),
                SizedBox(height: 20),

                // Email input
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color: Colors.purple[700]), // Purple text color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple[700]!),
                    ),
                    border: UnderlineInputBorder(),
                    filled: true,
                    fillColor: Colors.purple[50],
                  ),
                ),
                SizedBox(height: 20),

                // Password input
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: Colors.purple[700]), // Purple text color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple[700]!),
                    ),
                    border: UnderlineInputBorder(),
                    filled: true,
                    fillColor: Colors.purple[50],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.purple[700], // Purple icon color
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Sign Up button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700], // Purple button color
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),

                // Navigate to sign in screen
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signIn');
                    },
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Colors.purple[700], // Purple text color
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
