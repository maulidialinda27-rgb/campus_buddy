import 'package:campus_buddy/services/local_storage_service.dart';
import 'package:campus_buddy/features/tugas/data/models/tugas_model.dart';

class TugasService {
  static const String _key = 'tugas_list';

  Future<List<Tugas>> getAllTugas() async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    return list.map((m) => Tugas.fromMap(m)).toList();
  }

  Future<String> insertTugas(Tugas task) async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    list.add(task.toMap());
    await LocalStorageService.instance.saveJsonList(_key, list);
    return task.id;
  }

  Future<int> updateTugas(Tugas task) async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    final index = list.indexWhere((m) => m['id'] == task.id);
    if (index == -1) return 0;
    list[index] = task.toMap();
    await LocalStorageService.instance.saveJsonList(_key, list);
    return 1;
  }

  Future<int> deleteTugas(String id) async {
    final list = await LocalStorageService.instance.loadJsonList(_key);
    final newList = list.where((m) => m['id'] != id).toList();
    await LocalStorageService.instance.saveJsonList(_key, newList);
    return 1;
  }
}
