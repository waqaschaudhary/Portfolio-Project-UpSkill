import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  // Check if the user is authenticated
  void _checkUserAuthentication() {
    final user = _auth.currentUser;
    if (user == null) {
      // If the user is not logged in, navigate to the sign-in screen
      Navigator.pushReplacementNamed(context, '/signIn');
    } else {
      // Populate the fields with the user's current information
      _firstNameController.text = user.displayName?.split(' ').first ?? '';
      _lastNameController.text = user.displayName?.split(' ').last ?? '';
      _emailController.text = user.email ?? '';
      _imageUrl = user.photoURL; // Store the user's photo URL
    }
  }

  // Save the profile changes to Firebase
  void _saveProfileChanges() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        if (_imageFile != null) {
          // Upload image if new image is selected
          String imageUrl = await _uploadImage();
          await user.updatePhotoURL(imageUrl);
        }

        await user.updateDisplayName(
            "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}");
        await user.reload();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    }
  }

  // Log out the user
  void _logOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/signIn');
  }

  // Pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage() async {
    try {
      if (_imageFile == null) throw 'No image selected';

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = _storage.ref().child('profile_images/$fileName');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Image upload failed: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      // If the user is not logged in, show a loading spinner until the check is complete
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.purple[700],
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture with Image Upload Option
              GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple[300],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : user.photoURL != null
                          ? NetworkImage(user.photoURL!) as ImageProvider
                          : null,
                  child: _imageFile == null && user.photoURL == null
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              // Button to Upload Image (Camera or Gallery)
              ElevatedButton(
                onPressed: () async {
                  // Show a dialog for selecting Camera or Gallery
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Choose Image Source"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _pickImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                          child: Text("Camera"),
                        ),
                        TextButton(
                          onPressed: () {
                            _pickImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },
                          child: Text("Gallery"),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700], // Purple button
                  padding: EdgeInsets.symmetric(
                      vertical: 12, horizontal: 32), // Consistent size
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8)), // Rounded corners
                ),
                child: const Text(
                  'Upload Profile Image',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              // First Name Field
              TextField(
                controller: _firstNameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Colors.purple[800]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Last Name Field
              TextField(
                controller: _lastNameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: Colors.purple[800]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Email Field (Read-Only)
              TextField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.purple[800]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_isEditing) {
                        _saveProfileChanges();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700], // Purple button
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32), // Consistent size
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(_isEditing ? 'Save Changes' : 'Edit Profile',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _logOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.purple[700], // Purple logout button
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32), // Consistent size
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child:
                        Text('Log Out', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
