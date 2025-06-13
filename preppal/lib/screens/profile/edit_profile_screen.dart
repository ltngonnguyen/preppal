import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preppal/models/user_profile.dart';
import 'package:preppal/providers/profile_providers.dart';
import 'package:preppal/services/profile_service.dart'; 

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _locationController;
  String? _profilePicUrl;
  File? _imageFile;
  bool _isSaving = false; // Renamed from _isLoading for clarity
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(userProfileProvider).asData?.value;
    _displayNameController = TextEditingController(text: userProfile?.displayName ?? '');
    _locationController = TextEditingController(text: userProfile?.location ?? '');
    _profilePicUrl = userProfile?.profilePicUrl;

    _displayNameController.addListener(_onChanged);
    _locationController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_onChanged);
    _locationController.removeListener(_onChanged);
    _displayNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print('[EditProfileScreen] Image picked: ${pickedFile.path}');
      setState(() {
        _imageFile = File(pickedFile.path);
        _profilePicUrl = null; // Clear existing URL if new image is picked
        _hasChanges = true;
      });
      print('[EditProfileScreen] _imageFile after pick: ${_imageFile?.path}');
    } else {
      print('[EditProfileScreen] Image picking cancelled or failed.');
    }
  }

  Future<void> _saveProfile() async {
    print('[EditProfileScreen] _saveProfile called. _hasChanges: $_hasChanges, _formKey valid: ${_formKey.currentState?.validate()}');
    if (!_formKey.currentState!.validate() || !_hasChanges) {
      // If no changes or form is invalid, don't proceed.
      // Optionally, show a message if trying to save without changes.
      if (!_hasChanges && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to save.')),
        );
      }
      print('[EditProfileScreen] No changes or form invalid. Returning.');
      return;
    }

    setState(() {
      _isSaving = true;
    });
    print('[EditProfileScreen] _isSaving set to true.');

    final currentUserProfile = ref.read(userProfileProvider).asData?.value;
    if (currentUserProfile == null) {
      print('[EditProfileScreen] currentUserProfile is null. Cannot update.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not load current profile to update.')),
        );
      }
      setState(() {
        _isSaving = false;
      });
      return;
    }
    print('[EditProfileScreen] Current user profile loaded: ${currentUserProfile.id}');

    final profileService = ref.read(profileServiceProvider);
    
    // Construct the profile with updated text fields
    UserProfile profileToSave = UserProfile(
      id: currentUserProfile.id,
      email: currentUserProfile.email, // Assuming email is not editable here
      displayName: _displayNameController.text,
      location: _locationController.text,
      // profilePicUrl will be handled by the service if _imageFile is present
      // If _imageFile is null, use the existing _profilePicUrl
      profilePicUrl: _imageFile == null ? _profilePicUrl : currentUserProfile.profilePicUrl,
      createdAt: currentUserProfile.createdAt,
      updatedAt: Timestamp.now(), // Service might overwrite this
    );
    print('[EditProfileScreen] Profile to save: ${profileToSave.toJson()}');
    print('[EditProfileScreen] _imageFile to save: ${_imageFile?.path}');

    try {
      print('[EditProfileScreen] Calling profileService.updateUserProfile...');
      // The ProfileService's updateUserProfile method should handle the image upload
      // if an imageFile is provided.
      await profileService.updateUserProfile(profileToSave, imageFile: _imageFile);
      print('[EditProfileScreen] profileService.updateUserProfile completed.');
      
      ref.refresh(userProfileProvider); // Refresh profile data globally
      print('[EditProfileScreen] userProfileProvider refreshed.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); // Go back after successful save
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsyncValue = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving || !_hasChanges ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: userProfileAsyncValue.when(
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('User profile not found.'));
          }
          // Initialize controllers here if not done in initState or if data can change
          // _displayNameController.text = userProfile.displayName ?? '';
          // _locationController.text = userProfile.location ?? '';
          // _profilePicUrl = userProfile.profilePicUrl; // This might conflict if _imageFile is set

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profilePicUrl != null && _profilePicUrl!.isNotEmpty
                              ? NetworkImage(_profilePicUrl!)
                              : null) as ImageProvider?,
                      child: _imageFile == null && (_profilePicUrl == null || _profilePicUrl!.isEmpty)
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _pickImage,
                      child: const Text('Change Profile Picture'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(labelText: 'Display Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a display name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 30),
                  // Save and Cancel buttons were previously here, AppBar button is now 'Done'
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }
}