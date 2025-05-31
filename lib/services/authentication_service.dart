// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:pcplus/models/users/user_repo.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Sign out failed: $e");
    }
  }

  // Sign in
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password, AuthResult authResult) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return credential;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        authResult.code = AuthResult.UserNotFound;
        authResult.text = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        authResult.code = AuthResult.WrongPassword;
        authResult.text = 'Invalid password';
      } else if (e.code == AuthResult.NetworkRequestFailed) {
        authResult.code = AuthResult.NetworkRequestFailed;
        authResult.text = 'Please check your internet connection';
      } else if (e.code == AuthResult.InvalidCredential) {
        authResult.code = AuthResult.InvalidCredential;
        authResult.text = e.message.toString();
      } else {
        authResult.code = e.code;
        authResult.text = e.message.toString();
      }
      return null;
    } catch (e) {
      authResult.code = AuthResult.UnknownError;
      authResult.text = e.toString();
      return null;
    }
  }

  // sign up
  Future<UserCredential?> signUpWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password.trim(),
      );
      // authResult.code = AuthResult.Success;
      return credential;
    // ignore: unused_catch_clause
    } on FirebaseAuthException catch (e) {
      // authResult.code = e.code;
      // authResult.text = e.code;
      return null;
    } catch (e) {
      // authResult.code = AuthResult.UnknownError;
      // authResult.text = e.toString();
      return null;
    }
  }



  Future<bool?> checkIfEmailExists(String emailAddress, AuthResult authResult) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: '123456',
      );
      await credential.user?.delete();
      authResult.code = AuthResult.Success;
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        authResult.code = AuthResult.Success;
        return true;
      } else {
        authResult.code = e.code;
        authResult.text = e.message.toString();
        return null;
      }
    } catch (e) {
      authResult.code = AuthResult.UnknownError;
      authResult.text = e.toString();
      return null;
    }
  }

  // send reset password email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this email.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format.';
      }
      return e.toString();
    }
  }

  // Change password
  Future<bool> changePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
        // authResult.code = AuthResult.Success;
        debugPrint("Password changed successfully.");
        return true;
      } else {
        // authResult.code = AuthResult.UnknownError;
        // authResult.text = "No user is signed in.";
        debugPrint("No user is signed in.");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // authResult.code = AuthResult.WeakPassword;
        // authResult.text = 'The password is too weak.';
        debugPrint('The password is too weak.');
      } else if (e.code == 'requires-recent-login') {
        // authResult.code = AuthResult.RequiresRecentLogin;
        // authResult.text = 'Please re-authenticate to change your password.';
        debugPrint('Please re-authenticate to change your password.');
      } else {
        // authResult.code = AuthResult.UnknownError;
        // authResult.text = '${e.message}';
        debugPrint('Error: ${e.message}');
      }
      return false;
    }
  }
}

class AuthResult {

  String code = "";
  String text = "";

  static String UserNotFound = 'user-not-found';
  static String EmailAlreadyInUse = 'email-already-in-use';
  static String InvalidEmail = 'invalid-email';
  static String WeakPassword = 'weak-password';
  static String RequiresRecentLogin = 'requires-recent-login';
  static String Success = 'success';
  static String UnknownError = 'unknown-error';
  static String WrongPassword = 'wrong-password';
  static String NetworkRequestFailed = 'network-request-failed';
  static String InvalidCredential = 'invalid-credential';
}