import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class GoogleSheetsService {
  // Use SheetDB instead (easier, no CORS issues!)
  // 1. Go to https://sheetdb.io
  // 2. Sign up free and connect your Google Sheet
  // 3. Get your API URL and paste here
  static String? _sheetDbUrl;

  // Legacy: Google Apps Script URL (has CORS issues)
  static String? _scriptUrl;

  static void setSheetDbUrl(String url) {
    _sheetDbUrl = url;
  }

  static void setScriptUrl(String url) {
    _scriptUrl = url;
  }

  static bool get isConfigured =>
      (_sheetDbUrl != null && _sheetDbUrl!.isNotEmpty) ||
      (_scriptUrl != null && _scriptUrl!.isNotEmpty);

  /// Send order data to Google Sheets
  static Future<bool> sendOrderToSheet(OrderModel order) async {
    // Try SheetDB first (no CORS issues)
    if (_sheetDbUrl != null && _sheetDbUrl!.isNotEmpty) {
      return _sendToSheetDb(order);
    }

    // Fallback to Google Apps Script
    if (_scriptUrl != null && _scriptUrl!.isNotEmpty) {
      return _sendToGoogleAppsScript(order);
    }

    print('No Google Sheets URL configured');
    return false;
  }

  // Send to SheetDB (recommended - easier, no CORS)
  static Future<bool> _sendToSheetDb(OrderModel order) async {
    try {
      final data = {
        'order_id': order.orderId,
        'order_date': order.orderDate.toIso8601String(),
        'size': order.size,
        'sweetness': order.sweetness,
        'toppings': order.toppings.join(', '),
        'ingredients': order.ingredients.join(', '),
        'total_price': order.totalPrice.toString(),
        'status': order.status,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Sending to SheetDB: ${jsonEncode(data)}');

      final response = await http.post(
        Uri.parse(_sheetDbUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      print('SheetDB response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        print('Order sent to SheetDB successfully');
        return true;
      } else {
        print('SheetDB error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending to SheetDB: $e');
      return false;
    }
  }

  // Send to Google Apps Script (has CORS issues)
  static Future<bool> _sendToGoogleAppsScript(OrderModel order) async {
    try {
      final Map<String, dynamic> data = {
        'orderId': order.orderId,
        'orderDate': order.orderDate.toIso8601String(),
        'menuName': order.menuName,
        'size': order.size,
        'sweetness': order.sweetness,
        'totalPrice': order.totalPrice.toString(),
        'status': order.status,
        'toppings': order.toppings.join(', '),
        'ingredients': order.ingredients.join(', '),
      };

      final response = await http.post(
        Uri.parse(_scriptUrl!),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: data.map((key, value) => MapEntry(key, Uri.encodeComponent(value.toString())))
                 .map((key, value) => MapEntry(key, '$key=$value'))
                 .values
                 .join('&'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print('Order sent to Google Sheets successfully');
        return true;
      } else {
        print('Failed to send order: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending order to Google Sheets: $e');
      return false;
    }
  }

  /// Send multiple orders to Google Sheets
  static Future<bool> sendOrdersToSheet(List<OrderModel> orders) async {
    if (_scriptUrl == null || _scriptUrl!.isEmpty) {
      print('Google Sheets URL not configured');
      return false;
    }

    try {
      // Prepare the data
      final List<Map<String, dynamic>> ordersData = orders.map((order) {
        return {
          'orderId': order.orderId,
          'timestamp': order.orderDate.toIso8601String(),
          'menuName': order.menuName,
          'size': order.size,
          'sweetness': order.sweetness,
          'totalPrice': order.totalPrice.toString(),
          'status': order.status,
          'toppings': order.toppings.join(', '),
          'ingredients': order.ingredients.join(', '),
        };
      }).toList();

      final Map<String, dynamic> data = {
        'type': 'bulkOrders',
        'orders': ordersData,
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(_scriptUrl!),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30), // Increased timeout
        onTimeout: () {
          return http.Response('Timeout', 408);
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending orders to Google Sheets: $e');
      return false;
    }
  }

  /// Test connection to Google Sheets
  static Future<bool> testConnection() async {
    if (_scriptUrl == null || _scriptUrl!.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_scriptUrl!),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'type': 'test'}),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return http.Response('Timeout', 408);
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error testing Google Sheets connection: $e');
      return false;
    }
  }

  /// Fetch all orders from SheetDB
  /// Returns a map of order_id -> status
  static Future<Map<String, String>> fetchAllOrdersFromSheet() async {
    if (_sheetDbUrl == null || _sheetDbUrl!.isEmpty) {
      print('SheetDB URL not configured');
      return {};
    }

    try {
      final response = await http.get(
        Uri.parse(_sheetDbUrl!),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> orders = jsonDecode(response.body);
        final Map<String, String> statusMap = {};

        for (final order in orders) {
          final orderId = order['order_id'] as String?;
          final status = order['status'] as String?;
          if (orderId != null && status != null) {
            statusMap[orderId] = status;
          }
        }

        print('Fetched ${statusMap.length} orders from SheetDB');
        return statusMap;
      } else {
        print('Failed to fetch orders: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching orders from SheetDB: $e');
      return {};
    }
  }
}
