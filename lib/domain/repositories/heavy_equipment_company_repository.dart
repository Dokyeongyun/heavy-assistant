import 'package:heavy_assistant/domain/entities/heavy_equipment_company.dart';

abstract class HeavyEquipmentCompanyRepository {
  Future<List<HeavyEquipmentCompany>> getHeavyEquipmentCompanies();
}
