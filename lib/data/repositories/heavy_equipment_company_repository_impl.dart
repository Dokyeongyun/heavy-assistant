import 'package:heavy_assistant/data/datasources/notion_datasource.dart';
import 'package:heavy_assistant/domain/entities/heavy_equipment_company.dart';
import 'package:heavy_assistant/domain/repositories/heavy_equipment_company_repository.dart';

class HeavyEquipmentCompanyRepositoryImpl
    implements HeavyEquipmentCompanyRepository {
  final NotionDatasource notionDatasource;

  HeavyEquipmentCompanyRepositoryImpl(this.notionDatasource);

  @override
  Future<List<HeavyEquipmentCompany>> getHeavyEquipmentCompanies() {
    return notionDatasource.fetchHeavyEquipmentCompanies();
  }
}
