import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'bars/side_bar.dart';
import '../services/filter_user_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadFilterScreen extends StatefulWidget {
  const UploadFilterScreen({super.key});

  @override
  State<UploadFilterScreen> createState() => _UploadFilterScreenState();
}

class _UploadFilterScreenState extends State<UploadFilterScreen> {
  bool _isUploading = false;
  bool _isProcessing = false;
  String? _selectedFileName;
  List<Map<String, dynamic>>? _excelData;
  List<Map<String, dynamic>> _processedData = [];
  String? _errorMessage;
  int _successCount = 0;
  int _errorCount = 0;

  // Removed redundant build method.

  Future<void> _pickFile() async {
    setState(() {
      _isUploading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
        });

        // Read and parse the Excel file
        if (file.bytes != null) {
          var excelFile = excel.Excel.decodeBytes(file.bytes!);

          // Process the Excel data
          List<Map<String, dynamic>> excelData = [];

          for (var table in excelFile.tables.keys) {
            var sheet = excelFile.tables[table]!;
            bool isFirstRow = true;

            for (var row in sheet.rows) {
              if (row.isNotEmpty) {
                if (isFirstRow) {
                  // Skip header row
                  isFirstRow = false;
                  continue;
                }

                Map<String, dynamic> rowData = {};
                for (int i = 0; i < row.length; i++) {
                  rowData['column_$i'] = row[i]?.value?.toString() ?? '';
                }
                excelData.add(rowData);
              }
            }
          }

          setState(() {
            _excelData = excelData;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Excel file uploaded successfully! Found ${excelData.length} rows.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _processAndUploadData() async {
    if (_excelData == null || _excelData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an Excel file first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _successCount = 0;
      _errorCount = 0;
    });

    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Process Excel data to extract name, email, phone
      List<Map<String, dynamic>> usersToUpload = [];

      for (int i = 0; i < _excelData!.length; i++) {
        try {
          final row = _excelData![i];

          // Extract data from columns (assuming: column_0 = name, column_1 = email, column_2 = phone)
          String name = row['column_0']?.toString().trim() ?? '';
          String email = row['column_1']?.toString().trim() ?? '';

          // Handle phone number conversion from scientific notation to regular format
          String phone = '';
          var phoneValue = row['column_2'];
          if (phoneValue != null) {
            if (phoneValue is num) {
              // Convert scientific notation to regular number format
              phone = phoneValue.toInt().toString();
            } else {
              phone = phoneValue.toString().trim();
            }
          }

          // Validate required fields
          if (name.isEmpty || email.isEmpty) {
            _errorCount++;
            continue;
          }

          // Basic email validation
          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
            _errorCount++;
            continue;
          }

          Map<String, dynamic> userData = {'name': name, 'email': email};

          if (phone.isNotEmpty) {
            userData['phone'] = phone;
          }

          usersToUpload.add(userData);
        } catch (e) {
          // Skip this row if there's an error processing it
          _errorCount++;
          continue;
        }
      }

      if (usersToUpload.isEmpty) {
        throw Exception(
          'No valid data found in the Excel file. Please check the format.',
        );
      }

      // Upload data to filter_users table
      final insertIds = await FilterUserService.bulkCreateFilterUsers(
        token,
        usersToUpload,
      );

      setState(() {
        _successCount = insertIds.length;
        _processedData = usersToUpload;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully uploaded $_successCount users to filter list!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after successful upload
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handleNext() {
    _processAndUploadData();
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
                // Header with close button and title
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
                        'Upload Excel File',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // Close button in top right
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Instructional text
                        const Text(
                          'Upload an Excel file (.xlsx) to add multiple users to the filter list',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Excel format: Column A = Name, Column B = Email, Column C = Phone (optional)',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                        // Drag & Drop area
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE3F2FD,
                              ), // Light blue background
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFF1976D2,
                                ), // Dark blue border
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _isUploading ? null : _pickFile,
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Upload icon
                                      Icon(
                                        Icons.cloud_upload,
                                        size: 64,
                                        color: const Color(
                                          0xFF1976D2,
                                        ), // Dark blue
                                      ),
                                      const SizedBox(height: 24),

                                      // Drag & Drop text
                                      const Text(
                                        'Drag & Drop your file here',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Click to browse text
                                      Text(
                                        'or click to browse',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(
                                            0xFF1976D2,
                                          ), // Blue text
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Supported file types
                                      const Text(
                                        'Supports: CSV, XLS, XLSX',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      // Show selected file name if uploaded
                                      if (_selectedFileName != null) ...[
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green.shade600,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _selectedFileName!,
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      // Show loading indicator if uploading
                                      if (_isUploading) ...[
                                        const SizedBox(height: 20),
                                        const CircularProgressIndicator(
                                          color: Color(0xFF1976D2),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Processing status and results
                        if (_isProcessing ||
                            _successCount > 0 ||
                            _errorCount > 0 ||
                            _errorMessage != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_isProcessing) ...[
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Processing Excel data and uploading to filter users...',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_successCount > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Successfully uploaded $_successCount users to filter list',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_errorCount > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.orange.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_errorCount rows had invalid data and were skipped',
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Error: $_errorMessage',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        // Navigation buttons
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Back button
                            TextButton(
                              onPressed:
                                  _isProcessing
                                      ? null
                                      : () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Upload button
                            ElevatedButton(
                              onPressed:
                                  (_excelData != null && !_isProcessing)
                                      ? _handleNext
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _successCount > 0
                                        ? Colors.green.shade600
                                        : const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _isProcessing
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        _successCount > 0
                                            ? 'Upload Complete'
                                            : 'Upload to Filter List',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ],
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
