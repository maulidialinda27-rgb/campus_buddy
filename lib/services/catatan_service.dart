
import 'package:campus_buddy/features/catatan/data/models/catatan_model.dart';
import 'package:campus_buddy/services/local_storage_service.dart';

class CatatanService {
  static const String _key = 'catatan_list';

  Future<List<CatatanModel>> getAllCatatan() async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    return list.map((m) => CatatanModel.fromMap(m)).toList();
  }

  Future<String> insertCatatan(CatatanModel catatan) async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    list.add(catatan.toMap());
    await LocalStorageService.instance.saveJsonList(_key, list);
    return catatan.id;
  }

  Future<void> updateCatatan(CatatanModel catatan) async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    final idx = list.indexWhere((m) => m['id'] == catatan.id);
    if (idx != -1) {
      list[idx] = catatan.toMap();
      await LocalStorageService.instance.saveJsonList(_key, list);
    }
  }

  Future<void> deleteCatatan(String id) async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    list.removeWhere((m) => m['id'] == id);
    await LocalStorageService.instance.saveJsonList(_key, list);
  }
}
