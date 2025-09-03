import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'users_list_screen.dart';
import '../home_campaign/bars/side_bar.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _initialsController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'caller';
  String _selectedPermissionTemplate = 'Default Caller Permission';
  String? _selectedReportingTo;
  String _selectedCountryCode = '+91';

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _adminUsers = [];
  bool _isLoading = false;

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.person_outline;
      case 'caller':
        return Icons.phone_outlined;
      case 'marketing':
        return Icons.star_outline;
      case 'manager':
        return Icons.person_outline;
      default:
        return Icons.person_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
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

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'initials': _initialsController.text,
          'role': _selectedRole,
          'phone':
              _phoneController.text.isNotEmpty
                  ? '$_selectedCountryCode${_phoneController.text}'
                  : null,
          'country_code': _selectedCountryCode,
          'permission_template_id':
              null, // TODO: Implement permission templates
          'reporting_to': _selectedReportingTo,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final errorData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['error'] ?? 'Failed to add user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _initialsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar
          const SideBar(),

          // Main Content Column (including AppBar and form)
          Expanded(
            child: Column(
              children: [
                // Custom AppBar for main content area only
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.person_add, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        'Add User',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UsersListScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people, color: Colors.blue),
                        label: const Text(
                          'View All Users',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Add'),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          _buildLabel('Name*'),
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'Enter name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          _buildLabel('Email*'),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'abc@xyz.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
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

                          // Password and Initials Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Password*'),
                                    _buildTextField(
                                      controller: _passwordController,
                                      hintText: 'at least 8 characters',
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Initials*'),
                                    _buildTextField(
                                      controller: _initialsController,
                                      hintText: 'Enter initials',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Initials are required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Roles Field
                          _buildLabel('Roles'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF90CAF9),
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedRole,
                                    underline: Container(),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'admin',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Admin',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'caller',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.phone_outlined,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Caller',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'marketing',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star_outline,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Marketing',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'manager',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Manager',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
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
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Permission Template Field
                          _buildLabel('Permission Template'),
                          _buildDropdown(
                            value: _selectedPermissionTemplate,
                            items: const [
                              DropdownMenuItem(
                                value: 'Default Caller Permission',
                                child: Text('Default Caller Permission'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPermissionTemplate = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Reporting To Field
                          _buildLabel('Reporting To'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue[300]!,
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, color: Colors.black, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButton<String?>(
                                    value: _selectedReportingTo,
                                    underline: Container(),
                                    isExpanded: true,
                                    menuMaxHeight: 200,
                                    items: [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                'Select Superior ---',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ..._users
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
                                                    .where(
                                                      (user) =>
                                                          user['role'] == 'admin',
                                                    )
                                                    .length -
                                                1;

                                        return DropdownMenuItem(
                                          value: user['id'].toString(),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              border: isLast
                                                  ? null
                                                  : const Border(
                                                      bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.person_outline,
                                                  color: Colors.black,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        user['name'] ?? 'Unknown',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${user['role'] ?? 'Unknown'} • ${user['email'] ?? ''}',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedReportingTo = value;
                                      });
                                    },
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Show message if no admin users available
                          if (_users.where((user) => user['role'] == 'admin').isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'No admin users available. Please create an admin user first.',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
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
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
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
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF90CAF9), width: 2.0),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              underline: Container(),
              isExpanded: true,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }
}
