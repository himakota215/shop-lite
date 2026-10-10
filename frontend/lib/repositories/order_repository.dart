import '../core/network/api_client.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Create a new order with customer details and item quantities
  Future<Order> createOrder({
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required List<CartItem> items,
  }) async {
    final payload = {
      'customer': {
        'name': customerName.trim(),
        'phone': customerPhone.trim(),
        'address': deliveryAddress.trim(),
      },
      'items': items.map((item) => item.toCheckoutPayload()).toList(),
    };

    final response = await _apiClient.post('/api/orders', body: payload);
    final data = response['data'] as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  /// Retrieve an existing order by its server-assigned ID
  Future<Order> getOrderById(int orderId) async {
    final response = await _apiClient.get('/api/orders/$orderId');
    final data = response['data'] as Map<String, dynamic>;
    return Order.fromJson(data);
  }
}
