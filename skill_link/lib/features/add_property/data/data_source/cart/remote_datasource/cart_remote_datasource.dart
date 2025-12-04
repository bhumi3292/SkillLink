import 'package:dio/dio.dart';
import 'package:skill_link/features/add_property/data/data_source/cart/cart_data_source.dart';
import 'package:skill_link/features/add_property/domain/entity/cart/cart_entity.dart';

class CartRemoteDatasource implements ICartDataSource {
  final Dio _dio;

  CartRemoteDatasource({required Dio dio}) : _dio = dio;

  @override
  Future<CartEntity> getCart() async {
    try {
      final response = await _dio.get('/cart');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return CartEntity.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } else {
        throw Exception(
          'Failed to get cart: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to get cart (Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  @override
  Future<CartEntity> addToCart(String propertyId) async {
    try {
      final response = await _dio.post(
        '/cart/add',
        data: {'propertyId': propertyId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return CartEntity.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } else {
        throw Exception(
          'Failed to add to cart: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to add to cart (Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  @override
  Future<CartEntity> removeFromCart(String propertyId) async {
    try {
      final response = await _dio.delete('/cart/remove/$propertyId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return CartEntity.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } else {
        throw Exception(
          'Failed to remove from cart: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to remove from cart (Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      final response = await _dio.delete('/cart/clear');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to clear cart: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to clear cart (Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
