import 'dart:math';

class LocationUtils {
  /// Calculates distance between two points in Kilometers using Haversine formula
  static double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double radLat1 = _degreesToRadians(lat1);
    final double radLat2 = _degreesToRadians(lat2);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(radLat1) * cos(radLat2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Formats distance in KM to human-readable string (e.g. 450 m or 3.2 KM)
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      final int meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} KM';
    }
  }

  /// Formats GPS accuracy in meters (e.g. ± 8.5 m)
  static String formatAccuracy(double accuracyInMeters) {
    if (accuracyInMeters <= 0) return 'Unknown';
    return '± ${accuracyInMeters.toStringAsFixed(1)} m';
  }

  /// Formats lat/lng coordinates to standard string
  static String formatCoordinates(double lat, double lng) {
    final String latDir = lat >= 0 ? 'N' : 'S';
    final String lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }
}
