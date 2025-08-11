import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/service.dart';

class ServiceScreenHelper {
  // Mapping of screen names to Firebase category names
  static const Map<String, String> _screenToCategoryMap = {
    'beard_shave_grooming': 'Beard & Shave Grooming',
    'eyelash_extension': 'Eyelash & Extensions',
    'facial_men': 'Facial for Men',
    'facial_services': 'Facial Services',
    'hair_color_treatment': 'Hair Color & Treatment',
    'hair_extension': 'Hair Extensions',
    'hair_services': 'Hair Services',
    'haircut_men': 'Haircut for Men',
    'henna_makeup': 'Henna & Makeup',
    'massage_spa': 'Massage & Spa',
    'meni_padi': 'Mani Pedi',
    'nail_services': 'Nail Services',
    'wax_threading': 'Wax & Threading',
    'wax_trimming': 'Wax & Trimming',
  };

  // Get Firebase category name for a screen
  static String? getCategoryForScreen(String screenKey) {
    return _screenToCategoryMap[screenKey];
  }

  // Fetch services for a specific screen
  static Future<List<Service>> getServicesForScreen(String screenKey) async {
    final category = getCategoryForScreen(screenKey);
    if (category == null) {
      throw Exception('No category mapping found for screen: $screenKey');
    }
    
    try {
      final services = await FirebaseService.getServicesByCategory(category);
      // Filter only active services
      return services.where((service) => service.isActive).toList();
    } catch (e) {
      throw Exception('Error fetching services for $screenKey: $e');
    }
  }

  // Convert Firebase service to screen service format
  static Map<String, dynamic> convertServiceToScreenFormat(Service service) {
    return {
      'id': service.id,
      'title': service.name,
      'subtitle': '${service.duration} mins',
      'price': service.price,
      'description': service.description,
      'image': service.imageBase64 != null ? _getImageWidget(service.imageBase64!) : null,
      'imageBase64': service.imageBase64,
    };
  }

  // Convert list of Firebase services to screen format
  static List<Map<String, dynamic>> convertServicesToScreenFormat(List<Service> services) {
    return services.map((service) => convertServiceToScreenFormat(service)).toList();
  }

  // Helper method to create image widget from base64
  static Widget? _getImageWidget(String base64String) {
    try {
      // Handle different base64 formats
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      
      final Uint8List bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
        ),
      );
    }
  }

  // Get image widget for service
  static Widget getServiceImage(Map<String, dynamic> service) {
    if (service['imageBase64'] != null) {
      final imageWidget = _getImageWidget(service['imageBase64']);
      if (imageWidget != null) {
        return imageWidget;
      }
    }
    
    // Fallback to default image
    return Image.asset(
      'images/styling.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.spa,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  // Parse duration from subtitle for cart functionality
  static int parseDuration(String subtitle) {
    final regex = RegExp(r'(\d+)');
    final matches = regex.allMatches(subtitle);
    if (matches.isNotEmpty) {
      return int.parse(matches.first.group(1)!);
    }
    return 0;
  }

  // Convert service to cart item format
  static Map<String, dynamic> convertToCartItem(Map<String, dynamic> service) {
    return {
      'name': service['title'],
      'price': service['price'],
      'duration': parseDuration(service['subtitle']),
      'time': service['subtitle'],
      'branch': 'Main Branch',
    };
  }
}