abstract class EditWorkerRepository {
  Future<List<String>> fetchEditProperties();
}

class MockEditWorkerRepository implements EditWorkerRepository {
  @override
  Future<List<String>> fetchEditProperties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Edit Worker1', 'Edit Worker2', 'Edit Worker3'];
  }
}
