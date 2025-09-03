import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crm_final/home_campaign/home_campaign_screen.dart';
// If your main campaign screen widget is named Home_Campaign, ensure it's imported and used below.
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:crm_final/services/caller_service.dart';
import 'package:crm_final/models/caller.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_final/services/filter_user_service.dart';
import 'create_campaign_dialog.dart';

PreferredSizeWidget buildWizardHeaderInternal(BuildContext context) {
  return AppBar(
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    actions: [
      IconButton(
        icon: Icon(Icons.close, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

class ImportLeadsWizard extends StatefulWidget {
  @override
  _ImportLeadsWizardState createState() => _ImportLeadsWizardState();
}

class _ImportLeadsWizardState extends State<ImportLeadsWizard> {
  PlatformFile? selectedFile;

  Widget buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isActive ? Colors.blue : Colors.grey[300],
          child: Text(
            '$step',
            style: TextStyle(color: isActive ? Colors.white : Colors.black),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // You can use your existing build method implementation here.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildWizardHeaderInternal(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24),
              buildWizardTitleInternal(),
              SizedBox(height: 32),
              buildCustomStepper(0),
              SizedBox(height: 48),
              buildUploadBox(context, selectedFile),
              SizedBox(height: 48),
              buildWizardButtons(
                onBack: null, // Disabled for first step
                onNext: selectedFile != null ? () {} : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top-level function so it can be used anywhere
Widget buildWizardTitleInternal() {
  return Text(
    "Import Leads",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );
}

Future<List<Map<String, dynamic>>> parseExcel(Uint8List bytes) async {
  final excelFile = excel.Excel.decodeBytes(bytes);
  final sheet = excelFile.tables.values.first;
  final rows = sheet.rows;
  if (rows.isEmpty) return [];
  final headers =
      rows.first.map((cell) => cell?.value?.toString() ?? '').toList();
  return rows.skip(1).map((row) {
    final map = <String, dynamic>{};
    for (int i = 0; i < headers.length; i++) {
      map[headers[i]] = i < row.length ? (row[i]?.value?.toString() ?? '') : '';
    }
    return map;
  }).toList();
}

Future<void> pickFileAndParseExcel(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv', 'xls', 'xlsx'],
    withData: true,
  );
  if (result != null && result.files.single.bytes != null) {
    // setState(() {

    // });
    var selectedFile = result.files.single;
    final excelData = await parseExcel(result.files.single.bytes!);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FieldMappingScreen(mappedLeads: excelData),
      ),
    );
  }
}

Widget buildCustomStepper(int activeStep) {
  List<String> steps = [
    "Sheet Selection",
    "Field Mapping",
    "Duplicate Checking",
    "Campaign & List Confirmation",
    "Lead Distribution",
  ];
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(steps.length, (index) {
      bool isActive = index <= activeStep;
      return Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor:
                    isActive ? Color(0xFF4A90E2) : Color(0xFFBFC9D9),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                steps[index],
                style: TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ],
          ),
          if (index < steps.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(width: 30, height: 2, color: Color(0xFFBFC9D9)),
            ),
        ],
      );
    }),
  );
}

PreferredSizeWidget buildWizardHeader(BuildContext context) {
  return AppBar(
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    actions: [
      IconButton(
        icon: Icon(Icons.close, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

Widget buildWizardTitle() {
  return Text(
    "Import Leads",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );
}

Widget buildWizardButtons({
  required VoidCallback? onBack,
  required VoidCallback? onNext,
  bool isBackEnabled = true,
  bool isNextEnabled = true,
  bool isLoading = false,
  String nextText = "Next",
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      OutlinedButton(
        onPressed: isBackEnabled ? onBack : null,
        style: OutlinedButton.styleFrom(minimumSize: Size(100, 44)),
        child: Text("Back"),
      ),
      SizedBox(width: 16),
      ElevatedButton(
        onPressed: isNextEnabled && !isLoading ? onNext : null,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(100, 44),
          backgroundColor: Color(0xFF4A90E2),
          disabledBackgroundColor: Color(0xFFBFC9D9),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(nextText),
      ),
    ],
  );
}

Widget buildUploadBox(BuildContext context, PlatformFile? selectedFile) {
  return GestureDetector(
    onTap: () => pickFileAndParseExcel(context),
    child: DottedBorder(
      color: Color(0xFFBFC9D9),
      strokeWidth: 1.5,
      dashPattern: [6, 4],
      borderType: BorderType.RRect,
      radius: Radius.circular(16),
      child: Container(
        width: 600,
        height: 260,
        decoration: BoxDecoration(
          color: Color(0xFFEAF6FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 64, color: Color(0xFF4A90E2)),
            SizedBox(height: 16),
            Text(
              selectedFile == null
                  ? "Drag & Drop your file here\nor click to browse"
                  : selectedFile!.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              "Supports: CSV, XLS, XLSX",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    ),
  );
}

// Duplicate build method removed. The correct build method is already present above.

// Update FieldMappingScreen to accept and pass mapped leads
class FieldMappingScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mappedLeads;
  FieldMappingScreen({Key? key, required this.mappedLeads}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildWizardHeader(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24),
              buildWizardTitle(),
              SizedBox(height: 32),
              buildCustomStepper(1),
              SizedBox(height: 48),
              Expanded(
                child:
                    mappedLeads.isEmpty
                        ? Center(child: Text('No data found in Excel.'))
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns:
                                mappedLeads.first.keys
                                    .map(
                                      (key) => DataColumn(
                                        label: Text(
                                          key.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            rows:
                                mappedLeads
                                    .map(
                                      (row) => DataRow(
                                        cells:
                                            row.values
                                                .map(
                                                  (val) => DataCell(
                                                    Text(val.toString()),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
              ),
              SizedBox(height: 48),
              buildWizardButtons(
                onBack: () => Navigator.pop(context),
                onNext: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              DuplicateCheckingScreen(leads: mappedLeads),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Update DuplicateCheckingScreen to navigate to CampaignListConfirmationScreen
class DuplicateCheckingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> leads;
  DuplicateCheckingScreen({Key? key, required this.leads}) : super(key: key);

  @override
  _DuplicateCheckingScreenState createState() =>
      _DuplicateCheckingScreenState();
}

class _DuplicateCheckingScreenState extends State<DuplicateCheckingScreen> {
  bool _isLoadingFilterCheck = false;
  int _filterUserMatches = 0;
  List<Map<String, dynamic>> _filterMatchedLeads = [];

  @override
  void initState() {
    super.initState();
    _checkFilterUsers();
  }

  Future<void> _checkFilterUsers() async {
    setState(() {
      _isLoadingFilterCheck = true;
    });

    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Get all filter users
      final filterUsers = await FilterUserService.getAllFilterUsers(token);

      // Check for matches
      int matchCount = 0;
      List<Map<String, dynamic>> matchedLeads = [];

      for (var lead in widget.leads) {
        final leadName = (lead['name'] ?? '').toString().trim().toLowerCase();
        final leadEmail = (lead['email'] ?? '').toString().trim().toLowerCase();
        final leadPhone = (lead['phone'] ?? '').toString().trim();

        // Check if any filter user matches this lead
        bool hasMatch = filterUsers.any((filterUser) {
          final filterName =
              (filterUser['name'] ?? '').toString().trim().toLowerCase();
          final filterEmail =
              (filterUser['email'] ?? '').toString().trim().toLowerCase();
          final filterPhone = (filterUser['phone'] ?? '').toString().trim();

          // Check for matches on name, email, or phone
          return (leadName.isNotEmpty &&
                  filterName.isNotEmpty &&
                  leadName == filterName) ||
              (leadEmail.isNotEmpty &&
                  filterEmail.isNotEmpty &&
                  leadEmail == filterEmail) ||
              (leadPhone.isNotEmpty &&
                  filterPhone.isNotEmpty &&
                  leadPhone == filterPhone);
        });

        if (hasMatch) {
          matchCount++;
          matchedLeads.add(lead);
        }
      }

      setState(() {
        _filterUserMatches = matchCount;
        _filterMatchedLeads = matchedLeads;
      });
    } catch (e) {
      print('Error checking filter users: $e');
      // Don't show error to user, just continue with 0 matches
    } finally {
      setState(() {
        _isLoadingFilterCheck = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Analyze for duplicates and empty required fields (email and phone)
    final Set<String> seenEmails = {};
    final Set<String> seenPhones = {};
    int duplicateCount = 0;
    int emptyEmailCount = 0;
    int emptyPhoneCount = 0;
    int total = widget.leads.length;
    List<Map<String, dynamic>> uniqueLeads = [];
    for (var lead in widget.leads) {
      final email = (lead['email'] ?? '').toString().trim().toLowerCase();
      final phone = (lead['phone'] ?? '').toString().trim();
      bool isEmailEmpty = email.isEmpty;
      bool isPhoneEmpty = phone.isEmpty;
      if (isEmailEmpty && isPhoneEmpty) {
        emptyEmailCount++;
        emptyPhoneCount++;
        continue;
      }
      if ((!isEmailEmpty && seenEmails.contains(email)) ||
          (!isPhoneEmpty && seenPhones.contains(phone))) {
        duplicateCount++;
        continue;
      }
      if (!isEmailEmpty) seenEmails.add(email);
      if (!isPhoneEmpty) seenPhones.add(phone);
      uniqueLeads.add(lead);
    }
    int proceedCount = uniqueLeads.length;

    // Calculate final count excluding filter user matches and TeleCRM duplicates
    int telecrmDuplicates =
        0; // Simulate TeleCRM backend duplicates (for now, none)
    int finalCreateCount =
        proceedCount - _filterUserMatches - telecrmDuplicates;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildWizardHeader(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [buildWizardTitle()],
              ),
              SizedBox(height: 16),
              buildCustomStepper(2),
              SizedBox(height: 20),
              // File Error Section
              _warningSection(
                title: 'File Error',
                subtitle: 'Duplicate or empty values for EMAIL or PHONE',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (duplicateCount > 0 ||
                        emptyEmailCount > 0 ||
                        emptyPhoneCount > 0)
                      _infoBox(
                        icon: Icons.table_chart,
                        color: Colors.orange[100]!,
                        text:
                            'Ignore $duplicateCount duplicate emails/phones and $emptyEmailCount empty email, $emptyPhoneCount empty phone, from $total entries',
                        iconColor: Colors.orange,
                      ),
                    SizedBox(height: 12),
                    _infoBox(
                      icon: Icons.info_outline,
                      color: Colors.blue[50]!,
                      text:
                          'Proceeding with $proceedCount entries from original excel sheet',
                      iconColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // TeleCRM Duplicates Section
              _warningSection(
                title: 'TeleCRM Duplicates',
                subtitle:
                    'Leads from the file which are already present in Telecrm based on email',
                child: _infoBox(
                  icon: Icons.info_outline,
                  color: Colors.blue[50]!,
                  text: 'TeleCRM duplicates: $telecrmDuplicates',
                  iconColor: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              // Filter Users Matches Section
              _warningSection(
                title: 'Filter Users Matches',
                subtitle:
                    'Leads from the file which match with users in the filter list (name, email, or phone)',
                child:
                    _isLoadingFilterCheck
                        ? Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Checking against filter users...',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                        : _infoBox(
                          icon: Icons.filter_list,
                          color: Colors.orange[50]!,
                          text:
                              _filterUserMatches > 0
                                  ? '$_filterUserMatches leads match with filter users and will be excluded'
                                  : 'No leads match with filter users',
                          iconColor: Colors.orange,
                        ),
              ),
              SizedBox(height: 20),
              // Final Summary Section
              _warningSection(
                title: 'Final Summary',
                subtitle: 'Total leads that will be created',
                child: _infoBox(
                  icon: Icons.assignment,
                  color: Colors.green[50]!,
                  text:
                      'Proceed to create $finalCreateCount leads from excel sheet',
                  iconColor: Colors.green,
                ),
              ),
              SizedBox(height: 32),
              buildWizardButtons(
                onBack: () => Navigator.pop(context),
                onNext: () {
                  // Filter out leads that match with filter users
                  List<Map<String, dynamic>> filteredLeads =
                      uniqueLeads.where((lead) {
                        final leadName =
                            (lead['name'] ?? '')
                                .toString()
                                .trim()
                                .toLowerCase();
                        final leadEmail =
                            (lead['email'] ?? '')
                                .toString()
                                .trim()
                                .toLowerCase();
                        final leadPhone =
                            (lead['phone'] ?? '').toString().trim();

                        // Check if this lead matches any filter user
                        return !_filterMatchedLeads.any((matchedLead) {
                          final matchedName =
                              (matchedLead['name'] ?? '')
                                  .toString()
                                  .trim()
                                  .toLowerCase();
                          final matchedEmail =
                              (matchedLead['email'] ?? '')
                                  .toString()
                                  .trim()
                                  .toLowerCase();
                          final matchedPhone =
                              (matchedLead['phone'] ?? '').toString().trim();

                          return (leadName.isNotEmpty &&
                                  matchedName.isNotEmpty &&
                                  leadName == matchedName) ||
                              (leadEmail.isNotEmpty &&
                                  matchedEmail.isNotEmpty &&
                                  leadEmail == matchedEmail) ||
                              (leadPhone.isNotEmpty &&
                                  matchedPhone.isNotEmpty &&
                                  leadPhone == matchedPhone);
                        });
                      }).toList();

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => CampaignListConfirmationScreen(
                            leads: filteredLeads,
                            filterUserMatches: _filterUserMatches,
                          ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isActive ? Colors.blue : Colors.grey[300],
          child: Text(
            '$step',
            style: TextStyle(color: isActive ? Colors.white : Colors.black),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _warningSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
        SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String text,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// CampaignListConfirmationScreen implementation
class CampaignListConfirmationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> leads;
  final int filterUserMatches;
  CampaignListConfirmationScreen({
    Key? key,
    required this.leads,
    required this.filterUserMatches,
  }) : super(key: key);
  @override
  _CampaignListConfirmationScreenState createState() =>
      _CampaignListConfirmationScreenState();
}

class _CampaignListConfirmationScreenState
    extends State<CampaignListConfirmationScreen> {
  String campaignName = '';
  Set<int> selectedCallerIds = {};
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _callersDropdownOverlay;
  final GlobalKey _dropdownKey = GlobalKey();
  List<Caller> callers = [];
  bool isCallersLoading = true;
  String? callersError;
  bool isLoading = false;

  // Remove existingCampaigns and selectedCampaign
  bool isCampaignsLoading = false;
  String? campaignsError;

  final TextEditingController _campaignController = TextEditingController();

  @override
  void dispose() {
    _campaignController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchCampaignSuggestions(String pattern) async {
    try {
      print('Fetching campaigns with pattern: "$pattern"');
      final response = await http.get(
        Uri.parse('http://localhost:3000/campaigns'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Campaign response status: ${response.statusCode}');
      print('Campaign response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List campaignsJson = data['campaigns'] ?? [];
        print('Found ${campaignsJson.length} campaigns in response');

        final allCampaignNames =
            campaignsJson.map((c) => c['name'].toString()).toList();

        // If pattern is empty, return all campaigns
        if (pattern.isEmpty) {
          print('Returning all ${allCampaignNames.length} campaigns');
          return allCampaignNames;
        }

        // If pattern is not empty, filter by pattern
        final filteredCampaigns =
            allCampaignNames
                .where(
                  (name) => name.toLowerCase().contains(pattern.toLowerCase()),
                )
                .toList();
        print('Returning ${filteredCampaigns.length} filtered campaigns');
        return filteredCampaigns;
      } else {
        print('Failed to fetch campaigns: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching campaign suggestions: $e');
    }
    return [];
  }

  // Add this helper function inside _CampaignListConfirmationScreenState
  Future<int?> getCampaignIdByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/campaigns'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List campaignsJson = data['campaigns'] ?? [];
        final campaign = campaignsJson.firstWhere(
          (c) => (c['name'] as String).toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
        if (campaign != null && campaign['id'] != null) {
          return campaign['id'] as int;
        }
      }
    } catch (e) {
      print('Error getting campaign ID by name: $e');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchCallers();
    // fetchCampaigns(); // This function is no longer needed for the dropdown
  }

  Future<void> fetchCallers() async {
    setState(() {
      isCallersLoading = true;
      callersError = null;
    });
    try {
      print('Fetching callers from database...');
      callers = await CallerService.fetchCallers();
      print('Fetched ${callers.length} callers from database:');
      for (var caller in callers) {
        print('- ${caller.name} (ID: ${caller.id})');
      }
      setState(() {
        isCallersLoading = false;
      });
    } catch (e) {
      print('Error fetching callers: $e');
      setState(() {
        callersError = 'Failed to load callers: $e';
        isCallersLoading = false;
      });
    }
  }

  Future<int?> createCampaignOnBackend(String name, String list) async {
    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No authentication token found');
        return null;
      }

      final response = await http.post(
        Uri.parse('http://localhost:3000/campaigns'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'description': list}),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['campaign']['id'];
      } else {
        print('Campaign creation failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in createCampaignOnBackend: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendLeadsToBackendWithCampaignId(
    int campaignId,
    List<Map<String, dynamic>> leads,
  ) async {
    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No authentication token found');
        return null;
      }

      // Attach campaign_id to each lead
      final leadsWithCampaign =
          leads.map((lead) => {...lead, 'campaign_id': campaignId}).toList();

      // Convert selectedCallerIds to list
      final callerIds = selectedCallerIds.toList();

      final response = await http.post(
        Uri.parse('http://localhost:3000/leads/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'campaign': campaignId,
          'leads': leadsWithCampaign,
          'callers': callerIds,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Bulk import failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in sendLeadsToBackendWithCampaignId: $e');
      return null;
    }
  }

  void _showCampaignCreatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CampaignCreatedDialog(),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final insertedCount = result['inserted_count'] ?? 0;
    final assigneesAdded = result['assignees_added'] ?? 0;
    final leadAssignments = result['lead_assignments'] ?? [];
    final distributionSummary = result['distribution_summary'] ?? {};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Import Successful'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ $insertedCount leads imported successfully'),
                  SizedBox(height: 8),
                  Text('👥 $assigneesAdded callers added to campaign'),
                  if (widget.filterUserMatches > 0) ...[
                    SizedBox(height: 8),
                    Text(
                      '🚫 ${widget.filterUserMatches} leads excluded (matched with filter users)',
                    ),
                  ],
                  SizedBox(height: 16),
                  Text(
                    '📊 Lead Distribution Summary:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Total leads: ${distributionSummary['total_leads'] ?? 0}',
                  ),
                  Text(
                    '• Total callers: ${distributionSummary['total_callers'] ?? 0}',
                  ),
                  Text(
                    '• Average leads per caller: ${distributionSummary['leads_per_caller'] ?? 0}',
                  ),
                  SizedBox(height: 16),
                  if (leadAssignments.isNotEmpty) ...[
                    Text(
                      '📋 Lead Assignments:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 150,
                      child: ListView.builder(
                        itemCount: leadAssignments.length,
                        itemBuilder: (context, index) {
                          final assignment = leadAssignments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• Lead ${assignment['lead_id']} → ${assignment['assignee_name']}',
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎉 Campaign Successfully Created!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your campaign is now ready with leads randomly distributed among callers. You can view and manage the campaign from the main campaign screen.',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text('View Details'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close wizard
                  MaterialPageRoute(builder: (context) => Home_Campaign());
                  //  MaterialPageRoute(builder: (context) => HomeCampaignScreen()),
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Continue to Campaign'),
              ),
            ],
          ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onNextPressed() async {
    if ((campaignName.isEmpty) || selectedCallerIds.isEmpty) {
      _showError(
        'Please enter a campaign name and select at least one caller.',
      );
      return;
    }
    setState(() => isLoading = true);
    bool success = false;
    int? campaignId = await getCampaignIdByName(campaignName);
    if (campaignId == null) {
      // Campaign does not exist, create it
      final selectedNames = callers
          .where((c) => selectedCallerIds.contains(c.id))
          .map((c) => c.name)
          .join(', ');
      campaignId = await createCampaignOnBackend(
        campaignName,
        'Callers: $selectedNames',
      );
      if (campaignId == null) {
        setState(() => isLoading = false);
        _showError('Failed to create campaign.');
        return;
      } else {
        // Show success message for campaign creation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Campaign "$campaignName" created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    // Send leads with campaign_id (existing or new)
    final result = await sendLeadsToBackendWithCampaignId(
      campaignId,
      widget.leads,
    );
    setState(() => isLoading = false);
    if (result != null) {
      // Show success message
      final insertedCount = result['inserted_count'] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Successfully imported $insertedCount leads!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      // Show success with details
      _showSuccessDialog(result);
    } else {
      _showError('Failed to import leads. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildWizardHeader(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [buildWizardTitle()],
              ),
              SizedBox(height: 24),
              buildCustomStepper(3),
              SizedBox(height: 32),
              // Campaign Action Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => CreateCampaignDialog(
                              onCampaignCreated: (String newCampaignName) {
                                setState(() {
                                  campaignName = newCampaignName;
                                  _campaignController.text = newCampaignName;
                                });
                              },
                            ),
                      );
                    },
                    icon: Icon(Icons.add_circle_outline, size: 18),
                    label: Text('Create New Campaign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Choose Campaign Action
              Row(
                children: [
                  Icon(Icons.mail_outline, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Choose Campaign Action',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, top: 2.0),
                child: Text(
                  'Manage all your leads collectively and easily',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ),
              SizedBox(height: 20),
              // Lead Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4A90E2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: const Color(0xFF4A90E2),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leads Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: const Color(0xFF4A90E2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.leads.length} leads will be added to this campaign',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          if (widget.filterUserMatches > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${widget.filterUserMatches} leads excluded (matched with filter users)',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Campaign Name TypeAhead
              Text(
                'Campaign Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _campaignController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.alternate_email, size: 20),
                    hintText: 'Campaign name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.lightBlueAccent),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                  onChanged: (val) => setState(() => campaignName = val),
                ),
                suggestionsCallback: (pattern) async {
                  return await fetchCampaignSuggestions(pattern);
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (String suggestion) {
                  setState(() {
                    campaignName = suggestion;
                    _campaignController.text = suggestion;
                  });
                },
                noItemsFoundBuilder:
                    (context) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No campaigns found'),
                    ),
              ),
              SizedBox(height: 24),
              // Choose List
              Row(
                children: [
                  Icon(Icons.groups_outlined, color: Colors.black, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Choose List',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, top: 2.0),
                child: Text(
                  'You can choose list',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                child:
                    isCallersLoading
                        ? Center(child: CircularProgressIndicator())
                        : callersError != null
                        ? Center(child: Text(callersError!))
                        : CompositedTransformTarget(
                          link: _layerLink,
                          child: GestureDetector(
                            key: _dropdownKey,
                            onTap: () {
                              if (_callersDropdownOverlay != null) return;
                              final RenderBox renderBox =
                                  _dropdownKey.currentContext!
                                          .findRenderObject()
                                      as RenderBox;
                              final size = renderBox.size;
                              final offset = renderBox.localToGlobal(
                                Offset.zero,
                              );
                              _callersDropdownOverlay = OverlayEntry(
                                builder: (context) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      _callersDropdownOverlay?.remove();
                                      _callersDropdownOverlay = null;
                                    },
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: offset.dx,
                                          top: offset.dy + size.height + 4,
                                          width: size.width,
                                          child: Material(
                                            elevation: 4,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxHeight: 250,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                    child: ListView(
                                                      shrinkWrap: true,
                                                      children:
                                                          callers.map((caller) {
                                                            return CheckboxListTile(
                                                              value:
                                                                  selectedCallerIds
                                                                      .contains(
                                                                        caller
                                                                            .id,
                                                                      ),
                                                              onChanged: (
                                                                checked,
                                                              ) {
                                                                setState(() {
                                                                  if (caller
                                                                          .id ==
                                                                      null)
                                                                    return;
                                                                  if (checked ==
                                                                      true) {
                                                                    selectedCallerIds
                                                                        .add(
                                                                          caller
                                                                              .id!,
                                                                        );
                                                                  } else {
                                                                    selectedCallerIds
                                                                        .remove(
                                                                          caller
                                                                              .id!,
                                                                        );
                                                                  }
                                                                });
                                                              },
                                                              title: Text(
                                                                caller.name,
                                                              ),
                                                            );
                                                          }).toList(),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 12.0,
                                                            bottom: 4,
                                                          ),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          _callersDropdownOverlay
                                                              ?.remove();
                                                          _callersDropdownOverlay =
                                                              null;
                                                        },
                                                        child: Text('Done'),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                              Overlay.of(
                                context,
                              ).insert(_callersDropdownOverlay!);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                              ),
                              child: Text(
                                selectedCallerIds.isEmpty
                                    ? 'Select Callers...'
                                    : callers
                                        .where(
                                          (c) =>
                                              selectedCallerIds.contains(c.id),
                                        )
                                        .map((c) => c.name)
                                        .join(', '),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
              ),
              SizedBox(height: 48),
              buildWizardButtons(
                onBack: () => Navigator.pop(context),
                onNext: isLoading ? null : _onNextPressed,
                isNextEnabled: !isLoading,
                isLoading: isLoading,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isActive ? Colors.blue : Colors.grey[300],
          child: Text(
            '$step',
            style: TextStyle(color: isActive ? Colors.white : Colors.black),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

// CampaignCreatedDialog implementation
class CampaignCreatedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[100],
              radius: 32,
              child: Icon(Icons.check, color: Colors.green, size: 40),
            ),
            SizedBox(height: 24),
            Text(
              'Campaign Created',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 12),
            Text(
              'Your new campaign has been successfully created and assigned.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Edit'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Home_Campaign()),
                      (route) => false,
                    );
                  },
                  child: Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[50],
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
