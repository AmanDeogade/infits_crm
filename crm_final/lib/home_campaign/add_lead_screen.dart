import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bars/side_bar.dart';
import '../services/auth_service.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipController = TextEditingController();
  final _ratingController = TextEditingController();

  String _selectedCampaign = '';
  String _selectedAssignee = '';
  List<Map<String, dynamic>> _campaigns = [];
  List<Map<String, dynamic>> _assignees = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _fetchCampaigns() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/campaigns'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _campaigns = List<Map<String, dynamic>>.from(data['campaigns'] ?? []);
          if (_campaigns.isNotEmpty) {
            _selectedCampaign = _campaigns.first['id'].toString();
            _fetchAllUsers();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load campaigns: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _assignees = List<Map<String, dynamic>>.from(data['users'] ?? []);
          // Reset selected assignee when users are refreshed
          _selectedAssignee = '';
        });
      }
    } catch (e) {
      print('Failed to load users: $e');
      setState(() {
        _assignees = [];
        _selectedAssignee = '';
      });
    }
  }

  Future<void> _saveLead() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCampaign.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a campaign'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get authentication headers
      final authService = AuthService();
      final headers = await authService.getAuthHeaders();

      // If a user is selected, use their user_id directly
      // The backend will handle campaign assignment automatically
      String? assignedUserId;
      if (_selectedAssignee.isNotEmpty) {
        assignedUserId = _selectedAssignee;
      }

      final leadData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'alt_phone': _altPhoneController.text.trim(),
        'address_line': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'zip': _zipController.text.trim(),
        'rating':
            _ratingController.text.trim().isNotEmpty
                ? int.tryParse(_ratingController.text.trim())
                : null,
        'campaign_id': int.parse(_selectedCampaign),
        'assigned_to': assignedUserId, // This is now the user_id directly
        'current_status': 'NEW',
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/leads'),
        headers: headers,
        body: jsonEncode(leadData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lead added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add lead: ${errorData['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (isPhone)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'IN +91',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType ?? TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: placeholder ?? 'Enter phone',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                    validator: validator,
                  ),
                ),
              ],
            ),
          )
        else
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder ?? 'Text field value',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            validator: validator,
          ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
    required String displayKey,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF90CAF9), width: 2.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: value.isEmpty ? null : value,
                  underline: Container(),
                  isExpanded: true,
                  menuMaxHeight: 200,
                  hint: Text(hint ?? '---Select---'),
                  items:
                      items.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                                Text(
                                  item[displayKey] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: onChanged,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const SideBar(),
          Expanded(
            child: Column(
              children: [
                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Add Lead',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // Save button in header
                      TextButton(
                        onPressed: _isSaving ? null : _saveLead,
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Save'),
                      ),
                    ],
                  ),
                ),
                // Form content
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade300,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Campaign and Assignee Selection Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDropdownField(
                                            label: 'Campaign',
                                            value: _selectedCampaign,
                                            items: _campaigns,
                                            displayKey: 'name',
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedCampaign = value ?? '';
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select a campaign';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: _buildDropdownField(
                                            label: 'Assign To (Optional)',
                                            value: _selectedAssignee,
                                            items: _assignees,
                                            displayKey: 'name',
                                            hint:
                                                _assignees.isEmpty
                                                    ? 'No users available'
                                                    : '---Select User---',
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedAssignee = value ?? '';
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),

                                    // Two Column Layout
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left Column
                                        Expanded(
                                          child: Column(
                                            children: [
                                              _buildTextField(
                                                label: 'First Name',
                                                controller:
                                                    _firstNameController,
                                                placeholder: 'Enter first name',
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'First name is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'Last Name',
                                                controller: _lastNameController,
                                                placeholder: 'Enter last name',
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Last name is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'Email',
                                                controller: _emailController,
                                                placeholder: 'abc@xyz.com',
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
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
                                              _buildTextField(
                                                label: 'Phone',
                                                controller: _phoneController,
                                                placeholder: 'Enter phone',
                                                isPhone: true,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Phone is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'Alternate Phone',
                                                controller: _altPhoneController,
                                                placeholder:
                                                    'Enter alternate phone',
                                                isPhone: true,
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'Address',
                                                controller: _addressController,
                                                placeholder: 'Enter address',
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        // Right Column
                                        Expanded(
                                          child: Column(
                                            children: [
                                              _buildTextField(
                                                label: 'City',
                                                controller: _cityController,
                                                placeholder: 'Enter city',
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'State',
                                                controller: _stateController,
                                                placeholder: 'Enter state',
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'Country',
                                                controller: _countryController,
                                                placeholder: 'Enter country',
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'ZIP Code',
                                                controller: _zipController,
                                                placeholder: 'Enter ZIP code',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                              const SizedBox(height: 20),
                                              _buildTextField(
                                                label: 'Rating',
                                                controller: _ratingController,
                                                placeholder:
                                                    'Enter rating (1-10)',
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value != null &&
                                                      value.trim().isNotEmpty) {
                                                    final rating = int.tryParse(
                                                      value,
                                                    );
                                                    if (rating == null ||
                                                        rating < 1 ||
                                                        rating > 10) {
                                                      return 'Rating must be between 1 and 10';
                                                    }
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),

                                    // Add Lead Button
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        onPressed: _isSaving ? null : _saveLead,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child:
                                            _isSaving
                                                ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                                : const Text(
                                                  'Add Lead',
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
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
