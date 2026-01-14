import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Get current position with permission handling
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Convert coordinates to human-readable address
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Format: "Street, Locality, City"
        final parts = <String>[];
        if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          parts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
      }
    } catch (e) {
      // Geocoding failed, return coordinates
      return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
    }
    return 'Unknown Location';
  }

  /// Get both position and address in one call
  Future<LocationResult> getCurrentLocationWithAddress() async {
    final position = await getCurrentPosition();
    if (position == null) {
      return LocationResult(
        address: 'Location unavailable',
        latitude: null,
        longitude: null,
      );
    }

    final address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return LocationResult(
      address: address,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

class LocationResult {
  final String address;
  final double? latitude;
  final double? longitude;

  LocationResult({
    required this.address,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
