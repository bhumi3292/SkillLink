abstract class ContactworkerRepository {
  Future<List<String>> fetchContacts();
}

class MockContactworkerRepository implements ContactworkerRepository {
  @override
  Future<List<String>> fetchContacts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Contact 1', 'Contact 2', 'Contact 3'];
  }
}
