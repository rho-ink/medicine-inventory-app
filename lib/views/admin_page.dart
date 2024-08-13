import 'package:flutter/material.dart';
import 'package:admin_app/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for FirebaseDatabase and DataSnapshot
import 'package:firebase_core/firebase_core.dart';
import 'package:admin_app/controllers/user_provider.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _selectedRole = 'user'; // Default role
  final List<String> _roles = ['admin', 'apoteker', 'assistant', 'user'];
  final AuthController _authController = AuthController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newEmailController =
      TextEditingController(); // For email change

  List<Map<String, String>> _users = []; // List to store users

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // Fetch and check the user's role on initialization
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newEmailController.dispose(); // Dispose the new email controller
    super.dispose();
  }

  Future<void> _fetchUserRole() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      DataSnapshot snapshot = await userRef.get();
      print('User snapshot value: ${snapshot.value}');
      
      if (snapshot.exists) {
        String role = snapshot.child('role').value as String;
        print('User role: $role');
        
        // Set the role in UserProvider to maintain consistency
        UserProvider().setRole(role);
        
        if (role == 'admin') {
          _fetchUsers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Akses Dilarang.')),
          );
          Navigator.of(context).pop(); // Navigate back
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found in database.')),
        );
      }
    } catch (e) {
      print('Error fetching user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user role.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No user is currently logged in.')),
    );
  }
}



  Future<void> _fetchUsers() async {
    try {
      DataSnapshot snapshot =
          await FirebaseDatabase.instance.ref('users').get();
      print('User snapshot: ${snapshot.value}');

      if (snapshot.exists) {
        List<Map<String, String>> users = [];
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          users.add({
            'uid': key,
            'email': value['email'],
            'role': value['role'],
          });
        });

        setState(() {
          _users = users;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No users found.')),
        );
      }
    } on FirebaseException catch (e) {
      print('Firebase Exception: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.code == 'permission-denied'
                ? 'Access denied. You don\'t have permission to fetch users.'
                : 'Failed to fetch users from Database.')),
      );
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> _addUser() async {
    await _authController.addUser(
      _emailController.text,
      _passwordController.text,
      _selectedRole,
      context,
    );
    _fetchUsers(); // Refresh the user list
  }

  Future<void> _deleteUser(String uid) async {
    await _authController.deleteUser(uid, context);
    _fetchUsers(); // Refresh the user list
  }

  Future<void> _updateUserRole(String uid, String newRole) async {
    await _authController.updateUserRole(uid, newRole, context);
    _fetchUsers(); // Refresh the user list
  }

  Future<void> _updateUserEmail(String uid, String newEmail) async {
    await _authController.updateUserEmail(uid, newEmail, context);
    _fetchUsers(); // Refresh the user list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _selectedRole,
              onChanged: (newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              items: _roles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUser,
              child: Text('Tambah User'),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text(user['email'] ?? ''),
                    subtitle: Text('Role: ${user['role']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteUser(user['uid']!),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showRoleUpdateDialog(user['uid']!);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.email),
                          onPressed: () {
                            _showEmailUpdateDialog(
                                user['uid']!, user['email']!);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleUpdateDialog(String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newRole = _roles.first;
        return AlertDialog(
          title: Text('Update User Role'),
          content: DropdownButton<String>(
            value: newRole,
            onChanged: (String? value) {
              setState(() {
                newRole = value!;
              });
            },
            items: _roles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateUserRole(uid, newRole);
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEmailUpdateDialog(String uid, String currentEmail) {
    _newEmailController.text =
        currentEmail; // Set current email in the text field
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update User Email'),
          content: TextField(
            controller: _newEmailController,
            decoration: InputDecoration(labelText: 'New Email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateUserEmail(uid, _newEmailController.text);
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
