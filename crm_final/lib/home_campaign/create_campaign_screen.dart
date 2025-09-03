import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart'; // Use excel package for reading Excel files
import 'package:http/http.dart' as http;

class CreateCampaignScreen extends StatefulWidget {
  @override
  _CreateCampaignScreenState createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  String status = 'No file selected';
  List<Map<String, dynamic>> leads = []; // Store extracted leads
  String campaignName = '';
  String campaignId = '';
  bool isSaving = false;

  Future<void> pickAndExtractExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true, // Important for web!
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final excel = Excel.decodeBytes(bytes);

        final sheet = excel.tables.values.first;
        final rows = sheet.rows;

        if (rows.isEmpty) {
          setState(() {
            status = 'Excel file is empty or invalid.';
            leads = [];
          });
          return;
        }

        // Find header row and map columns
        final headerRow = rows.first;
        Map<String, int> headerMap = {};
        List<String> detectedHeaders = [];
        for (int i = 0; i < headerRow.length; i++) {
          final cell = headerRow[i];
          String header = '';
          if (cell != null) {
            if (cell is Data) {
              header = cell.value?.toString().toLowerCase().trim() ?? '';
            } else {
              header = cell.toString().toLowerCase().trim();
            }
          }
          if (header.isNotEmpty) {
            headerMap[header] = i;
            detectedHeaders.add(header);
          }
        }

        // New columns
        final firstNameIdx = headerMap['first_name'];
        final lastNameIdx = headerMap['last_name'];
        final emailIdx = headerMap['email'];
        final phoneIdx = headerMap['phone'];
        final altPhoneIdx = headerMap['alt_phone'];
        final addressLineIdx = headerMap['address_line'];
        final cityIdx = headerMap['city'];
        final stateIdx = headerMap['state'];
        final countryIdx = headerMap['country'];

        if (firstNameIdx == null || lastNameIdx == null || emailIdx == null) {
          setState(() {
            status = 'Excel file must have columns: first_name, last_name, email\nDetected headers: ' + detectedHeaders.join(', ');
            leads = [];
          });
          return;
        }

        List<Map<String, dynamic>> extractedLeads = [];
        Set<String> seenEmails = {};
        int duplicateCount = 0;
        String extractCellValue(dynamic cell) {
          if (cell == null) return '';
          String value = '';
          if (cell is Data) {
            value = cell.value?.toString().trim() ?? '';
          } else {
            value = cell.toString().trim();
          }
          if (value.toLowerCase() == 'n/a') return '';
          return value;
        }
        for (var row in rows.skip(1)) {
          final firstName = (firstNameIdx < row.length) ? extractCellValue(row[firstNameIdx]) : '';
          final lastName = (lastNameIdx < row.length) ? extractCellValue(row[lastNameIdx]) : '';
          final email = (emailIdx < row.length) ? extractCellValue(row[emailIdx]) : '';
          final phone = (phoneIdx != null && phoneIdx < row.length) ? extractCellValue(row[phoneIdx]) : '';
          final altPhone = (altPhoneIdx != null && altPhoneIdx < row.length) ? extractCellValue(row[altPhoneIdx]) : '';
          final addressLine = (addressLineIdx != null && addressLineIdx < row.length) ? extractCellValue(row[addressLineIdx]) : '';
          final city = (cityIdx != null && cityIdx < row.length) ? extractCellValue(row[cityIdx]) : '';
          final state = (stateIdx != null && stateIdx < row.length) ? extractCellValue(row[stateIdx]) : '';
          final country = (countryIdx != null && countryIdx < row.length) ? extractCellValue(row[countryIdx]) : '';

          if (firstName.isNotEmpty && lastName.isNotEmpty && email.isNotEmpty) {
            if (!seenEmails.contains(email.toLowerCase())) {
              seenEmails.add(email.toLowerCase());
              extractedLeads.add({
                "first_name": firstName,
                "last_name": lastName,
                "email": email,
                "phone": phone,
                "alt_phone": altPhone,
                "address_line": addressLine,
                "city": city,
                "state": state,
                "country": country,
              });
            } else {
              duplicateCount++;
            }
          }
        }

        setState(() {
          leads = extractedLeads;
          status =
              leads.isNotEmpty
                  ? 'Extracted ' + leads.length.toString() + ' leads' + (duplicateCount > 0 ? ' (Eliminated ' + duplicateCount.toString() + ' duplicate email entr' + (duplicateCount == 1 ? 'y' : 'ies') + ')' : '')
                  : 'Excel file is empty or invalid.';
        });
      } else {
        setState(() => status = 'No file selected');
      }
    } catch (e) {
      setState(() => status = 'Error: ' + e.toString());
    }
  }

  Future<void> saveLeadsToBackend() async {
    if (campaignId.isEmpty) {
      setState(() {
        status = 'Please enter a campaign ID before saving leads.';
      });
      return;
    }
    setState(() { isSaving = true; status = 'Checking for duplicates...'; });
    // Fetch all existing leads from backend
    List<dynamic> existingLeads = [];
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/leads'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        existingLeads = data['leads'] ?? [];
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        status = 'Failed to fetch existing leads.';
      });
      return;
    }
    final existingEmails = existingLeads.map((l) => (l['email'] ?? '').toString().toLowerCase()).toSet();
    final leadsToSave = leads.where((lead) => !existingEmails.contains((lead['email'] ?? '').toString().toLowerCase())).toList();
    if (leadsToSave.isEmpty) {
      setState(() {
        isSaving = false;
        status = 'No new leads to save (all emails already exist).';
      });
      return;
    }
    setState(() { status = 'Saving ${leadsToSave.length} new leads...'; });
    int success = 0;
    int fail = 0;
    for (final lead in leadsToSave) {
      final leadWithCampaign = Map<String, dynamic>.from(lead);
      leadWithCampaign['campaign_id'] = campaignId;
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/leads'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(leadWithCampaign),
        );
        if (response.statusCode == 201) {
          success++;
        } else {
          fail++;
        }
      } catch (e) {
        fail++;
      }
    }
    setState(() {
      isSaving = false;
      status = 'Saved $success new leads. Failed: $fail. Skipped: ${leads.length - leadsToSave.length} (already exist)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Excel File Uploader')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Campaign Name'),
                    onChanged: (val) => setState(() => campaignName = val),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Campaign ID'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => campaignId = val),
                  ),
                ],
              ),
            ),
            Text(status, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickAndExtractExcelFile,
              child: Text('Select Excel File'),
            ),
            SizedBox(height: 20),
            if (leads.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          return ListTile(
                            title: Text('Name: ' + lead['first_name'] + ' ' + lead['last_name']),
                            subtitle: Text(
                              'Email: ' + lead['email'] +
                              (lead['phone'].isNotEmpty ? ' | Phone: ' + lead['phone'] : '') +
                              (lead['alt_phone'].isNotEmpty ? ' | Alt Phone: ' + lead['alt_phone'] : '') +
                              (lead['address_line'].isNotEmpty ? ' | Address: ' + lead['address_line'] : '') +
                              (lead['city'].isNotEmpty ? ' | City: ' + lead['city'] : '') +
                              (lead['state'].isNotEmpty ? ' | State: ' + lead['state'] : '') +
                              (lead['country'].isNotEmpty ? ' | Country: ' + lead['country'] : ''),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isSaving ? null : saveLeadsToBackend,
                      child: isSaving ? CircularProgressIndicator() : Text('Save Leads to Backend'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
