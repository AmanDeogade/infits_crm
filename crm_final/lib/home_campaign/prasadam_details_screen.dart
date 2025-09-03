import 'package:flutter/material.dart';
import '../services/prasad_service.dart';
import 'bars/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prasadam_excel_upload_screen.dart';

class PrasadamDetailsScreen extends StatefulWidget {
  const PrasadamDetailsScreen({super.key});

  @override
  State<PrasadamDetailsScreen> createState() => _PrasadamDetailsScreenState();
}

class _PrasadamDetailsScreenState extends State<PrasadamDetailsScreen> {
  List<Map<String, dynamic>> _prasadam = [];
  List<Map<String, dynamic>> _filteredPrasadam = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _imagesFilter = 'All';
  String _emailFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in or token missing')),
        );
        return;
      }

      final prasadamData = await PrasadService.getAllPrasad(token);
      setState(() {
        _prasadam = prasadamData;
        _filteredPrasadam = prasadamData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load prasadam data: $e')),
      );
    }
  }

  void _filterData() {
    setState(() {
      _filteredPrasadam = _prasadam.where((prasadam) {
        final matchesSearch = _searchQuery.isEmpty ||
            prasadam['donor_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesStatus = _statusFilter == 'All' || prasadam['status'] == _statusFilter;
        final matchesImages = _imagesFilter == 'All' || prasadam['images'] == _imagesFilter;
        final matchesEmail = _emailFilter == 'All' || prasadam['email'] == _emailFilter;

        return matchesSearch && matchesStatus && matchesImages && matchesEmail;
      }).toList();
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCreatedOn(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showAddPrasadamDialog() {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    String selectedStatus = 'Not Verified';
    String selectedImages = 'Not Sent';
    String selectedEmail = 'No';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Prasadam'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Donor Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Donation Date',
                    border: OutlineInputBorder(),
                    hintText: 'YYYY-MM-DD',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                    DropdownMenuItem(value: 'Not Verified', child: Text('Not Verified')),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedImages,
                  decoration: const InputDecoration(
                    labelText: 'Images',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sent', child: Text('Sent')),
                    DropdownMenuItem(value: 'Not Sent', child: Text('Not Sent')),
                  ],
                  onChanged: (value) {
                    selectedImages = value!;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    selectedEmail = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('auth_token');

                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in or token missing')),
                      );
                      return;
                    }

                    final newPrasadam = await PrasadService.createPrasad(
                      token,
                      nameController.text,
                      dateController.text,
                      selectedStatus,
                      selectedImages,
                      selectedEmail,
                    );

                    setState(() {
                      _prasadam.add(newPrasadam);
                      _filterData();
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prasadam added successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add prasadam: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show edit prasadam dialog
  void _showEditPrasadamDialog(Map<String, dynamic> prasadam) {
    final nameController = TextEditingController(text: prasadam['donor_name']);
    // Store original date format for database update
    final originalDate = prasadam['donation_date'];
    final dateController = TextEditingController(text: _formatDate(originalDate));
    String selectedStatus = prasadam['status'];
    String selectedImages = prasadam['images'];
    String selectedEmail = prasadam['email'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Prasadam'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Donor Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Donation Date',
                    border: OutlineInputBorder(),
                    hintText: 'YYYY-MM-DD',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(prasadam['donation_date']),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                    DropdownMenuItem(value: 'Not Verified', child: Text('Not Verified')),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedImages,
                  decoration: const InputDecoration(
                    labelText: 'Images',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sent', child: Text('Sent')),
                    DropdownMenuItem(value: 'Not Sent', child: Text('Not Sent')),
                  ],
                  onChanged: (value) {
                    selectedImages = value!;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    selectedEmail = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('auth_token');

                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in or token missing')),
                      );
                      return;
                    }
                    
                    // Validate donor name
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a donor name')),
                      );
                      return;
                    }

                    // Validate date format (should be DD-MM-YYYY)
                    if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateController.text.trim())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid date in DD-MM-YYYY format')),
                      );
                      return;
                    }
                    
                    // Convert date back to YYYY-MM-DD format for database
                    String updatedDate = dateController.text;
                    print('Edit dialog - Original date controller text: ${dateController.text}');
                    
                    if (updatedDate.contains('-') && updatedDate.split('-')[0].length == 2) {
                      // Convert from DD-MM-YYYY to YYYY-MM-DD
                      final parts = updatedDate.split('-');
                      if (parts.length == 3 && parts[0].length == 2 && parts[1].length == 2 && parts[2].length == 4) {
                        updatedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
                        print('Edit dialog - Date converted: ${dateController.text} -> $updatedDate');
                      }
                    }
                    
                    print('Edit dialog - Final update data: donor_name=${nameController.text}, donation_date=$updatedDate, status=$selectedStatus, images=$selectedImages, email=$selectedEmail');
                    
                    print('Edit dialog - Calling PrasadService.updatePrasad with ID: ${prasadam['id']}');
                    
                    await PrasadService.updatePrasad(
                      token,
                      prasadam['id'],
                      {
                        'donor_name': nameController.text,
                        'donation_date': updatedDate,
                        'status': selectedStatus,
                        'images': selectedImages,
                        'email': selectedEmail,
                      },
                    );

                    print('Edit dialog - Update successful, refreshing data...');
                    
                    // Refresh the data
                    await _loadData();

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prasadam updated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update prasadam: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Show delete prasadam confirmation dialog
  void _showDeletePrasadamDialog(Map<String, dynamic> prasadam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Prasadam'),
          content: Text('Are you sure you want to delete "${prasadam['donor_name']}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token');

                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in or token missing')),
                    );
                    return;
                  }

                  await PrasadService.deletePrasad(token, prasadam['id']);

                  // Refresh the data
                  _loadData();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prasadam deleted successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete prasadam: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prasadam Details',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage prasadam donor information and donation records',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                                             Container(
                         decoration: BoxDecoration(
                           color: Colors.grey.shade300,
                           borderRadius: BorderRadius.circular(25),
                         ),
                         child: Material(
                           color: Colors.transparent,
                           child: InkWell(
                             borderRadius: BorderRadius.circular(25),
                             onTap: () async {
                               final result = await Navigator.of(context).push(
                                 MaterialPageRoute(
                                   builder: (context) => const PrasadamExcelUploadScreen(),
                                 ),
                               );
                               if (result == true) {
                                 _loadData();
                               }
                             },
                             child: Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(
                                     Icons.upload_file,
                                     color: Colors.black87,
                                     size: 20,
                                   ),
                                   const SizedBox(width: 8),
                                   Text(
                                     'Upload Excel',
                                     style: TextStyle(
                                       color: Colors.black87,
                                       fontSize: 14,
                                       fontWeight: FontWeight.w500,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         ),
                       ),
                      const SizedBox(width: 16),
                                             Container(
                         decoration: BoxDecoration(
                           color: Colors.grey.shade300,
                           borderRadius: BorderRadius.circular(25),
                         ),
                         child: Material(
                           color: Colors.transparent,
                           child: InkWell(
                             borderRadius: BorderRadius.circular(25),
                             onTap: _showAddPrasadamDialog,
                             child: Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(
                                     Icons.add,
                                     color: Colors.black87,
                                     size: 20,
                                   ),
                                   const SizedBox(width: 8),
                                   Text(
                                     'Add Prasadam',
                                     style: TextStyle(
                                       color: Colors.black87,
                                       fontSize: 14,
                                       fontWeight: FontWeight.w500,
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
                  const SizedBox(height: 32),

                  // Search and Filters
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            _searchQuery = value;
                            _filterData();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by donor name...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          items: ['All', 'Verified', 'Not Verified'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _statusFilter = newValue!;
                              _filterData();
                            });
                          },
                          underline: Container(), // Remove default underline
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          hint: const Text('Status'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _imagesFilter,
                          items: ['All', 'Sent', 'Not Sent'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _imagesFilter = newValue!;
                              _filterData();
                            });
                          },
                          underline: Container(), // Remove default underline
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          hint: const Text('Images'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _emailFilter,
                          items: ['All', 'Yes', 'No'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _emailFilter = newValue!;
                              _filterData();
                            });
                          },
                          underline: Container(), // Remove default underline
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          hint: const Text('Email'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Table
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Donor Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Donation Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Images',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Created On',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Actions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table Body
                          Expanded(
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _filteredPrasadam.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No prasadam records found',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _filteredPrasadam.length,
                                        itemBuilder: (context, index) {
                                          final prasadam = _filteredPrasadam[index];

                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: index.isEven
                                                  ? Colors.white
                                                  : Colors.grey.shade50,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade200,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    prasadam['donor_name'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    _formatDate(prasadam['donation_date']),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: prasadam['status'] == 'Verified'
                                                          ? const Color(0xFF1EAA36)
                                                          : const Color(0xFFFF0033),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      prasadam['status'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: prasadam['images'] == 'Sent'
                                                          ? const Color(0xFF1EAA36)
                                                          : const Color(0xFFFF0033),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      prasadam['images'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: prasadam['email'] == 'Yes'
                                                          ? const Color(0xFF1EAA36)
                                                          : const Color(0xFFFF0033),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      prasadam['email'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    _formatCreatedOn(prasadam['created_on']),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF718096),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit_outlined,
                                                          color: Colors.grey[600],
                                                          size: 20,
                                                        ),
                                                        onPressed: () => _showEditPrasadamDialog(prasadam),
                                                        tooltip: 'Edit',
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.visibility_outlined,
                                                          color: Colors.grey[600],
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          // View functionality
                                                        },
                                                        tooltip: 'View',
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.grey[600],
                                                          size: 20,
                                                        ),
                                                        onPressed: () => _showDeletePrasadamDialog(prasadam),
                                                        tooltip: 'Delete',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
