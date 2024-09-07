import 'package:heavy_assistant/domain/entities/heavy_equipment_company.dart';
import 'package:heavy_assistant/domain/repositories/heavy_equipment_company_repository.dart';

class FindHeavyEquipmentCompanyUseCase {
  final HeavyEquipmentCompanyRepository repository;

  FindHeavyEquipmentCompanyUseCase(this.repository);

  Future<List<HeavyEquipmentCompany>> execute() async {
    return repository.getHeavyEquipmentCompanies();
  }
}
