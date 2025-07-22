import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart'; // Import the logger package

class FirebaseUtil {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Logger _logger = Logger(); // Initialize logger

  // Get current authenticated user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Email/Password Sign Up
  static Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the specific FirebaseAuthException so calling widgets can handle it
      rethrow;
    } catch (e) {
      // Catch any other general errors
      _logger.e("Error during email sign up: $e"); // Use logger.e for error
      throw Exception("Failed to sign up with email: $e");
    }
  }

  // Email/Password Sign In
  static Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the specific FirebaseAuthException
      rethrow;
    } catch (e) {
      _logger.e("Error during email sign in: $e"); // Use logger.e for error
      throw Exception("Failed to sign in with email: $e");
    }
  }

  // Google Sign In
  static Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Google Sign-In aborted by user',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      _logger.e("Error during Google sign in: $e"); // Use logger.e for error
      throw Exception("Failed to sign in with Google: $e");
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // Also sign out from Google if signed in via Google
    } catch (e) {
      _logger.e("Error during sign out: $e"); // Use logger.e for error
      throw Exception("Failed to sign out: $e");
    }
  }

  // Store User Data in Firestore
  static Future<void> storeUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData, SetOptions(merge: true));
    } catch (e) {
      _logger.e("Error storing user data: $e"); // Use logger.e for error
      throw Exception("Failed to store user data: $e");
    }
  }

  // Get User Data from Firestore
  static Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      _logger.e("Error getting user data: $e"); // Use logger.e for error
      throw Exception("Failed to get user data: $e");
    }
  }
}