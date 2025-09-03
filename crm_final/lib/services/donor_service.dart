import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class DonorService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get all donors
  static Future<List<Map<String, dynamic>>> getAllDonors(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donors'),
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
          throw Exception(data['message'] ?? 'Failed to get donors');
        }
      } else {
        throw Exception('Failed to get donors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting donors: $e');
    }
  }

  // Create a single donor
  static Future<Map<String, dynamic>> createDonor(
    String token,
    String donorName,
    String donationDate,
    String status,
    String images,
  ) async {
    try {
      final Map<String, dynamic> body = {
        'donor_name': donorName,
        'donation_date': donationDate,
        'status': status,
        'images': images,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/donors'),
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
          throw Exception(data['message'] ?? 'Failed to create donor');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create donor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating donor: $e');
    }
  }

  // Update a donor
  static Future<Map<String, dynamic>> updateDonor(
    String token,
    int id,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/donors/$id'),
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
          throw Exception(data['message'] ?? 'Failed to update donor');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update donor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating donor: $e');
    }
  }

  // Delete a donor
  static Future<bool> deleteDonor(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/donors/$id'),
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
        throw Exception(errorData['message'] ?? 'Failed to delete donor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting donor: $e');
    }
  }

  // Search donors by name
  static Future<List<Map<String, dynamic>>> searchByName(String token, String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donors/search/name?name=$name'),
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
          throw Exception(data['message'] ?? 'Failed to search donors');
        }
      } else {
        throw Exception('Failed to search donors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching donors: $e');
    }
  }

  // Get donors by status
  static Future<List<Map<String, dynamic>>> getDonorsByStatus(String token, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donors/status/$status'),
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
          throw Exception(data['message'] ?? 'Failed to get donors by status');
        }
      } else {
        throw Exception('Failed to get donors by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting donors by status: $e');
    }
  }

  // Get donors by images status
  static Future<List<Map<String, dynamic>>> getDonorsByImagesStatus(String token, String imagesStatus) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donors/images/$imagesStatus'),
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
          throw Exception(data['message'] ?? 'Failed to get donors by images status');
        }
      } else {
        throw Exception('Failed to get donors by images status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting donors by images status: $e');
    }
  }
}



