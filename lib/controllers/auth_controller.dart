import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart'; // Import for SnackBar
import 'package:admin_app/controllers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<User?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Fetch user role from the database
        DataSnapshot snapshot =
            await _database.ref('users/${user.uid}/role').get();
        String role = snapshot.value as String;

        // Access UserProvider and set the role
        UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setRole(role);

        return user;
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific authentication errors
      switch (e.code) {
        case 'user-not-found':
          print('No user found for that email.');
          break;
        case 'wrong-password':
          print('Wrong password provided.');
          break;
        default:
          print('Authentication error: ${e.message}');
      }
    } catch (e) {
      print('An unexpected error occurred: ${e.toString()}');
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.clearRole(); // Clear role on logout
  }

  Future<void> addUser(
      String email,
      String password,
      String role,
      BuildContext context,
  ) async {
    try {
      // Create a new user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? newUser = result.user;

      if (newUser != null) {
        // Add the new user to Realtime Database
        await _database.ref('users/${newUser.uid}').set({
          'email': email,
          'role': role,
        });

        // Provide feedback to the admin
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User added successfully!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific authentication errors
      switch (e.code) {
        case 'email-already-in-use':
          print('The account already exists for that email.');
          break;
        case 'invalid-email':
          print('The email address is badly formatted.');
          break;
        case 'operation-not-allowed':
          print('Operation not allowed. Please enable the provider in the Firebase Console.');
          break;
        case 'weak-password':
          print('The password is too weak.');
          break;
        default:
          print('Authentication error: ${e.message}');
      }
    } catch (e) {
      print('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String uid, BuildContext context) async {
    try {
      User? user = _auth.currentUser;

      if (user != null && user.uid == uid) {
        // Delete user from Authentication
        await user.delete();
      }

      // Delete user from Realtime Database
      await _database.ref('users/$uid').remove();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully!')),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please re-authenticate and try again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user from Authentication.')),
        );
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Access denied. You don\'t have permission to delete this user.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user from Database.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<void> updateUserRole(String uid, String newRole, BuildContext context) async {
    try {
      await _database.ref('users/$uid').update({
        'role': newRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user role: $e')),
      );
    }
  }

  Future<void> updateUserEmail(String uid, String newEmail, BuildContext context) async {
    try {
      User? user = _auth.currentUser;

      if (user != null && user.uid == uid) {
        // Update the email in Firebase Authentication
        await user.updateEmail(newEmail);

        // Notify the user about the successful update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update email. User not authenticated.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email address.')),
        );
      } else if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please re-authenticate and try again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update email: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }
  
}
