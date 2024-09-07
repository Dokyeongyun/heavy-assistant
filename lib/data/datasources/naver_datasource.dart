import 'dart:convert';

import 'package:heavy_assistant/core/network/network_client.dart';
import 'package:heavy_assistant/core/utils/constants.dart';
import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:logger/logger.dart';

class NaverDatasource {
  final Logger logger = Logger();
  final NetworkClient networkClient;

  NaverDatasource(this.networkClient);

  Future<String?> findAddressFromLatLng(LatLng latlng) async {
    final response = await networkClient.get(
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${latlng.longitude},${latlng.latitude}&output=json',
      {
        'X-NCP-APIGW-API-KEY-ID': naverApiClientId,
        'X-NCP-APIGW-API-KEY': naverApiClientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];
      if (results.isEmpty) {
        return null;
      }

      final result = results[0];
      final area1Name = result['region']['area1']['alias'] ??
          result['region']['area1']['name'];
      final area2Name = result['region']['area2']['name'];
      final area3Name = result['region']['area3']['name'];

      final address = '$area1Name $area2Name $area3Name';
      return address;
    } else {
      return null;
    }
  }
}
