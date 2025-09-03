# Settings Navigation Feature

## Overview
This feature enables navigation to the Profile Settings screen from the Settings icon in the side navigation bar.

## Implementation Details

### 1. Side Navigation Update
- **File**: `crm_final/lib/home_campaign/bars/side_bar.dart`
- **Changes**:
  - Added import for `ProfileScreen`
  - Updated Settings navigation item to include `onTap` functionality
  - Settings icon now navigates to Profile Settings screen

### 2. Profile Settings Screen
- **File**: `crm_final/lib/screens/profile_screen.dart`
- **Features**:
  - User profile information display and editing
  - Name, email, phone, and password management
  - Profile picture placeholder
  - Form validation and error handling
  - API integration for profile updates
  - Local storage fallback

### 3. Navigation Flow
1. User clicks Settings icon in side navigation
2. Navigation pushes to Profile Settings screen
3. User can view and edit their profile information
4. Changes are saved to backend API
5. User can navigate back using back button

### 4. User Interface
- **Side Navigation**: Settings icon with gear icon
- **Profile Screen**: 
  - Header with "Profile Setting" title
  - Two-column layout with form fields
  - Profile picture section
  - Save/Retry buttons in header
  - Loading states and error handling

### 5. API Integration
- **Profile Loading**: Fetches user profile from backend
- **Profile Updates**: Sends changes to backend API
- **Error Handling**: Falls back to local storage if API fails
- **Authentication**: Uses existing AuthService

## Files Modified

### Modified Files
- `crm_final/lib/home_campaign/bars/side_bar.dart`

### Existing Files (No Changes)
- `crm_final/lib/screens/profile_screen.dart`
- `crm_final/lib/services/auth_service.dart`

## Testing

### Manual Testing Steps
1. Start the Flutter app
2. Navigate to any screen with side navigation
3. Click the Settings icon in the side navigation
4. Verify navigation to Profile Settings screen
5. Test profile editing functionality
6. Test save and cancel operations

### Expected Behavior
- Settings icon should navigate to Profile Settings screen
- Profile screen should display user information
- Edit functionality should work for name and email
- Save changes should update backend
- Back navigation should return to previous screen

## Future Enhancements

1. **Settings Menu**: Expand Settings to include multiple options
2. **Profile Picture**: Add actual profile picture upload functionality
3. **Additional Fields**: Add more profile fields (address, preferences, etc.)
4. **Theme Settings**: Add theme customization options
5. **Notification Settings**: Add notification preferences
6. **Security Settings**: Add two-factor authentication, password policies

## Code Example

```dart
// Settings navigation in side bar
_NavItem(
  'Settings',
  Icons.settings_outlined,
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const ProfileScreen(),
    ),
  ),
),
```

This implementation provides a clean and intuitive way for users to access their profile settings through the side navigation.
