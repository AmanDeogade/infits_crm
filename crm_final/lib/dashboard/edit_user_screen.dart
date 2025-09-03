import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_users_screen.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _initialsController = TextEditingController();

  String _selectedRole = 'caller';
  String? _selectedReportingTo;
  String _selectedCountryCode = '+91';

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _fetchUsers();
  }

  void _initializeForm() {
    _nameController.text = widget.user['name'] ?? '';
    _emailController.text = widget.user['email'] ?? '';
    _phoneController.text = widget.user['phone'] ?? '';
    _initialsController.text = widget.user['initials'] ?? '';
    _selectedRole = widget.user['role'] ?? 'caller';
    _selectedReportingTo = widget.user['reporting_to']?.toString();
    _selectedCountryCode = widget.user['country_code'] ?? '+91';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _initialsController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'initials': _initialsController.text.trim(),
        'role': _selectedRole,
        'country_code': _selectedCountryCode,
        'reporting_to':
            _selectedReportingTo != null && _selectedReportingTo!.isNotEmpty
                ? int.tryParse(_selectedReportingTo!)
                : null,
      };

      print('Sending update request for user ID: ${widget.user['id']}');
      print('User data being sent: $userData');

      final response = await http.put(
        Uri.parse('http://localhost:3000/users/${widget.user['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(userData),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final errorData = json.decode(response.body);
        print('Error data: $errorData');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['error'] ?? errorData['message'] ?? 'Failed to update user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Exception during update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF90CAF9), width: 2.0),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF90CAF9), width: 2.0),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Icon _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return const Icon(Icons.person_outline);
      case 'manager':
        return const Icon(Icons.phone_outlined);
      case 'marketing':
        return const Icon(Icons.star_outline);
      case 'caller':
        return const Icon(Icons.person_outline);
      default:
        return const Icon(Icons.person_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllUsersScreen()),
              );
            },
            icon: const Icon(Icons.people),
            label: const Text('View All Users'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              _buildLabel('Full Name'),
              _buildTextField(
                controller: _nameController,
                hintText: 'Enter full name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildLabel('Email'),
              _buildTextField(
                controller: _emailController,
                hintText: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Role Field
              _buildLabel('Role'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF90CAF9),
                    width: 2.0,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            const Text('Admin'),
                          ],
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'manager',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 12),
                            const Text('Manager'),
                          ],
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'marketing',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            const Text('Marketing'),
                          ],
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'caller',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: Colors.purple[700],
                            ),
                            const SizedBox(width: 12),
                            const Text('Caller'),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Reporting To Field
              _buildLabel('Reporting To'),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!, width: 2.0),
                ),
                child: DropdownButton<String?>(
                  value: _selectedReportingTo,
                  isExpanded: true,
                  menuMaxHeight: 200,
                  underline: Container(),
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text('Select superior'),
                  ),
                  items:
                      _users
                          .where((user) => user['role'] == 'admin')
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final user = entry.value;
                            final isLast =
                                index ==
                                _users
                                        .where((u) => u['role'] == 'admin')
                                        .length -
                                    1;

                            return DropdownMenuItem<String?>(
                              value: user['id'].toString(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      isLast
                                          ? null
                                          : const Border(
                                            bottom: BorderSide(
                                              color: Colors.grey,
                                              width: 0.5,
                                            ),
                                          ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${user['role']} • ${user['email']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReportingTo = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Initials Field
              _buildLabel('Initials'),
              _buildTextField(
                controller: _initialsController,
                hintText: 'Enter initials',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Initials are required';
                  }
                  if (value.trim().length > 5) {
                    return 'Initials should be 5 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Field
              _buildLabel('Phone'),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF90CAF9),
                        width: 2.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'IN ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        DropdownButton<String>(
                          value: _selectedCountryCode,
                          underline: Container(),
                          items: const [
                            DropdownMenuItem(value: '+91', child: Text('+91')),
                            DropdownMenuItem(value: '+1', child: Text('+1')),
                            DropdownMenuItem(value: '+44', child: Text('+44')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      hintText: 'Enter phone',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Phone number should be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Update User',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
