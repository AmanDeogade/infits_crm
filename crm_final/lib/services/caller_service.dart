import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/caller.dart';
import '../constants.dart';

class CallerService {
  static Future<List<Caller>> fetchCallers() async {
    print('CallerService: Making API call to fetch callers...');
    final response = await http.get(Uri.parse('$baseUrl/callers'));
    print('CallerService: Response status code: ${response.statusCode}');
    print('CallerService: Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> callersJson = data['callers'] ?? [];
      print('CallerService: Found ${callersJson.length} callers in response');
      return callersJson.map((json) => Caller.fromJson(json)).toList();
    } else {
      print('CallerService: Error response - ${response.statusCode}: ${response.body}');
      throw Exception('Failed to load callers: ${response.statusCode}');
    }
  }

  static Future<Caller> fetchCallerById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/callers/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Caller.fromJson(data['caller']);
    } else {
      throw Exception('Failed to load caller');
    }
  }

  // Add getAll method for consistency with other services
  Future<List<Caller>> getAll() async {
    return await CallerService.fetchCallers();
  }
}
