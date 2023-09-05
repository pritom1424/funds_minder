import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
  Future<String> authenticateFAuth(
      String email, String password, bool didSignIn) async {
    var message = "";
    try {
      if (!didSignIn) {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      }
      notifyListeners();
      message = (didSignIn)
          ? "you have successfully logged in!"
          : "you have successfully created an account";
    } on FirebaseAuthException catch (err) {
      message = 'an error occured, please check your credentials';
      if (err.message!.isNotEmpty) {
        message = err.message!;
      }
    } catch (e) {
      message = 'something wrong! $e';
    }

    return message;
  }

  Future<String> signUpWithFAuth(String email, String pass) async {
    return authenticateFAuth(email, pass, false);
  }

  Future<String> signInWithFAuth(String email, String pass) async {
    return authenticateFAuth(email, pass, true);
  }

  Future<bool> isLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }
    return true;
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      notifyListeners();
    } catch (e) {
      throw ();
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
