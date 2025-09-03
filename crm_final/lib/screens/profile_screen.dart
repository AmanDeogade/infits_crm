import 'package:flutter/material.dart';
import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/services/auth_service.dart';
import 'package:crm_final/authentication/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alternatePhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  bool _isEditingAlternatePhone = false;
  bool _isEditingPassword = false;
  
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      print('Loading user profile...');
      
      // First try to get profile from API
      final profileData = await _authService.getProfile();
      print('Profile data received: $profileData');
      
      if (profileData['success'] == true) {
        final userData = profileData['user'];
        print('User data: $userData');
        
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _alternatePhoneController.text = userData['alternate_phone'] ?? '';
          _passwordController.text = '••••••••'; // Show dots for password
          _isLoading = false;
        });
        print('Profile loaded successfully from API');
      } else {
        print('Profile loading failed: ${profileData['message']}');
        
        // Try to load from local storage as fallback
        await _loadFromLocalStorage();
      }
    } catch (e) {
      print('Error loading profile: $e');
      
      // Try to load from local storage as fallback
      await _loadFromLocalStorage();
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      print('Loading profile from local storage...');
      final localUserData = await _authService.getUserData();
      print('Local user data: $localUserData');
      
             setState(() {
         _nameController.text = localUserData['name'] ?? 'User Name';
         _emailController.text = localUserData['email'] ?? 'user@example.com';
         _phoneController.text = localUserData['phone'] ?? '';
         _alternatePhoneController.text = localUserData['alternate_phone'] ?? '';
         _passwordController.text = '••••••••';
         _isLoading = false;
       });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Using locally stored profile data. API connection failed.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      print('Profile loaded from local storage');
    } catch (e) {
      print('Error loading from local storage: $e');
      setState(() {
        _nameController.text = 'User Name';
        _emailController.text = 'user@example.com';
        _phoneController.text = '';
        _alternatePhoneController.text = '';
        _passwordController.text = '••••••••';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load profile. Showing default data.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveProfileChanges() async {
    try {
      // First get current user data to include all required fields
      final currentProfileData = await _authService.getProfile();
      if (currentProfileData['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current profile data')),
        );
        return;
      }
      
      final currentUserData = currentProfileData['user'];
      
                    // Update profile through API including all required fields
       print('Current user data: $currentUserData');
       print('Sending profile update with:');
       print('  name: ${_nameController.text}');
       print('  email: ${_emailController.text}');
       print('  initials: ${currentUserData['initials']}');
       print('  role: ${currentUserData['role']}');
       print('  country_code: ${currentUserData['country_code']}');
       
        final result = await _authService.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
          phone: null,
          alternatePhone: null,
          initials: (currentUserData['initials'] != null && currentUserData['initials'].toString().isNotEmpty) ? currentUserData['initials'].toString() : null,
          role: (currentUserData['role'] != null && currentUserData['role'].toString().isNotEmpty) ? currentUserData['role'].toString() : null,
          countryCode: (currentUserData['country_code'] != null && currentUserData['country_code'].toString().isNotEmpty) ? currentUserData['country_code'].toString() : null,
        );
      
      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully and saved to database'),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Exit edit mode for all fields
        setState(() {
          _isEditingName = false;
          _isEditingEmail = false;
          _isEditingPhone = false;
          _isEditingAlternatePhone = false;
          _isEditingPassword = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  void _showPasswordChangeDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
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
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                  return;
                }
                
                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                
                try {
                  final result = await _authService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Password changed successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Failed to change password')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to change password')),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: const Color(0xFFCCF0FF), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '••••••••',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _showPasswordChangeDialog,
              icon: Icon(
                Icons.edit,
                color: Colors.blue[600],
                size: 20,
              ),
            ),
          ],
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
                // Header with title only (no back button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Profile Setting',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                                                                    if (_isEditingName || _isEditingEmail)
                         TextButton(
                           onPressed: _saveProfileChanges,
                           child: const Text(
                             'Save Changes',
                             style: TextStyle(
                               color: Colors.blue,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ),
                      if (!_isLoading && (_nameController.text == 'User Name' || _emailController.text == 'user@example.com'))
                        TextButton(
                          onPressed: _loadUserProfile,
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Main content with light blue border
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCCF0FF), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: _isLoading
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading profile...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column - Main Form
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFormField(
                                        label: 'Name',
                                        controller: _nameController,
                                        isEditing: _isEditingName,
                                        onEditToggle: () => setState(() => _isEditingName = !_isEditingName),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildFormField(
                                        label: 'Email',
                                        controller: _emailController,
                                        isEditing: _isEditingEmail,
                                        onEditToggle: () => setState(() => _isEditingEmail = !_isEditingEmail),
                                      ),
                                      const SizedBox(height: 24),
                                                                                                                                                           _buildPhoneField(
                                           label: 'Phone',
                                           controller: _phoneController,
                                           isEditing: false,
                                           onEditToggle: () {},
                                         ),
                                      const SizedBox(height: 24),
                                      _buildPasswordField(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 48),
                                // Right Column - Profile Picture and Alternate Phone
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Profile Picture
                                      Center(
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[300],
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                  color: Colors.blue[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                                                                                                                                                   _buildPhoneField(
                                           label: 'Alternate Phone',
                                           controller: _alternatePhoneController,
                                           isEditing: false,
                                           onEditToggle: () {},
                                         ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                // Logout button at bottom
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                                                         onTap: () async {
                               // Handle logout
                               try {
                                 // Clear user data from local storage
                                 await _authService.logout();
                                 
                                 // Navigate to login screen and clear all routes
                                 if (mounted) {
                                   Navigator.of(context).pushAndRemoveUntil(
                                     MaterialPageRoute(builder: (context) => const LoginScreen()),
                                     (route) => false,
                                   );
                                 }
                               } catch (e) {
                                 // If logout fails, still try to navigate
                                 if (mounted) {
                                   Navigator.of(context).pushAndRemoveUntil(
                                     MaterialPageRoute(builder: (context) => const LoginScreen()),
                                     (route) => false,
                                   );
                                 }
                               }
                             },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Log out',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditToggle,
    bool isPassword = false,
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: isPassword && !isEditing,
                enabled: isEditing,
                decoration: InputDecoration(
                  hintText: isPassword ? '••••••••' : 'Enter ${label.toLowerCase()}',
                  filled: true,
                  fillColor: isEditing ? Colors.white : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFFCCF0FF), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFFCCF0FF), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFFCCF0FF), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onEditToggle,
              icon: Icon(
                isEditing ? Icons.check : Icons.edit,
                color: isEditing ? Colors.green : Colors.blue[600],
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

    Widget _buildPhoneField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditToggle,
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
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCCF0FF), width: 1),
              ),
              child: const Center(
                child: Text(
                  'IN +91',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: const Color(0xFFCCF0FF), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    controller.text.isNotEmpty ? controller.text : 'Enter phone number',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.info_outline,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ],
    );
  }
}
