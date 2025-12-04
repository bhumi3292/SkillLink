abstract class ExploreRepository {
  Future<List<String>> fetchExploreItems();
}

class MockExploreRepository implements ExploreRepository {
  @override
  Future<List<String>> fetchExploreItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Explore Item 1', 'Explore Item 2', 'Explore Item 3'];
  }
} 