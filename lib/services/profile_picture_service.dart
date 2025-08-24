import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final ImagePicker _picker = ImagePicker();

  // Get current user's profile picture URL
  static Future<String?> getProfilePictureUrl() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      // If image doesn't exist or other error, return null
      return null;
    }
  }

  // Pick image from camera or gallery
  static Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Upload profile picture to Firebase Storage
  static Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      
      // Upload the file
      final uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Delete profile picture from Firebase Storage
  static Future<void> deleteProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      await ref.delete();
    } catch (e) {
      // If image doesn't exist, ignore the error
      if (!e.toString().contains('object-not-found')) {
        throw Exception('Failed to delete profile picture: $e');
      }
    }
  }

  // Show image source selection dialog
  static Future<ImageSource?> showImageSourceDialog(context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  // Complete flow: pick, upload and return URL
  static Future<String?> pickAndUploadProfilePicture(context) async {
    try {
      // Show source selection dialog
      final ImageSource? source = await showImageSourceDialog(context);
      if (source == null) return null;

      // Pick image
      final XFile? pickedFile = await pickImage(source: source);
      if (pickedFile == null) return null;

      // Upload image
      final File imageFile = File(pickedFile.path);
      final String downloadUrl = await uploadProfilePicture(imageFile);
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to pick and upload profile picture: $e');
    }
  }
}