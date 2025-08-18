import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? gender,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Store additional user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'message': 'Failed to create user'};
      }
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: ${e.toString()}'};
    }
  }



  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: ${e.toString()}'};
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        await updateUserData(user.uid, {'email': newEmail});
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: ${e.toString()}');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  // Update display name
  Future<void> updateDisplayName(String newName) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await updateUserData(user.uid, {'name': newName});
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      throw Exception('Failed to update display name: ${e.toString()}');
    }
  }

  // Get current user's gender
  Future<String?> getCurrentUserGender() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userData = await getUserData(user.uid);
        return userData?['gender'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete the user account
        await user.delete();
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticateUser(String password) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        throw Exception('No user is currently signed in or email is null');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to re-authenticate: ${e.toString()}');
    }
  }

  // Get auth error message
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }

  // Handle Firebase Auth exceptions (for backward compatibility)
  String _handleAuthException(FirebaseAuthException e) {
    return _getAuthErrorMessage(e);
  }
}