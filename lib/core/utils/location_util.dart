import 'package:geolocator/geolocator.dart';
import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationUtil {
  final Logger logger = Logger();

  Future<LatLng> getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    logger
        .i("[getCurrentLocation] Current permission status: $permissionStatus");
    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        logger.i("[getCurrentLocation] Current location: $position");
        return LatLng(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        throw Exception("위치 정보를 가져오는데 실패했습니다.");
      }
    } else {
      throw Exception("위치 권한이 거부되었습니다.");
    }
  }
}
