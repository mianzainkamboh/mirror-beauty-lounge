import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'models/branch.dart';
import 'app_colors.dart';

class BranchMapScreen extends StatefulWidget {
  final Branch branch;
  
  const BranchMapScreen({
    super.key,
    required this.branch,
  });

  @override
  State<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends State<BranchMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  double? _distanceInKm;
  bool _isLoading = true;
  String? _errorMessage;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _checkLocationPermission();
      if (_locationPermissionGranted) {
        await _getUserLocation();
      } else {
        _showBranchOnly();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load map: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      // Check current permission status
      ph.PermissionStatus status = await ph.Permission.location.status;
      
      if (status.isDenied) {
        // Request permission
        status = await ph.Permission.location.request();
      }
      
      if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        _showPermissionDialog();
        setState(() {
          _locationPermissionGranted = false;
        });
        return;
      }
      
      setState(() {
        _locationPermissionGranted = status.isGranted;
      });
      
      if (!status.isGranted) {
        _showLocationDeniedMessage();
      }
    } catch (e) {
      setState(() {
        _locationPermissionGranted = false;
        _errorMessage = 'Failed to check location permissions: ${e.toString()}';
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Location location = Location();
      
      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showLocationServiceDisabledMessage();
          _showBranchOnly();
          return;
        }
      }

      // Get current location with timeout
      final currentLoc = await location.getLocation().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Location request timed out. Please check your GPS signal.');
        },
      );
      
      if (currentLoc.latitude == null || currentLoc.longitude == null) {
        throw Exception('Invalid location data received');
      }

      setState(() {
        _currentPosition = LatLng(currentLoc.latitude!, currentLoc.longitude!);
        _addMarkers();
        _isLoading = false;
      });

      await _drawRoute();
      _calculateDistance();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _errorMessage = 'Failed to get your location: ${e.toString()}';
      });
      _showBranchOnly();
    }
  }

  void _showBranchOnly() {
    setState(() {
      _addBranchMarker();
      _isLoading = false;
    });
  }

  void _addMarkers() {
    _markers.clear();
    
    // Add user location marker
    if (_currentPosition != null) {
      _markers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'You are here',
        ),
      ));
    }
    
    _addBranchMarker();
  }

  void _addBranchMarker() {
    // Add branch marker
    _markers.add(Marker(
      markerId: MarkerId('branch_${widget.branch.id}'),
      position: widget.branch.coordinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: widget.branch.name,
        snippet: widget.branch.address,
      ),
    ));
  }

  Future<void> _drawRoute() async {
    if (_currentPosition == null) return;
    
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      const String googleApiKey = 'AIzaSyDgXI1n8YU4qN3UEa9zpobK8jRkWfZTRoI'; // Android key
      
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          destination: PointLatLng(widget.branch.coordinates.latitude, widget.branch.coordinates.longitude),
          mode: TravelMode.driving,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Route request timed out. Please check your internet connection.');
        },
      );

      if (result.points.isNotEmpty) {
        setState(() {
          _polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        });
      } else {
        print('No route points received from Google Directions API');
        _showRouteNotAvailableMessage();
      }
    } catch (e) {
      print('Error drawing route: $e');
      if (e.toString().contains('timeout') || e.toString().contains('network')) {
        _showNetworkErrorMessage();
      } else {
        _showRouteNotAvailableMessage();
      }
    }
  }

  void _calculateDistance() {
    if (_currentPosition == null) return;
    
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.branch.coordinates.latitude,
      widget.branch.coordinates.longitude,
    );
    setState(() {
      _distanceInKm = distance / 1000;
    });
  }

  Future<void> _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${widget.branch.coordinates.latitude},${widget.branch.coordinates.longitude}&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  Future<void> _callBranch() async {
    final url = 'tel:${widget.branch.phone}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make phone call')),
      );
    }
  }

  void _centerMapOnBranch() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.branch.coordinates,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _centerMapOnUser() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  // Error handling helper methods
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to show your position on the map and calculate distance to the branch. Please enable location permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ph.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location permission denied. Showing branch location only.'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            _checkLocationPermission();
          },
        ),
      ),
    );
  }

  void _showLocationServiceDisabledMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location services are disabled. Please enable GPS to see your location.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showNetworkErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Network error. Unable to load route directions.'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            _drawRoute();
          },
        ),
      ),
    );
  }

  void _showRouteNotAvailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route directions are not available for this location.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.branch.name),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading map...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.branch.name),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _initializeMap();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.branch.name,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callBranch,
            tooltip: 'Call Branch',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? widget.branch.coordinates,
              zoom: _currentPosition != null ? 12 : 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                // Fit both markers in view
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        [_currentPosition!.latitude, widget.branch.coordinates.latitude].reduce((a, b) => a < b ? a : b),
                        [_currentPosition!.longitude, widget.branch.coordinates.longitude].reduce((a, b) => a < b ? a : b),
                      ),
                      northeast: LatLng(
                        [_currentPosition!.latitude, widget.branch.coordinates.latitude].reduce((a, b) => a > b ? a : b),
                        [_currentPosition!.longitude, widget.branch.coordinates.longitude].reduce((a, b) => a > b ? a : b),
                      ),
                    ),
                    100.0,
                  ),
                );
              }
            },
            markers: _markers,
            polylines: _polylineCoordinates.isNotEmpty
                ? {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      color: AppColors.primaryColor,
                      width: 4,
                      points: _polylineCoordinates,
                    ),
                  }
                : {},
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: false,
          ),
          
          // Control buttons
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'branch_location',
                  onPressed: _centerMapOnBranch,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, color: AppColors.primaryColor),
                ),
                if (_currentPosition != null)
                  const SizedBox(height: 8),
                if (_currentPosition != null)
                  FloatingActionButton(
                    mini: true,
                    heroTag: 'user_location',
                    onPressed: _centerMapOnUser,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.my_location, color: AppColors.primaryColor),
                  ),
              ],
            ),
          ),
          
          // Branch information card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.branch.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_distanceInKm != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_distanceInKm!.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, 
                           size: 16, 
                           color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.branch.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, 
                           size: 16, 
                           color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.branch.phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openInGoogleMaps,
                          icon: const Icon(Icons.directions),
                          label: const Text('Get Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _callBranch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.phone),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
