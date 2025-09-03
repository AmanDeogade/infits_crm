import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'dart:typed_data';
import '../services/prasad_service.dart';
import 'bars/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrasadamExcelUploadScreen extends StatefulWidget {
  const PrasadamExcelUploadScreen({super.key});

  @override
  State<PrasadamExcelUploadScreen> createState() => _PrasadamExcelUploadScreenState();
}

class _PrasadamExcelUploadScreenState extends State<PrasadamExcelUploadScreen> {
  bool _isLoading = false;
  bool _isUploading = false;
  PlatformFile? _selectedFile;
  List<Map<String, dynamic>> _parsedData = [];
  String? _errorMessage;
  String? _successMessage;

  // Excel parsing logic
  Future<List<Map<String, dynamic>>> parseExcel(Uint8List bytes) async {
    final excelFile = excel.Excel.decodeBytes(bytes);
    final sheet = excelFile.tables.values.first;
    final rows = sheet.rows;
    if (rows.isEmpty) return [];
    
    final headers = rows.first.map((cell) => cell?.value?.toString() ?? '').toList();
    
    return rows.skip(1).map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = i < row.length ? (row[i]?.value?.toString() ?? '') : '';
      }
      return map;
    }).toList();
  }

  // File picking logic
  Future<void> pickFileAndParseExcel() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xls', 'xlsx'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        var selectedFile = result.files.single;
        
        // Check file size (10MB limit)
        if (selectedFile.size > 10 * 1024 * 1024) {
          throw Exception('File size exceeds 10MB limit');
        }

        // Validate file extension
        final fileName = selectedFile.name.toLowerCase();
        if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls') && !fileName.endsWith('.csv')) {
          throw Exception('Please select a valid file (.xlsx, .xls, or .csv)');
        }

        setState(() {
          _selectedFile = selectedFile;
        });

        // Parse Excel
        final excelData = await parseExcel(selectedFile.bytes!);
        
        if (excelData.isEmpty) {
          throw Exception('No data found in Excel file');
        }

        // Validate required columns for prasadam data
        if (excelData.isNotEmpty) {
          final firstRow = excelData.first;
          final hasName = firstRow.keys.any((key) => 
            key.toString() == 'Name' || key.toString() == 'name'
          );
          final hasDate = firstRow.keys.any((key) => 
            key.toString() == 'Date' || key.toString() == 'date'
          );
          final hasStatus = firstRow.keys.any((key) => 
            key.toString() == 'Status' || key.toString() == 'status'
          );
          final hasImages = firstRow.keys.any((key) => 
            key.toString() == 'Images' || key.toString() == 'images'
          );
          final hasEmail = firstRow.keys.any((key) => 
            key.toString() == 'Email' || key.toString() == 'email'
          );

          if (!hasName || !hasDate) {
            throw Exception('Excel file must contain "Name" and "Date" columns');
          }
        }

        setState(() {
          _parsedData = excelData;
          _errorMessage = null;
        });

        _showSuccessDialog(
          'File Parsed Successfully!', 
          'Found ${excelData.length} prasadam records ready for upload.\n\nDetected columns: ${excelData.isNotEmpty ? excelData.first.keys.join(', ') : 'None'}'
        );

      } else {
        setState(() => _selectedFile = null);
      }
    } catch (e) {
      String errorMessage = 'Error processing file: $e';
      
      if (kIsWeb) {
        errorMessage = 'File picker may not work properly on web. Please try a different browser.';
      } else if (e.toString().contains('_Namespace')) {
        errorMessage = 'File picker encountered a platform issue. Please try again.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant file access permissions.';
      }
      
      setState(() {
        _errorMessage = errorMessage;
        _parsedData.clear();
      });
      
      _showErrorDialog('Processing Error', errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upload Prasadam Excel File',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Upload an Excel file (.xlsx) to add multiple prasadam records at once',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          size: 24,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                   
                  const SizedBox(height: 40),
                   
                  // File Upload Area
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : pickFileAndParseExcel,
                        child: Container(
                          width: 600,
                          height: 260,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFBFC9D9),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, 
                                size: 64, 
                                color: const Color(0xFF4A90E2)
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFile == null
                                    ? "Drag & Drop your file here\nor click to browse"
                                    : _selectedFile!.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18, 
                                  color: Color(0xFF2D3748)
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Supports: CSV, XLS, XLSX",
                                style: TextStyle(
                                  fontSize: 13, 
                                  color: Color(0xFF718096)
                                ),
                              ),
                              if (_isLoading) ...[
                                const SizedBox(height: 16),
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                   
                  const SizedBox(height: 40),
                   
                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E8F0),
                            foregroundColor: const Color(0xFF2D3748),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _parsedData.isNotEmpty && !_isUploading ? _uploadData : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E8F0),
                            foregroundColor: const Color(0xFF2D3748),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isUploading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
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
    );
  }

  Future<void> _uploadData() async {
    if (_parsedData.isEmpty) return;
    
    try {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('User not logged in or token missing');
      }

      // Debug: Print token (first 10 characters for security)
      print('Token found: ${token.substring(0, 10)}...');

      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      // Process each prasadam record
      for (int i = 0; i < _parsedData.length; i++) {
        try {
          final prasadam = _parsedData[i];
          
          // Extract prasadam data from Excel row - looking for exact column names
          final donorName = prasadam['Name'] ?? prasadam['name'] ?? '';
          String donationDate = prasadam['Date'] ?? prasadam['date'] ?? '';
          
          // Convert date format from DD-MM-YYYY to YYYY-MM-DD
          if (donationDate.isNotEmpty && donationDate.contains('-')) {
            try {
              final parts = donationDate.split('-');
              if (parts.length == 3) {
                // Assuming format is DD-MM-YYYY
                if (parts[0].length == 2 && parts[1].length == 2 && parts[2].length == 4) {
                  donationDate = '${parts[2]}-${parts[1]}-${parts[0]}';
                  print('Date converted: ${prasadam['Date']} -> $donationDate');
                }
              }
            } catch (e) {
              print('Date conversion failed: $e');
              // Keep original date if conversion fails
            }
          }
          
          // Ensure date is in YYYY-MM-DD format (no time component)
          if (donationDate.contains('T') || donationDate.contains('Z')) {
            donationDate = donationDate.split('T')[0];
            print('Date cleaned: $donationDate');
          }
          
          // Extract status, images, and email using exact column names
          final status = prasadam['Status'] ?? prasadam['status'] ?? 'Not Verified';
          final images = prasadam['Images'] ?? prasadam['images'] ?? 'Not Sent';
          final email = prasadam['Email'] ?? prasadam['email'] ?? 'No';

          // Validate required fields
          if (donorName.isEmpty || donationDate.isEmpty) {
            errorCount++;
            errors.add('Row ${i + 1}: Missing donor name or donation date');
            continue;
          }

          // Validate date format (should be YYYY-MM-DD)
          if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(donationDate)) {
            errorCount++;
            errors.add('Row ${i + 1}: Invalid date format. Expected YYYY-MM-DD, got: $donationDate');
            continue;
          }

          // Debug logging
          print('Creating prasadam: Name=$donorName, Date=$donationDate, Status=$status, Images=$images, Email=$email');

          // Create prasadam in database
          await PrasadService.createPrasad(
            token,
            donorName,
            donationDate,
            status.isEmpty ? 'Not Verified' : status,
            images.isEmpty ? 'Not Sent' : images,
            email.isEmpty ? 'No' : email,
          );

          successCount++;
        } catch (e) {
          errorCount++;
          errors.add('Row ${i + 1}: ${e.toString()}');
        }
      }

      // Show results
      String message = 'Successfully uploaded $successCount prasadam records to database.';
      if (errorCount > 0) {
        message += '\n\n$errorCount records failed to upload.';
        if (errors.isNotEmpty) {
          message += '\n\nErrors:\n${errors.take(5).join('\n')}';
          if (errors.length > 5) {
            message += '\n... and ${errors.length - 5} more errors';
          }
        }
      }

      _showSuccessDialog(
        'Upload Completed!', 
        message,
        onConfirm: () {
          Navigator.of(context).pop(true); // Return true to indicate successful upload
        },
      );

      setState(() {
        _parsedData.clear();
        _selectedFile = null;
      });
      
    } catch (e) {
      _showErrorDialog('Upload Failed', 'Error uploading data: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSuccessDialog(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onConfirm != null) {
                  onConfirm(); // Execute the callback
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}



