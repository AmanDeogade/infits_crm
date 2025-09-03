import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'dart:typed_data';
import '../services/auth_service.dart';
import '../services/filter_user_service.dart';
import 'bars/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterExcelUploadScreen extends StatefulWidget {
  const FilterExcelUploadScreen({super.key});

  @override
  State<FilterExcelUploadScreen> createState() => _FilterExcelUploadScreenState();
}

class _FilterExcelUploadScreenState extends State<FilterExcelUploadScreen> {
  bool _isLoading = false;
  bool _isUploading = false;
  PlatformFile? _selectedFile;
  List<Map<String, dynamic>> _parsedData = [];
  String? _errorMessage;
  String? _successMessage;

  // Same Excel parsing logic as campaign screen
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

  // Same file picking logic as campaign screen
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

        // Parse Excel using same logic as campaign screen
        final excelData = await parseExcel(selectedFile.bytes!);
        
        if (excelData.isEmpty) {
          throw Exception('No data found in Excel file');
        }

        // Validate required columns for filter user data
        if (excelData.isNotEmpty) {
          final firstRow = excelData.first;
          final hasName = firstRow.keys.any((key) => 
            key.toString().toLowerCase().contains('name')
          );
          final hasEmail = firstRow.keys.any((key) => 
            key.toString().toLowerCase().contains('email')
          );

          if (!hasName || !hasEmail) {
            throw Exception('Excel file must contain Name and Email columns');
          }
        }

        setState(() {
          _parsedData = excelData;
          _errorMessage = null;
        });

        _showSuccessDialog(
          'File Parsed Successfully!', 
          'Found ${excelData.length} records ready for upload.\n\nDetected columns: ${excelData.isNotEmpty ? excelData.first.keys.join(', ') : 'None'}'
        );

      } else {
        setState(() {
          _errorMessage = 'No file selected';
        });
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

  Future<void> uploadFilterUsers() async {
    if (_parsedData.isEmpty) {
      setState(() {
        _errorMessage = 'No data to upload. Please parse an Excel file first.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      for (int i = 0; i < _parsedData.length; i++) {
        try {
          final row = _parsedData[i];
          
          // Extract data from row
          final name = row.values.firstWhere(
            (value) => row.keys.elementAt(row.values.toList().indexOf(value)).toString().toLowerCase().contains('name'),
            orElse: () => '',
          ).toString();
          
          final email = row.values.firstWhere(
            (value) => row.keys.elementAt(row.values.toList().indexOf(value)).toString().toLowerCase().contains('email'),
            orElse: () => '',
          ).toString();
          
          final phone = row.values.firstWhere(
            (value) => row.keys.elementAt(row.values.toList().indexOf(value)).toString().toLowerCase().contains('phone'),
            orElse: () => '',
          ).toString();
          
          final date = row.values.firstWhere(
            (value) => row.keys.elementAt(row.values.toList().indexOf(value)).toString().toLowerCase().contains('date'),
            orElse: () => '',
          ).toString();

          if (name.isEmpty || email.isEmpty) {
            errorCount++;
            errors.add('Row ${i + 1}: Name and Email are required');
            continue;
          }

          await FilterUserService.createFilterUser(
            token,
            name,
            email,
            phone.isNotEmpty ? phone : null,
            date.isNotEmpty ? date : null,
          );

          successCount++;
        } catch (e) {
          errorCount++;
          errors.add('Row ${i + 1}: ${e.toString()}');
        }
      }

             setState(() {
         _isUploading = false;
         if (errorCount > 0) {
           _errorMessage = 'Upload completed with errors.\n\nSuccessfully uploaded: $successCount\nFailed: $errorCount\n\nErrors:\n${errors.take(5).join('\n')}${errors.length > 5 ? '\n... and ${errors.length - 5} more errors' : ''}';
         } else {
           _showSuccessDialog(
             'Upload Successful!',
             'Successfully uploaded $successCount filter users!'
           );
         }
       });

    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Upload failed: ${e.toString()}';
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(true); // Return to previous screen with success
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upload Filter Users Excel File',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Upload an Excel file (.xlsx) to add multiple filter users at once',
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
                          onPressed: _parsedData.isNotEmpty && !_isUploading ? uploadFilterUsers : null,
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
}
