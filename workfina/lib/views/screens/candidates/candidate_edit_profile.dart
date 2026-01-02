import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _experienceController;
  late TextEditingController _currentCtcController;
  late TextEditingController _expectedCtcController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _educationController;
  late TextEditingController _skillsController;

  late String _selectedRole;
  late String _selectedReligion;
  File? _resumeFile;
  String? _resumeFileName;
  File? _videoIntroFile;  // âœ… Added
  String? _videoIntroFileName;  // âœ… Added
  File? _profileImage;  // âœ… Added for profile image
  final ImagePicker _imagePicker = ImagePicker();  // âœ… Added

  final List<Map<String, String>> _roles = [
    {'value': 'IT', 'label': 'Information Technology'},
    {'value': 'HR', 'label': 'Human Resources'},
    {'value': 'SUPPORT', 'label': 'Customer Support'},
    {'value': 'SALES', 'label': 'Sales'},
    {'value': 'MARKETING', 'label': 'Marketing'},
    {'value': 'FINANCE', 'label': 'Finance'},
    {'value': 'DESIGN', 'label': 'Design'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  final List<Map<String, String>> _religions = [
    {'value': 'HINDU', 'label': 'Hindu'},
    {'value': 'MUSLIM', 'label': 'Muslim'},
    {'value': 'CHRISTIAN', 'label': 'Christian'},
    {'value': 'SIKH', 'label': 'Sikh'},
    {'value': 'BUDDHIST', 'label': 'Buddhist'},
    {'value': 'JAIN', 'label': 'Jain'},
    {'value': 'OTHER', 'label': 'Other'},
    {'value': 'PREFER_NOT_TO_SAY', 'label': 'Prefer not to say'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _fullNameController = TextEditingController(
      text: widget.profileData['full_name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profileData['phone'] ?? '',
    );
    _ageController = TextEditingController(
      text: widget.profileData['age']?.toString() ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.profileData['experience_years']?.toString() ?? '',
    );
    _currentCtcController = TextEditingController(
      text: widget.profileData['current_ctc']?.toString() ?? '',
    );
    _expectedCtcController = TextEditingController(
      text: widget.profileData['expected_ctc']?.toString() ?? '',
    );
    _stateController = TextEditingController(
      text: widget.profileData['state_name'] ?? '',
    );
    _cityController = TextEditingController(
      text: widget.profileData['city_name'] ?? '',
    );
    _educationController = TextEditingController(
      text: widget.profileData['education_name'] ?? '',
    );
    
    // Convert skills list to comma-separated string
    final skillsList = widget.profileData['skills_list'] as List<dynamic>?;
    _skillsController = TextEditingController(
      text: skillsList?.join(', ') ?? widget.profileData['skills'] ?? '',
    );

    _selectedRole = widget.profileData['role_name'] ?? 'IT';
    _selectedReligion = widget.profileData['religion_name'] ?? 'PREFER_NOT_TO_SAY';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _currentCtcController.dispose();
    _expectedCtcController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size should not exceed 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _resumeFile = file;
          _resumeFileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking file. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Ã¢Å“â€¦ Added video picker method
  void _pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 50) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video size should not exceed 50MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _videoIntroFile = file;
          _videoIntroFileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking video. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // âœ… Image Picker Methods
  Future<void> _pickImageFromCamera() async {
    try {
      final status = await Permission.camera.request();
      
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDialog(
            'Camera Permission',
            'Camera access is required to take photos. Please enable it in app settings.',
          );
        }
        return;
      }

      if (!status.isGranted) {
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size should not exceed 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _profileImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      PermissionStatus status;
      
      // Check Android version for appropriate permission
      if (await Permission.photos.isPermanentlyDenied || 
          await Permission.storage.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDialog(
            'Gallery Permission',
            'Gallery access is required to select photos. Please enable it in app settings.',
          );
        }
        return;
      }
      
      // Request photos permission (Android 13+) or storage (Android 12 and below)
      status = await Permission.photos.request();
      
      // Fallback to storage permission for older Android versions
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gallery permission is required to select photos'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDialog(
            'Gallery Permission',
            'Gallery access is required to select photos. Please enable it in app settings.',
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size should not exceed 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _profileImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (_profileImage != null || widget.profileData['profile_image_url'] != null)
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<CandidateController>();

    final success = await controller.updateProfile(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      age: int.tryParse(_ageController.text),
      role: _selectedRole,
      experienceYears: int.tryParse(_experienceController.text),
      currentCtc: _currentCtcController.text.isEmpty 
          ? null 
          : double.tryParse(_currentCtcController.text),
      expectedCtc: _expectedCtcController.text.isEmpty 
          ? null 
          : double.tryParse(_expectedCtcController.text),
      religion: _selectedReligion,
      state: _stateController.text,
      city: _cityController.text,
      education: _educationController.text,
      skills: _skillsController.text,
      resumeFile: _resumeFile,
      videoIntroFile: _videoIntroFile,  // âœ… Added
      profileImage: _profileImage,  // âœ… Added for profile image
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      // Go back to profile screen
      Navigator.pop(context, true); // Pass true to indicate update success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CandidateController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // âœ… Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _showImageSourceBottomSheet,
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                  border: Border.all(
                                    color: AppTheme.primaryGreen,
                                    width: 3,
                                  ),
                                ),
                                child: _profileImage != null
                                    ? ClipOval(
                                        child: Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : widget.profileData['profile_image_url'] != null
                                        ? ClipOval(
                                            child: Image.network(
                                              widget.profileData['profile_image_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey[400],
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey[400],
                                          ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _profileImage != null
                              ? 'New photo selected'
                              : 'Tap to change photo',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    isRequired: true,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Phone is required';
                      if (value!.length != 10) return 'Enter valid 10-digit number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _ageController,
                          label: 'Age',
                          icon: Icons.cake,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty == true ? 'Age is required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _experienceController,
                          label: 'Experience (Years)',
                          icon: Icons.work_history,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty == true
                              ? 'Experience is required'
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  // Professional Information Section
                  _buildSectionTitle('Professional Information'),
                  const SizedBox(height: 16),
                  
                  _buildDropdownField(
                    value: _selectedRole,
                    label: 'Role/Department',
                    icon: Icons.business_center,
                    items: _roles,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _educationController,
                    label: 'Education',
                    icon: Icons.school,
                    isRequired: true,
                    maxLines: 2,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Education is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _skillsController,
                    label: 'Skills',
                    icon: Icons.psychology,
                    isRequired: true,
                    maxLines: 3,
                    hintText: 'e.g., Python, Django, React (comma separated)',
                    validator: (value) =>
                        value?.isEmpty == true ? 'Skills are required' : null,
                  ),

                  const SizedBox(height: 24),
                  
                  // Compensation & Location Section
                  _buildSectionTitle('Compensation & Location'),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _currentCtcController,
                          label: 'Current CTC (Ã¢â€šÂ¹)',
                          icon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _expectedCtcController,
                          label: 'Expected CTC (Ã¢â€šÂ¹)',
                          icon: Icons.trending_up,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.location_on,
                          isRequired: true,
                          validator: (value) =>
                              value?.isEmpty == true ? 'State is required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city,
                          isRequired: true,
                          validator: (value) =>
                              value?.isEmpty == true ? 'City is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDropdownField(
                    value: _selectedReligion,
                    label: 'Religion (Optional)',
                    icon: Icons.account_circle,
                    items: _religions,
                    onChanged: (value) =>
                        setState(() => _selectedReligion = value!),
                  ),

                  const SizedBox(height: 24),
                  
                  // Documents Section - Ã¢Å“â€¦ Updated with both Resume and Video
                  _buildSectionTitle('Documents (Optional)'),
                  const SizedBox(height: 16),
                  
                  // Resume Upload
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _resumeFile != null
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          size: 48,
                          color: _resumeFile != null
                              ? AppTheme.primaryGreen
                              : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _resumeFile != null
                              ? 'New Resume Selected'
                              : widget.profileData['resume_url'] != null
                                  ? 'Update Resume'
                                  : 'Upload Resume',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _resumeFileName ?? 
                          (widget.profileData['resume_url'] != null 
                              ? 'Current resume uploaded' 
                              : 'PDF format only (Max 5MB)'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickResumeFile,
                          icon: Icon(
                            _resumeFile != null ? Icons.refresh : Icons.upload_file,
                          ),
                          label: Text(
                            _resumeFile != null ? 'Change File' : 'Choose File',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ã¢Å“â€¦ Video Intro Upload Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _videoIntroFile != null
                              ? Icons.check_circle
                              : Icons.videocam_outlined,
                          size: 48,
                          color: _videoIntroFile != null
                              ? AppTheme.primaryGreen
                              : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _videoIntroFile != null
                              ? 'New Video Selected'
                              : widget.profileData['video_intro_url'] != null
                                  ? 'Update Video Introduction'
                                  : 'Upload Video Introduction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _videoIntroFileName ?? 
                          (widget.profileData['video_intro_url'] != null 
                              ? 'Current video uploaded' 
                              : 'MP4, MOV, or AVI (Max 50MB)'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickVideoFile,
                          icon: Icon(
                            _videoIntroFile != null ? Icons.refresh : Icons.upload_file,
                          ),
                          label: Text(
                            _videoIntroFile != null ? 'Change Video' : 'Choose Video',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        counterText: '',
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item['value'],
              child: Text(item['label']!),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}