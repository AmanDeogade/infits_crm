import 'package:crm_final/home_campaign/donor_excel_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/donor_service.dart';
import 'bars/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonationDetailsScreen extends StatefulWidget {
  const DonationDetailsScreen({super.key});

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  List<Map<String, dynamic>> _donors = [];
  List<Map<String, dynamic>> _filteredDonors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _imagesFilter = 'All';

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
        throw Exception('User not logged in or token missing');
      }

      final donors = await DonorService.getAllDonors(token);

      setState(() {
        _donors = donors;
        _filteredDonors = donors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _filterData() {
    setState(() {
      _filteredDonors = _donors.where((donor) {
        final matchesSearch = donor['donor_name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        final matchesStatus =
            _statusFilter == 'All' || donor['status'] == _statusFilter;

        final matchesImages =
            _imagesFilter == 'All' || donor['images'] == _imagesFilter;

        return matchesSearch && matchesStatus && matchesImages;
      }).toList();
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCreatedOn(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _showAddDonorDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    String selectedStatus = 'Not Verified';
    String selectedImages = 'Not Sent';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Donor'),
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
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          dateController.text =
                              date.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Verified',
                          child: Text('Verified'),
                        ),
                        DropdownMenuItem(
                          value: 'Not Verified',
                          child: Text('Not Verified'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
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
                        DropdownMenuItem(
                          value: 'Not Sent',
                          child: Text('Not Sent'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedImages = value!;
                        });
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
                      if (nameController.text.isNotEmpty &&
                          dateController.text.isNotEmpty) {
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('auth_token');

                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User not logged in or token missing')),
                            );
                            return;
                          }

                          final newDonor = await DonorService.createDonor(
                            token,
                            nameController.text,
                            dateController.text,
                            selectedStatus,
                            selectedImages,
                          );

                          setState(() {
                            _donors.add(newDonor);
                            _filterData();
                          });

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Donor added successfully!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add donor: $e')),
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
      },
    );
  }

  // Show edit donor dialog
  void _showEditDonorDialog(Map<String, dynamic> donor) {
    final nameController = TextEditingController(text: donor['donor_name']);
    final dateController = TextEditingController(text: _formatDate(donor['donation_date']));
    String selectedStatus = donor['status'];
    String selectedImages = donor['images'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Donor'),
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
                      initialDate: DateTime.parse(donor['donation_date']),
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

                    await DonorService.updateDonor(
                      token,
                      donor['id'],
                      {
                        'donor_name': nameController.text,
                        'donation_date': dateController.text,
                        'status': selectedStatus,
                        'images': selectedImages,
                      },
                    );

                    // Refresh the data
                    _loadData();

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Donor updated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update donor: $e')),
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

  // Show delete donor confirmation dialog
  void _showDeleteDonorDialog(Map<String, dynamic> donor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Donor'),
          content: Text('Are you sure you want to delete "${donor['donor_name']}"? This action cannot be undone.'),
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

                  await DonorService.deleteDonor(token, donor['id']);

                  // Refresh the data
                  _loadData();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donor deleted successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete donor: $e')),
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
                              'Donation Details',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage donor information and donation records',
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
                                  builder: (context) => const DonorExcelUploadScreen(),
                                ),
                              );
                              
                              // Refresh the donor list when returning from upload screen
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
                            onTap: _showAddDonorDialog,
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
                                    'Add Donor',
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
                            hintText: 'Search donors...',
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
                      DropdownButton<String>(
                        value: _statusFilter,
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: 'Verified',
                            child: Text('Verified'),
                          ),
                          DropdownMenuItem(
                            value: 'Not Verified',
                            child: Text('Not Verified'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value!;
                            _filterData();
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _imagesFilter,
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Images'),
                          ),
                          DropdownMenuItem(value: 'Sent', child: Text('Sent')),
                          DropdownMenuItem(
                            value: 'Not Sent',
                            child: Text('Not Sent'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _imagesFilter = value!;
                            _filterData();
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Data Table - Using Add Filter style
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Row(
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
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Date',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Images',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Created On',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
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
                                  : _filteredDonors.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No donors found',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: _filteredDonors.length,
                                          itemBuilder: (context, index) {
                                            final donor = _filteredDonors[index];

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
                                                      donor['donor_name'],
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
                                                      _formatDate(donor['donation_date']),
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
                                                        color: donor['status'] == 'Verified'
                                                            ? const Color(0xFF1EAA36)
                                                            : const Color(0xFFFF0033),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        donor['status'],
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
                                                        color: donor['images'] == 'Sent'
                                                            ? const Color(0xFF1EAA36)
                                                            : const Color(0xFFFF0033),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        donor['images'],
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
                                                      _formatCreatedOn(donor['created_on']),
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
                                                          onPressed: () => _showEditDonorDialog(donor),
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
                                                          onPressed: () => _showDeleteDonorDialog(donor),
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
