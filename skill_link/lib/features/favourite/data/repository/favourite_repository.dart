abstract class FavouriteRepository {
  Future<List<String>> fetchFavourites();
}

class MockFavouriteRepository implements FavouriteRepository {
  @override
  Future<List<String>> fetchFavourites() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Favourite 1', 'Favourite 2', 'Favourite 3'];
  }
} 