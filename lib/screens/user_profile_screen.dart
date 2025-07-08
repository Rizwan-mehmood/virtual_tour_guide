import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uaetourguide/screens/login_screen.dart';

import '../models/user_profile.dart';
import '../providers/firebase_provider.dart';
import '../theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  Map<String, bool> _exhibitTypePreferences = {};
  List<String> _allExhibitTypes = [
    'Painting',
    'Sculpture',
    'Jewelry',
    'Ceramics',
    'Textile',
    'Islamic Art',
    'European Art',
    'Asian Art',
    'Contemporary Art',
    'Ancient Artifacts',
    'Manuscripts',
    'Decorative Arts',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final firebaseProvider = Provider.of<FirebaseProvider>(
      context,
      listen: false,
    );
    final userProfile = firebaseProvider.userProfile;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
      _emailController.text = userProfile.email;

      // Initialize preferences map
      _exhibitTypePreferences = {};
      for (var type in _allExhibitTypes) {
        _exhibitTypePreferences[type] = userProfile.favoriteExhibitTypes
            .contains(type);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseProvider = Provider.of<FirebaseProvider>(
        context,
        listen: false,
      );
      final currentProfile = firebaseProvider.userProfile;
      if (currentProfile == null) {
        throw Exception('User profile not found');
      }

      // Get selected exhibit types
      final List<String> selectedExhibitTypes =
          _exhibitTypePreferences.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

      // Update profile
      final updatedProfile = currentProfile.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        favoriteExhibitTypes: selectedExhibitTypes,
      );

      await firebaseProvider.updateUserProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Consumer<FirebaseProvider>(
        builder: (context, firebaseProvider, _) {
          final userProfile = firebaseProvider.userProfile;
          print("USER PROFILE");
          print(userProfile?.name);
          print(userProfile?.completedTours);
          if (userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header with avatar
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.2,
                          ),
                          child: Text(
                            userProfile.name.isNotEmpty
                                ? userProfile.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic information section
                  const Text(
                    'Basic Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Preferences section
                  const Text(
                    'Art Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Select the types of art you\'re interested in:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _allExhibitTypes.map((type) {
                          return FilterChip(
                            label: Text(type),
                            selected: _exhibitTypePreferences[type] ?? false,
                            onSelected: (selected) {
                              setState(() {
                                _exhibitTypePreferences[type] = selected;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: AppTheme.primaryColor.withOpacity(
                              0.2,
                            ),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color:
                                  (_exhibitTypePreferences[type] ?? false)
                                      ? AppTheme.primaryColor
                                      : Colors.black,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Stats section
                  const Text(
                    'Activity Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatRow(
                            'Completed Tours',
                            userProfile.completedTours.length.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            'Exhibit Reviews',
                            userProfile.commentCount.toString(),
                            Icons.star,
                            Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Save Profile',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing between buttons
                  // In the build method's button section:
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await context.read<FirebaseProvider>().logout();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
