import 'dart:convert';

import 'package:heavy_assistant/core/network/network_client.dart';
import 'package:heavy_assistant/core/utils/constants.dart';
import 'package:heavy_assistant/domain/entities/heavy_equipment_company.dart';
import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:logger/logger.dart';

class NotionDatasource {
  final Logger logger = Logger();
  final NetworkClient client;

  NotionDatasource(this.client);

  Future<List<HeavyEquipmentCompany>> fetchHeavyEquipmentCompanies() async {
    try {
      final response = await client.post(
        'https://api.notion.com/v1/databases/40a9cb777f004f749c44001ab2c556f5/query',
        {'Notion-Version': '2022-06-28', 'Authorization': notionApiKey},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<dynamic> results = jsonData['results'];

        logger.d(
            "[fetchHeavyEquipmentCompanies] Loaded heavy equipment companies: ${results.length}");

        return results.map(
          (item) {
            final properties = item['properties'];

            String? phone;
            if (properties['phone'] != null &&
                properties['phone']['rich_text'] != null &&
                properties['phone']['rich_text'].isNotEmpty) {
              phone = properties['phone']['rich_text'][0]['plain_text'];
            } else {
              phone = null;
            }

            return HeavyEquipmentCompany(
              identifier: properties['identifier']['rich_text'][0]
                  ['plain_text'],
              companyName: properties['company_name']['title'][0]['plain_text'],
              address: properties['address']['rich_text'][0]['plain_text'],
              roadAddress: properties['road_address']['rich_text'][0]
                  ['plain_text'],
              location: LatLng(
                latitude: properties['latitude']['number'],
                longitude: properties['longitude']['number'],
              ),
              phone: phone,
              url: properties['url']['rich_text'][0]['plain_text'],
            );
          },
        ).toList();
      } else {
        throw Exception(
            '[fetchHeavyEquipmentCompanies] Failed to load heavy equipment companies. statusCode: ${response.statusCode}');
      }
    } catch (e) {
      logger.e(
          "[fetchHeavyEquipmentCompanies] Failed to load heavy equipment companies: $e");
      rethrow;
    }
  }
}
