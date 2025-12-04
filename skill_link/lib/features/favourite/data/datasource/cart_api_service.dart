import 'package:dio/dio.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/favourite/data/model/cart_model/cart_api_model.dart';

abstract class CartApiService {
  Future<CartApiModel> getCart();
  Future<CartApiModel> addToCart(String propertyId);
  Future<CartApiModel> removeFromCart(String propertyId);
  Future<void> clearCart();
}

class CartApiServiceImpl implements CartApiService {
  final ApiService _apiService;

  CartApiServiceImpl(this._apiService);

  @override
  Future<CartApiModel> getCart() async {
    try {
      final response = await _apiService.dio.get('/cart');

      // Handle the case where cart might be empty
      if (response.data['data'] == null) {
        return CartApiModel(
          user: '', // This will be set by the backend
          items: [],
        );
      }

      return CartApiModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CartApiModel> addToCart(String propertyId) async {
    try {
      final response = await _apiService.dio.post(
        '/cart/add',
        data: {'propertyId': propertyId},
      );

      return CartApiModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CartApiModel> removeFromCart(String propertyId) async {
    try {
      final response = await _apiService.dio.delete('/cart/remove/$propertyId');
      // If backend returns a string (e.g. 'Removed successfully'), re-fetch the cart
      if (response.data is String || response.data == null) {
        return await getCart();
      }
      if (response.data is Map<String, dynamic> &&
          response.data['data'] != null) {
        return CartApiModel.fromJson(response.data['data']);
      }
      // Fallback: re-fetch the cart
      return await getCart();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _apiService.dio.delete('/cart/clear');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Exception(
          'Bad request: ${e.response?.data['message'] ?? 'Invalid request'}',
        );
      case 401:
        return Exception('Unauthorized: Please login again');
      case 404:
        return Exception('Cart not found');
      case 409:
        return Exception('Property already in cart');
      case 500:
        return Exception('Server error: Please try again later');
      default:
        return Exception('Network error: Please check your connection');
    }
  }
}
