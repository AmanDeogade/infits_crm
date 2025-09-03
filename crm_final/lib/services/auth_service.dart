import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:crm_final/authentication/login_screen.dart';

class AuthService {
  // Store token in SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Public method to get token
  Future<String?> getToken() async {
    return await _getToken();
  }

  // Remove token from SharedPreferences
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Save user data locally
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setInt('user_id', userData['id'] ?? 0);
    await prefs.setString('user_phone', userData['phone'] ?? '');
    await prefs.setString('user_alternate_phone', userData['alternate_phone'] ?? '');
    await prefs.setString('user_initials', userData['initials'] ?? '');
    await prefs.setString('user_role', userData['role'] ?? '');
    await prefs.setString('user_country_code', userData['country_code'] ?? '');
  }

  // Get user data from local storage
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('user_id') ?? 0,
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'phone': prefs.getString('user_phone') ?? '',
      'alternate_phone': prefs.getString('user_alternate_phone') ?? '',
      'initials': prefs.getString('user_initials') ?? '',
      'role': prefs.getString('user_role') ?? '',
      'country_code': prefs.getString('user_country_code') ?? '',
    };
  }

  // Get user name from local storage
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  // Get user email from local storage
  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? '';
  }

  // Get user ID from local storage
  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  // Check if user data exists locally
  Future<bool> hasUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    return name != null && name.isNotEmpty && email != null && email.isNotEmpty;
  }

  // Clear user data from local storage
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
    await prefs.remove('user_alternate_phone');
    await prefs.remove('user_initials');
    await prefs.remove('user_role');
    await prefs.remove('user_country_code');
  }

  // Public logout method
  Future<void> logout() async {
    try {
      // Clear user data
      await _clearUserData();
      // Remove authentication token
      await _removeToken();
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, try to clear data
      try {
        await _clearUserData();
        await _removeToken();
      } catch (e2) {
        print('Error during fallback logout: $e2');
      }
    }
  }

  // Register new user
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // Save token and user data
        await _saveToken(data['token']);
        await _saveUserData(data['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        await _saveToken(data['token']);
        await _saveUserData(data['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? alternatePhone,
    String? initials,
    String? role,
    String? countryCode,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      // Prepare the data to send to backend
      final Map<String, dynamic> profileData = {
        'name': name,
        'email': email,
      };
      
      // Add phone numbers if provided
      if (phone != null) profileData['phone'] = phone;
      if (alternatePhone != null) profileData['alternate_phone'] = alternatePhone;
      
      // Add other required fields to prevent NULL errors
      // Only include fields that have actual values
      if (initials != null && initials.isNotEmpty) profileData['initials'] = initials;
      if (role != null && role.isNotEmpty) profileData['role'] = role;
      if (countryCode != null && countryCode.isNotEmpty) profileData['country_code'] = countryCode;

      print('Sending profile data to backend: $profileData');

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(profileData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Update local user data
        await _saveUserData(data['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // Verify logout was successful
  Future<bool> verifyLogout() async {
    final token = await _getToken();
    return token == null;
  }

  // Clear all user data
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all stored data
    await prefs.clear();
  }



  // Get auth headers for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Static method to handle logout with confirmation
  static Future<void> logoutWithConfirmation(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Perform logout immediately
      final authService = AuthService();
      await authService.logout();

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // Alternative logout method with loading indicator
  static Future<void> logoutWithLoading(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Show loading overlay
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation1, animation2) {
          return Container();
        },
        transitionBuilder: (context, animation1, animation2, child) {
          return FadeTransition(
            opacity: animation1,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text('Logging out...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      // Perform logout
      final authService = AuthService();
      await authService.logout();

      // Close loading overlay and navigate
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading overlay
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

/*
USAGE EXAMPLES:

// Get user data anywhere in your app:
final authService = AuthService();

// Get all user data
final userData = await authService.getUserData();
print('User: ${userData['name']} (${userData['email']})');

// Get specific user info
final userName = await authService.getUserName();
final userEmail = await authService.getUserEmail();
final userId = await authService.getUserId();

// Check if user data exists
final hasData = await authService.hasUserData();

// Example widget usage:
class UserInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService().getUserName(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text('Welcome, ${snapshot.data}!');
        }
        return Text('Welcome!');
      },
    );
  }
}
*/
