import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class PrasadService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get all prasad records
  static Future<List<Map<String, dynamic>>> getAllPrasad(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prasad'),
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
          throw Exception(data['message'] ?? 'Failed to get prasad records');
        }
      } else {
        throw Exception('Failed to get prasad records: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting prasad records: $e');
    }
  }

  // Create a single prasad record
  static Future<Map<String, dynamic>> createPrasad(
    String token,
    String donorName,
    String donationDate,
    String status,
    String images,
    String email,
  ) async {
    try {
      final Map<String, dynamic> body = {
        'donor_name': donorName,
        'donation_date': donationDate,
        'status': status,
        'images': images,
        'email': email,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/prasad'),
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
          throw Exception(data['message'] ?? 'Failed to create prasad record');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create prasad record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating prasad record: $e');
    }
  }

  // Update a prasad record
  static Future<Map<String, dynamic>> updatePrasad(
    String token,
    int id,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/prasad/$id'),
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
          throw Exception(data['message'] ?? 'Failed to update prasad record');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update prasad record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating prasad record: $e');
    }
  }

  // Delete a prasad record
  static Future<bool> deletePrasad(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/prasad/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error deleting prasad record: $e');
    }
  }

  // Search prasad records by name
  static Future<List<Map<String, dynamic>>> searchByName(String token, String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prasad/search/name?name=$name'),
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
          throw Exception(data['message'] ?? 'Failed to search prasad records');
        }
      } else {
        throw Exception('Failed to search prasad records: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching prasad records: $e');
    }
  }

  // Get prasad records by status
  static Future<List<Map<String, dynamic>>> getPrasadByStatus(String token, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prasad/status/$status'),
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
          throw Exception(data['message'] ?? 'Failed to get prasad records by status');
        }
      } else {
        throw Exception('Failed to get prasad records by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting prasad records by status: $e');
    }
  }

  // Get prasad records by images status
  static Future<List<Map<String, dynamic>>> getPrasadByImagesStatus(String token, String imagesStatus) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prasad/images/$imagesStatus'),
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
          throw Exception(data['message'] ?? 'Failed to get prasad records by images status');
        }
      } else {
        throw Exception('Failed to get prasad records by images status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting prasad records by images status: $e');
    }
  }

  // Get prasad records by email status
  static Future<List<Map<String, dynamic>>> getPrasadByEmailStatus(String token, String emailStatus) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prasad/email/$emailStatus'),
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
          throw Exception(data['message'] ?? 'Failed to get prasad records by email status');
        }
      } else {
        throw Exception('Failed to get prasad records by email status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting prasad records by email status: $e');
    }
  }
}



