import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import '../../../utils/constants/api_constants.dart';

/// Generic API service for handling HTTP requests
class ApiService with UiLoggy {
  static const int _timeoutSeconds = 30;

  /// GET request to fetch all data from a table
  Future<List<Map<String, dynamic>>> getAllData(String tableName) async {
    try {
      final url = ApiConstants.buildAllDataUrl(tableName);

      loggy.info('GET request to: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.timeoutDuration);

      loggy.info('Response status: ${response.statusCode}');
      loggy.debug('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Handle different response formats
        if (jsonData is List) {
          return List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          // Handle the new API format where data is wrapped with entry_id
          final List<dynamic> dataArray = jsonData['data'];
          final List<Map<String, dynamic>> processedData = [];

          for (final item in dataArray) {
            if (item is Map<String, dynamic> && item.containsKey('data')) {
              // Preserve both entry_id and data
              final Map<String, dynamic> wrappedItem = {
                'entry_id': item['entry_id'],
                'data': item['data'],
              };
              processedData.add(wrappedItem);
            } else if (item is Map<String, dynamic>) {
              // Direct data format
              processedData.add(item);
            }
          }

          return processedData;
        } else if (jsonData is Map) {
          return [Map<String, dynamic>.from(jsonData)];
        }

        return [];
      } else {
        throw Exception(
            'Failed to load data from $tableName: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      loggy.error('Error fetching data from $tableName: $e');
      rethrow;
    }
  }

  /// POST request to create new data
  Future<Map<String, dynamic>> createData(
      String tableName, Map<String, dynamic> data) async {
    try {
      final url = ApiConstants.buildStoreUrl();

      final body = json.encode({
        'table_name': tableName,
        'data': data,
      });

      loggy.info('POST request to: $url');
      loggy.debug('Request body: $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConstants.headers,
            body: body,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      loggy.info('Response status: ${response.statusCode}');
      loggy.debug('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to create data in $tableName: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      loggy.error('Error creating data in $tableName: $e');
      rethrow;
    }
  }

  /// PUT request to update existing data
  Future<Map<String, dynamic>> updateData(
      String tableName, int id, Map<String, dynamic> data) async {
    try {
      final url = ApiConstants.buildUpdateUrl(tableName, id);

      final body = json.encode({'data': data});

      loggy.info('PUT request to: $url');
      loggy.debug('Request body: $body');

      final response = await http
          .put(
            Uri.parse(url),
            headers: ApiConstants.headers,
            body: body,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      loggy.info('Response status: ${response.statusCode}');
      loggy.debug('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to update data in $tableName: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      loggy.error('Error updating data in $tableName: $e');
      rethrow;
    }
  }

  /// DELETE request to remove data
  Future<bool> deleteData(String tableName, int id) async {
    try {
      final url = ApiConstants.buildDeleteUrl(tableName, id);

      loggy.info('DELETE request to: $url');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: ApiConstants.headers,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      loggy.info('Response status: ${response.statusCode}');
      loggy.debug('Response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      loggy.error('Error deleting data from $tableName: $e');
      rethrow;
    }
  }
}
