import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch users: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesRole = _selectedRoleFilter == 'all' ||
          user['role'] == _selectedRoleFilter;
      
      return matchesSearch && matchesRole;
    }).toList();
  }

  String _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return '#FF6B6B';
      case 'manager':
        return '#4ECDC4';
      case 'marketing':
        return '#45B7D1';
      case 'caller':
        return '#96CEB4';
      default:
        return '#95A5A6';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar (you can import your existing sidebar)
          Container(
            width: 250,
            color: Colors.grey[100],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.blue),
                      const SizedBox(width: 10),
                      const Text(
                        'Users Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('All Users'),
                  selected: true,
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Add User'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddUserScreen(),
                      ),
                    ).then((_) => _fetchUsers());
                  },
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header with search and filters
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedRoleFilter,
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Roles')),
                          const DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          const DropdownMenuItem(value: 'manager', child: Text('Manager')),
                          const DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
                          const DropdownMenuItem(value: 'caller', child: Text('Caller')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRoleFilter = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchUsers,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Users table
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                'No users found',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Initials')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Created')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _filteredUsers.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user['id'].toString())),
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Color(int.parse(
                                                _getRoleColor(user['role']).replaceAll('#', '0xFF'),
                                              )),
                                              child: Text(
                                                user['initials'] ?? 'NA',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                user['name'] ?? 'N/A',
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(user['email'] ?? 'N/A')),
                                      DataCell(Text(user['initials'] ?? 'N/A')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(
                                              _getRoleColor(user['role']).replaceAll('#', '0xFF'),
                                            )).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Color(int.parse(
                                                _getRoleColor(user['role']).replaceAll('#', '0xFF'),
                                              )),
                                            ),
                                          ),
                                          child: Text(
                                            user['role'] ?? 'N/A',
                                            style: TextStyle(
                                              color: Color(int.parse(
                                                _getRoleColor(user['role']).replaceAll('#', '0xFF'),
                                              )),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(user['phone'] ?? 'N/A')),
                                      DataCell(
                                        Text(
                                          user['created_at'] != null
                                              ? DateTime.parse(user['created_at'])
                                                  .toString()
                                                  .split(' ')[0]
                                              : 'N/A',
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 18),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditUserScreen(user: user),
                                                  ),
                                                ).then((_) => _fetchUsers());
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                              onPressed: () async {
                                                // Show confirmation dialog
                                                bool? confirmDelete = await showDialog<bool>(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Delete User'),
                                                      content: Text(
                                                        'Are you sure you want to delete ${user['name']}? This action cannot be undone.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(false),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(true),
                                                          style: TextButton.styleFrom(
                                                            foregroundColor: Colors.red,
                                                          ),
                                                          child: const Text('Delete'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (confirmDelete == true) {
                                                  // Delete user
                                                  try {
                                                    final response = await http.delete(
                                                      Uri.parse('http://localhost:3000/users/${user['id']}'),
                                                    );

                                                    if (response.statusCode == 200) {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('User deleted successfully!'),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                        _fetchUsers(); // Refresh the list
                                                      }
                                                    } else {
                                                      final errorData = json.decode(response.body);
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(errorData['error'] ?? 'Failed to delete user'),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Error deleting user: $e'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
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