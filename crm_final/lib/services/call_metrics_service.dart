import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/call_metrics.dart';
import '../constants.dart';

class CallMetricsService {
  static const String resource = '/call-metrics';
  static String get fullUrl => baseUrl + resource;

  Future<List<CallMetrics>> getAll() async {
    final response = await http.get(Uri.parse(fullUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['metrics'];
      return data.map((e) => CallMetrics.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load call metrics');
    }
  }

  Future<CallMetrics> getById(int id) async {
    final response = await http.get(Uri.parse('$fullUrl/$id'));
    if (response.statusCode == 200) {
      return CallMetrics.fromJson(json.decode(response.body)['metrics']);
    } else {
      throw Exception('Failed to load call metrics');
    }
  }

  Future<List<CallMetrics>> getByUserId(int userId) async {
    final response = await http.get(Uri.parse('$fullUrl/by-user/$userId'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['metrics'];
      return data.map((e) => CallMetrics.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load call metrics by user id');
    }
  }

  Future<CallMetrics> create(CallMetrics metrics) async {
    final response = await http.post(
      Uri.parse(fullUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(metrics.toJson()),
    );
    if (response.statusCode == 201) {
      return CallMetrics.fromJson(json.decode(response.body)['metrics']);
    } else {
      throw Exception('Failed to create call metrics');
    }
  }

  Future<CallMetrics> update(int id, CallMetrics metrics) async {
    final response = await http.put(
      Uri.parse('$fullUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(metrics.toJson()),
    );
    if (response.statusCode == 200) {
      return CallMetrics.fromJson(json.decode(response.body)['metrics']);
    } else {
      throw Exception('Failed to update call metrics');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$fullUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete call metrics');
    }
  }
} 