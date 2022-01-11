import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:basket_protocol/core/db/user_db.dart';
import 'package:basket_protocol/core/models/user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User> get user {
    return _auth.onAuthStateChanged.map<User>(convertFirebaseUserToUser);
  }

  User convertFirebaseUserToUser(FirebaseUser _user) {
    if (_user == null) return null;

    return User(
        id: _user.uid,
        name: _user.displayName,
        email: _user.email,
        isEmailVerified: _user.isEmailVerified);
  }

  Future<void> checkIfUserExistsInDBAndCreateIfNot(FirebaseUser user) async {
    bool _doesUserExists = await UserDB.doesUserExists(user.uid);
    if (!_doesUserExists) UserDB.createUserDocument(user);
  }

  Future<User> signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();

      checkIfUserExistsInDBAndCreateIfNot(result.user);

      return convertFirebaseUserToUser(result.user);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<User> signUpWithCredentials(String _email, String _password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);

      checkIfUserExistsInDBAndCreateIfNot(result.user);

      verifyUserEmail(result.user);
      return convertFirebaseUserToUser(result.user);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<User> signInWithCredentials(String _email, String _password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);

      checkIfUserExistsInDBAndCreateIfNot(result.user);

      return convertFirebaseUserToUser(result.user);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<User> signWithGoogle() async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();

      GoogleSignInAccount googleAccount = await _googleSignIn.signIn();

      GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      AuthCredential credentials = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      FirebaseUser _user = (await _auth.signInWithCredential(credentials)).user;

      checkIfUserExistsInDBAndCreateIfNot(_user);

      return convertFirebaseUserToUser(_user);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateUserName(FirebaseUser _user, String _name) async {
    try {
      UserUpdateInfo _userUpdateInfo = UserUpdateInfo();

      _userUpdateInfo.displayName = _name;

      _user.updateProfile(_userUpdateInfo);
      await _user.reload();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateUserEmail(FirebaseUser _user, String _email) async {
    try {
      UserDB.updateUserEmail(_user, _email);

      _user.updateEmail(_email);

      await _user.reload();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> verifyUserEmail(FirebaseUser _user) async {
    try {
      await _user.sendEmailVerification();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> resetPassword(String _email) async {
    try {
      await _auth.sendPasswordResetEmail(email: _email);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteAccount(FirebaseUser _user) async {
    try {
      await UserDB.deleteUserDocument(_user.uid);
      await _user.delete();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (error) {
      throw Exception(error);
    }
  }
}
