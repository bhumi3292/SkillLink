abstract class EditPropertyRepository {
  Future<List<String>> fetchEditProperties();
}

class MockEditPropertyRepository implements EditPropertyRepository {
  @override
  Future<List<String>> fetchEditProperties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Edit Property 1', 'Edit Property 2', 'Edit Property 3'];
  }
} 