import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/caller_details.dart';
import '../constants.dart';

class CallerDetailsService {
  static const String resource = '/caller-details';
  static String get fullUrl => baseUrl + resource;

  Future<List<CallerDetails>> getAll() async {
    final response = await http.get(Uri.parse(fullUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['details'];
      return data.map((e) => CallerDetails.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load caller details');
    }
  }

  Future<CallerDetails> getById(int id) async {
    final response = await http.get(Uri.parse('$fullUrl/$id'));
    if (response.statusCode == 200) {
      return CallerDetails.fromJson(json.decode(response.body)['details']);
    } else {
      throw Exception('Failed to load caller details');
    }
  }

  Future<List<CallerDetails>> getByCallerId(int callerId) async {
    final response = await http.get(Uri.parse('$fullUrl/by-caller/$callerId'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['details'];
      return data.map((e) => CallerDetails.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load caller details by caller id');
    }
  }

  Future<CallerDetails> create(CallerDetails details) async {
    final response = await http.post(
      Uri.parse(fullUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(details.toJson()),
    );
    if (response.statusCode == 201) {
      return CallerDetails.fromJson(json.decode(response.body)['details']);
    } else {
      throw Exception('Failed to create caller details');
    }
  }

  Future<CallerDetails> update(int id, CallerDetails details) async {
    final response = await http.put(
      Uri.parse('$fullUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(details.toJson()),
    );
    if (response.statusCode == 200) {
      return CallerDetails.fromJson(json.decode(response.body)['details']);
    } else {
      throw Exception('Failed to update caller details');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$fullUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete caller details');
    }
  }
} 