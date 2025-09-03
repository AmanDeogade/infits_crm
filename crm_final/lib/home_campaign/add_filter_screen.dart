import 'package:flutter/material.dart';
import 'bars/side_bar.dart';
import '../services/filter_user_service.dart';
import '../services/auth_service.dart';
import '../models/filter_user.dart';
import 'filter_excel_upload_screen.dart';

class AddFilterScreen extends StatefulWidget {
  const AddFilterScreen({super.key});

  @override
  State<AddFilterScreen> createState() => _AddFilterScreenState();
}

class _AddFilterScreenState extends State<AddFilterScreen> {
  bool _isLoading = false;
  List<FilterUser> _filterUsers = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedDateFilter = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final filterUsersData = await FilterUserService.getAllFilterUsers(token);
      final filterUsers =
          filterUsersData.map((json) => FilterUser.fromJson(json)).toList();

      setState(() {
        _filterUsers = filterUsers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<FilterUser> get _filteredData {
    List<FilterUser> filtered = _filterUsers;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      filtered =
          filtered.where((user) {
            return user.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                user.email.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                user.id.toString().contains(_searchController.text);
          }).toList();
    }

    // Date filter
    if (_selectedDateFilter.isNotEmpty) {
      filtered =
          filtered.where((user) {
            if (user.date == null) return false;

            switch (_selectedDateFilter) {
              case 'today':
                final now = DateTime.now();
                return user.date!.year == now.year &&
                    user.date!.month == now.month &&
                    user.date!.day == now.day;
              case 'this_week':
                final now = DateTime.now();
                final startOfWeek = now.subtract(
                  Duration(days: now.weekday - 1),
                );
                final endOfWeek = startOfWeek.add(const Duration(days: 6));
                return user.date!.isAfter(
                      startOfWeek.subtract(const Duration(days: 1)),
                    ) &&
                    user.date!.isBefore(endOfWeek.add(const Duration(days: 1)));
              case 'this_month':
                final now = DateTime.now();
                return user.date!.year == now.year &&
                    user.date!.month == now.month;
              case 'this_year':
                final now = DateTime.now();
                return user.date!.year == now.year;
              default:
                return true;
            }
          }).toList();
    }

    return filtered;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No Date';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No Data';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Filter User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'Enter full name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'Enter email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter phone number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      selectedDate != null
                          ? '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'
                          : 'Select date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name and Email are required'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final authService = AuthService();
                      final token = await authService.getToken();

                      if (token == null || token.isEmpty) {
                        throw Exception('Authentication token not found');
                      }

                      await FilterUserService.createFilterUser(
                        token,
                        nameController.text,
                        emailController.text,
                        phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                        selectedDate?.toIso8601String(),
                      );

                      Navigator.of(context).pop();
                      _loadData(); // Refresh the data

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add user: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Add User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add New User',
      ),
      body: Row(
        children: [
          const SideBar(),
          Expanded(
            child: Column(
              children: [
                // Header
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
                        'Filter Users Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),

                // Filters Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Search by name, email or ID...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Date Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value:
                                _selectedDateFilter.isEmpty
                                    ? null
                                    : _selectedDateFilter,
                            hint: const Text('Date Filter'),
                            isExpanded: true,
                            underline: Container(),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('All Dates'),
                              ),
                              const DropdownMenuItem(
                                value: 'today',
                                child: Text('Today'),
                              ),
                              const DropdownMenuItem(
                                value: 'this_week',
                                child: Text('This Week'),
                              ),
                              const DropdownMenuItem(
                                value: 'this_month',
                                child: Text('This Month'),
                              ),
                              const DropdownMenuItem(
                                value: 'this_year',
                                child: Text('This Year'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDateFilter = value ?? '';
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add Filter Button
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
                                  builder: (context) => const FilterExcelUploadScreen(),
                                ),
                              );
                              
                              // Refresh the filter list when returning from upload screen
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
                            onTap: () {
                              _showAddFilterDialog();
                            },
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
                                    'Add Filter',
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
                ),

                // Filter Users Table
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                                    'Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Phone',
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
                              ],
                            ),
                          ),

                          // Table Body
                          Expanded(
                            child:
                                _isLoading
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : _filteredData.isEmpty
                                    ? const Center(
                                      child: Text(
                                        'No data found',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: _filteredData.length,
                                      itemBuilder: (context, index) {
                                        final user = _filteredData[index];

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                index.isEven
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
                                                  user.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  user.email,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  user.phone ?? 'No Phone',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        user.phone != null
                                                            ? Colors.black
                                                            : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  _formatDate(user.date),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        user.date != null
                                                            ? Colors.black
                                                            : Colors.grey,
                                                  ),
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
        ],
      ),
    );
  }

  void _showAddFilterDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Filter User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date (Optional) YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
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
                if (nameController.text.isEmpty || emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and Email are required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final authService = AuthService();
                  final token = await authService.getToken();

                  if (token == null || token.isEmpty) {
                    throw Exception('Authentication token not found');
                  }

                  await FilterUserService.createFilterUser(
                    token,
                    nameController.text,
                    emailController.text,
                    phoneController.text.isNotEmpty ? phoneController.text : null,
                    dateController.text.isNotEmpty ? dateController.text : null,
                  );

                  Navigator.of(context).pop();
                  _loadData(); // Refresh the list
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter user added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add filter user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
