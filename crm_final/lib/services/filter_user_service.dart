import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class FilterUserService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get all filter users
  static Future<List<Map<String, dynamic>>> getAllFilterUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get filter users');
        }
      } else {
        throw Exception('Failed to get filter users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting filter users: $e');
    }
  }

  // Create a single filter user
  static Future<Map<String, dynamic>> createFilterUser(
    String token,
    String name,
    String email,
    String? phone,
    String? date,
  ) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
      };

      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      if (date != null && date.isNotEmpty) {
        body['date'] = date;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/filter-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to create filter user');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create filter user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating filter user: $e');
    }
  }

  // Bulk create filter users
  static Future<List<int>> bulkCreateFilterUsers(
    String token,
    List<Map<String, dynamic>> users,
  ) async {
    try {
      // Debug: Print the data being sent
      print('Sending users data: ${json.encode({'users': users})}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/filter-users/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'users': users}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<int>.from(data['data']['insertIds']);
        } else {
          throw Exception(data['message'] ?? 'Failed to bulk create filter users');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to bulk create filter users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error bulk creating filter users: $e');
    }
  }

  // Update a filter user
  static Future<Map<String, dynamic>> updateFilterUser(
    String token,
    int id,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/filter-users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to update filter user');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update filter user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating filter user: $e');
    }
  }

  // Delete a filter user
  static Future<bool> deleteFilterUser(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/filter-users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete filter user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting filter user: $e');
    }
  }

  // Search filter users by email
  static Future<List<Map<String, dynamic>>> searchByEmail(String token, String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter-users/search/email?email=$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to search filter users');
        }
      } else {
        throw Exception('Failed to search filter users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching filter users: $e');
    }
  }

  // Search filter users by name
  static Future<List<Map<String, dynamic>>> searchByName(String token, String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter-users/search/name?name=$name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to search filter users');
        }
      } else {
        throw Exception('Failed to search filter users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching filter users: $e');
    }
  }

  // Search filter users by date range
  static Future<List<Map<String, dynamic>>> searchByDateRange(
    String token,
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter-users/search/date-range?startDate=$startDate&endDate=$endDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to search filter users');
        }
      } else {
        throw Exception('Failed to search filter users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching filter users: $e');
    }
  }
}
