class LatLng {
  double latitude;
  double longitude;

  LatLng({
    required this.latitude,
    required this.longitude,
  });

  factory LatLng.defaultLatLng() {
    return LatLng(
      latitude: 37.5664056,
      longitude: 126.9778222,
    );
  }

  @override
  String toString() {
    return 'LatLng(latitude: $latitude, longitude: $longitude)';
  }
}
