import 'package:firebase_auth/firebase_auth.dart';
import 'package:pcplus/services/pref_service.dart';
// import 'package:pcplus/models/users/user_repo.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PrefService _pref = PrefService();
  // final UserRepository _repo = UserRepository();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _pref.clearUserData();
    } catch (e) {
      throw Exception("Sign out failed: $e");
    }
  }

  // Sign in
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
     return await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
    } catch (e) {
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
      return credential;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool?> checkIfEmailExists(String emailAddress) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: '123456',
      );
      await credential.user?.delete();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      } else {
        return null;
      }
    } catch (e) {
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
        print("Password changed successfully.");
        return true;
      } else {
        print("No user is signed in.");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password is too weak.');
      } else if (e.code == 'requires-recent-login') {
        print('Please re-authenticate to change your password.');
      } else {
        print('Error: ${e.message}');
      }
      return false;
    }
  }
}