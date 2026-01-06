import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CandidateSetupScreen extends StatefulWidget {
  const CandidateSetupScreen({super.key});

  @override
  State<CandidateSetupScreen> createState() =>
      _CandidateSetupScreenSwipeableState();
}

class _CandidateSetupScreenSwipeableState extends State<CandidateSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _currentCtcController = TextEditingController();
  final TextEditingController _expectedCtcController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _otherRoleController = TextEditingController();

  List<String> _selectedLanguages = [];
  String? _currentLanguageValue;

  final List<String> _availableLanguages = [
    'Hindi',
    'English',
    'Punjabi',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Gujarati',
    'Urdu',
    'Kannada',
    'Malayalam',
    'Odia',
  ];

  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _careerObjectiveController =
      TextEditingController();

  // Work Experience List
  List<Map<String, dynamic>> _workExperiences = [];
  List<Map<String, dynamic>> _educationList = [];

  bool _willingToRelocate = false;

  String _selectedRole = 'IT';
  bool _isOtherRole = false; // YEH ADD KARO

  String _selectedReligion = 'PREFER_NOT_TO_SAY';
  File? _resumeFile;
  String? _resumeFileName;
  File? _videoIntroFile;
  String? _videoIntroFileName;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

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

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        // Personal Information with Compensation & Location
        return _fullNameController.text.isNotEmpty &&
            _phoneController.text.length == 10 &&
            _ageController.text.isNotEmpty &&
            _stateController.text.isNotEmpty &&
            _cityController.text.isNotEmpty &&
            (!_isOtherRole || _otherRoleController.text.isNotEmpty);

      case 1:
        // Work Experience (optional but at least structure should be valid)
        return true;

      case 2:
        // Education - At least one education entry required
        return _educationList.isNotEmpty && _skillsController.text.isNotEmpty;

      case 3:
        // Documents (optional)
        return true;

      default:
        return false;
    }
  }

  void _handleContinue() {
    if (_validateCurrentPage()) {
      _nextPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  // ÃƒÂ¢Ã…â€œÃ¢â‚¬Â¦ Image Picker Methods
  Future<void> _pickImageFromCamera() async {
    try {
      // Request camera permission
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
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

  Future<void> _submitProfile() async {
  // VALIDATE ALL REQUIRED FIELDS FIRST
  if (_fullNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your full name'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid 10-digit phone number'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_ageController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your age'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_educationList.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please add at least one education qualification'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_skillsController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your skills'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_stateController.text.isEmpty || _cityController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your state and city'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final controller = context.read<CandidateController>();

  String workExperienceJson = '';
  if (_workExperiences.isNotEmpty) {
    workExperienceJson = _workExperiences
        .map(
          (exp) => {
            'company_name': exp['company_name'],
            'job_role': exp['job_role'],
            'start_month': exp['start_month'],
            'start_year': exp['start_year'],
            'end_month': exp['end_month'],
            'end_year': exp['end_year'],
            'is_current': exp['is_current'],
          },
        )
        .toList()
        .toString();
  }

  String educationJson = '';
  if (_educationList.isNotEmpty) {
    educationJson = _educationList
        .map(
          (edu) => {
            'school': edu['school'],
            'degree': edu['degree'],
            'field': edu['field'],
            'start_month': edu['start_month'],
            'start_year': edu['start_year'],
            'end_month': edu['end_month'],
            'end_year': edu['end_year'],
            'grade': edu['grade'],
          },
        )
        .toList()
        .toString();
  }

  // Calculate experience years
  int experienceYears = 0;
  if (_workExperiences.isNotEmpty) {
    for (var exp in _workExperiences) {
      int startYear = int.parse(exp['start_year']);
      int endYear = exp['is_current'] 
          ? DateTime.now().year 
          : int.parse(exp['end_year']);
      experienceYears += (endYear - startYear);
    }
  }

  final success = await controller.registerCandidate(
    fullName: _fullNameController.text,
    phone: _phoneController.text,
    age: int.parse(_ageController.text),
    role: _selectedRole == 'OTHER'
        ? _otherRoleController.text
        : _selectedRole,
    experienceYears: experienceYears,
    currentCtc: _currentCtcController.text.isEmpty
        ? null
        : double.parse(_currentCtcController.text),
    expectedCtc: _expectedCtcController.text.isEmpty
        ? null
        : double.parse(_expectedCtcController.text),
    religion: _selectedReligion,
    state: _stateController.text,
    city: _cityController.text,
    skills: _skillsController.text,
    resumeFile: _resumeFile,
    videoIntroFile: _videoIntroFile,
    profileImage: _profileImage,
    languages: _selectedLanguages.join(', '),
    education: educationJson,
    streetAddress: _streetAddressController.text,
    willingToRelocate: _willingToRelocate,
    workExperience: workExperienceJson,
    careerObjective: _careerObjectiveController.text,
  );

  if (success) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/candidate-home',
      (route) => false,
    );
  } else if (controller.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(controller.error!), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPersonalInfoPage(), // Page 1: Personal + Compensation + Location
                _buildWorkExperiencePage(), // Page 2: Work Experience
                _buildProfessionalInfoPage(), // Page 3: Education + Skills
                _buildDocumentsPage(), // Page 4: Documents
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentPage + 1} of 4', // Change from 4 to 5
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((_currentPage + 1) / 4 * 100).toInt()}% Complete', // Change from 4 to 5
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (index) {
              // Change from 4 to 5
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < 3 ? 8 : 0,
                  ), // Change from 3 to 4
                  height: 6,
                  decoration: BoxDecoration(
                    color: index <= _currentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Consumer<CandidateController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentPage == 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : _currentPage < 3
                        ? _handleContinue
                        : _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                        : Text(
                            _currentPage < 3
                                ? 'Continue'
                                : 'Submit Profile', // Change from 3 to 4
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // PAGE 1: Personal Information
  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Tell us about yourself',
          ),
          const SizedBox(height: 32),

          // ÃƒÂ¢Ã…â€œÃ¢â‚¬Â¦ Profile Picture Section
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
                          border: Border.all(color: AppTheme.primary, width: 3),
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
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
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                      ? 'Tap to change photo'
                      : 'Tap to add photo (Optional)',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person,
            isRequired: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            isRequired: true,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.cake,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: _buildTextField(
              //     controller: _experienceController,
              //     label: 'Experience (Years)',
              //     icon: Icons.work_history,
              //     isRequired: true,
              //     keyboardType: TextInputType.number,
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 20),

          // // Languages
          // _buildTextField(
          //   controller: _languagesController,
          //   label: 'Languages',
          //   icon: Icons.language,
          //   hintText: 'e.g., Hindi, English, Punjabi (comma separated)',
          //   maxLines: 2,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedLanguages.length),
                value: _currentLanguageValue,

                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Select Language',
                  labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: const Icon(
                    Icons.language,
                    color: Color(0xFF6B7280),
                  ),
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
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                hint: const Text('Choose a language'),
                items: _availableLanguages
                    .where((lang) => !_selectedLanguages.contains(lang))
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguages.add(value);
                      _currentLanguageValue = null;
                    });
                  }
                },
              ),
              if (_selectedLanguages.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedLanguages
                      .map(
                        (lang) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lang,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _selectedLanguages.remove(lang),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // Street Address
          _buildTextField(
            controller: _streetAddressController,
            label: 'Street Address',
            icon: Icons.home,
            hintText: 'House no., Street, Area',
            minLines: 1, // YEH ADD KARO
            maxLines: null,
          ),

          const SizedBox(height: 20),

          // Willing to Relocate
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: const Color(0xFF6B7280)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Are you willing to relocate?',
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  value: _willingToRelocate,
                  onChanged: (value) {
                    setState(() {
                      _willingToRelocate = value;
                    });
                  },
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Career Objective
          _buildTextField(
            controller: _careerObjectiveController,
            label: 'Career Objective',
            icon: Icons.flag,
            hintText:
                'Describe your career goals and what you are looking for...',
            maxLines: null,
            minLines: 1,
          ),

          const SizedBox(height: 20),
          _buildDropdownField(
            value: _selectedRole,
            label: 'Role/Department',
            icon: Icons.business_center,
            items: _roles,
            onChanged: (value) => setState(() {
              _selectedRole = value!;
              _isOtherRole = value == 'OTHER';
            }),
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 20),

          if (_isOtherRole)
            Column(
              children: [
                _buildTextField(
                  controller: _otherRoleController,
                  label: 'Specify Role',
                  icon: Icons.edit,
                  isRequired: true,
                  hintText: 'Enter your role',
                ),
                const SizedBox(height: 20),
              ],
            ),

          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Compensation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _currentCtcController,
                  label: 'Current CTC',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  hintText: 'Annual package',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _expectedCtcController,
                  label: 'Expected CTC',
                  icon: Icons.trending_up,
                  keyboardType: TextInputType.number,
                  hintText: 'Expected package',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Location Section Header
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
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
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                  isRequired: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildDropdownField(
            value: _selectedReligion,
            label: 'Religion (Optional)',
            icon: Icons.account_circle,
            items: _religions,
            onChanged: (value) => setState(() => _selectedReligion = value!),
          ),

          // // Work Experience Section Header
          // Row(
          //   children: [
          //     const Icon(Icons.work_outline, color: AppTheme.primary, size: 20),
          //     const SizedBox(width: 8),
          //     const Text(
          //       'Work Experience',
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //         color: Color(0xFF1A1A1A),
          //       ),
          //     ),
          //     const Spacer(),
          //     IconButton(
          //       icon: const Icon(
          //         Icons.add_circle,
          //         color: AppTheme.primary,
          //         size: 28,
          //       ),
          //       onPressed: _showAddExperienceDialog,
          //       tooltip: 'Add Experience',
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 4),
          // Text(
          //   'Add your previous work experience (if any)',
          //   style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          // ),
          const SizedBox(height: 16),

          // Display Work Experiences
          // if (_workExperiences.isEmpty)
          //   Container(
          //     padding: const EdgeInsets.all(24),
          //     decoration: BoxDecoration(
          //       color: Colors.grey[50],
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: Colors.grey[300]!),
          //     ),
          //     child: Column(
          //       children: [
          //         Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
          //         const SizedBox(height: 12),
          //         Text(
          //           'No work experience added yet',
          //           style: TextStyle(
          //             fontSize: 14,
          //             color: Colors.grey[600],
          //           ),
          //         ),
          //         const SizedBox(height: 8),
          //         TextButton.icon(
          //           onPressed: _showAddExperienceDialog,
          //           icon: const Icon(Icons.add),
          //           label: const Text('Add Experience'),
          //         ),
          //       ],
          //     ),
          //   )
          // else
          ...(_workExperiences.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> exp = entry.value;
            return _buildExperienceCard(exp, index);
          }).toList()),
        ],
      ),
    );
  }

  // PAGE 2: Work Experience
Widget _buildWorkExperiencePage() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(
          icon: Icons.work_outline,
          title: 'Work Experience',
          subtitle: 'Add your previous work experience',
        ),
        const SizedBox(height: 32),

        // Work Experience Section
        Row(
          children: [
            const Icon(Icons.work_outline, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Experience Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: AppTheme.primary,
                size: 28,
              ),
              onPressed: _showAddExperienceDialog,
              tooltip: 'Add Experience',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Add your work experience (Optional - but recommended)',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Display Work Experiences
        if (_workExperiences.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'No work experience added yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _showAddExperienceDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Experience'),
                ),
              ],
            ),
          )
        else
          ...(_workExperiences.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> exp = entry.value;
            return _buildExperienceCard(exp, index);
          }).toList()),
      ],
    ),
  );
}

  // PAGE 2: Professional Information
  Widget _buildProfessionalInfoPage() {
    return Consumer<CandidateController>(
      builder: (context, controller, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Education Section Header
              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(Icons.school, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Education',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                    onPressed: _showAddEducationDialog,
                    tooltip: 'Add Education',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Add at least one educational qualification (Required)',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Display Education Cards
              ...(_educationList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> edu = entry.value;
                return _buildEducationDisplayCard(edu, index);
              }).toList()),

              const SizedBox(height: 32),

              // Skills Header
              Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _skillsController,
                label: 'Skills',
                icon: Icons.psychology,
                isRequired: true,
                minLines: 1,
                maxLines: null,
                hintText: 'e.g., Python, Django, React (comma separated)',
              ),
            ],
          ),
        );
      },
    );
  }
  // ========== Education Methods ==========

  void _showAddEducationDialog() {
    final schoolController = TextEditingController();
    final degreeController = TextEditingController();
    final fieldController = TextEditingController();
    final gradeController = TextEditingController();
    String startMonth = 'January';
    String startYear = DateTime.now().year.toString();
    String endMonth = 'January';
    String endYear = DateTime.now().year.toString();

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final years = List.generate(
      50,
      (index) => (DateTime.now().year - index).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Education'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: schoolController,
                  decoration: const InputDecoration(
                    labelText: 'School/University *',
                    hintText: 'e.g., K.R. Mangalam University',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: degreeController,
                  decoration: const InputDecoration(
                    labelText: 'Degree *',
                    hintText: 'e.g., Bachelor\'s, Master\'s',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fieldController,
                  decoration: const InputDecoration(
                    labelText: 'Field of Study',
                    hintText: 'e.g., Computer Science',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Start Date *',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: startMonth,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        items: months
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(month),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => startMonth = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: startYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        items: years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => startYear = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'End Date (or Expected) *',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: endMonth,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        items: months
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(month),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => endMonth = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: endYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        items: years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => endYear = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: gradeController,
                  decoration: const InputDecoration(
                    labelText: 'Grade/Percentage',
                    hintText: 'e.g., 8.5 CGPA or 85%',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (schoolController.text.isEmpty ||
                    degreeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  _educationList.add({
                    'school': schoolController.text,
                    'degree': degreeController.text,
                    'field': fieldController.text,
                    'start_month': startMonth,
                    'start_year': startYear,
                    'end_month': endMonth,
                    'end_year': endYear,
                    'grade': gradeController.text,
                  });
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationDisplayCard(Map<String, dynamic> education, int index) {
    String duration =
        '${education['start_month']} ${education['start_year']} - ${education['end_month']} ${education['end_year']}';
    String degreeText = education['degree'];
    if (education['field'].isNotEmpty) {
      degreeText += ' - ${education['field']}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education['school'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  degreeText,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (education['grade'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.grade, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Grade: ${education['grade']}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _educationList.removeAt(index);
              });
            },
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  // PAGE 3: Compensation & Location
  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            icon: Icons.location_on_outlined,
            title: 'Compensation & Location',
            subtitle: 'Where you work and your expectations',
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _currentCtcController,
                  label: 'Current CTC',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  hintText: 'Annual package',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _expectedCtcController,
                  label: 'Expected CTC',
                  icon: Icons.trending_up,
                  keyboardType: TextInputType.number,
                  hintText: 'Expected package',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.location_on,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            value: _selectedReligion,
            label: 'Religion (Optional)',
            icon: Icons.account_circle,
            items: _religions,
            onChanged: (value) => setState(() => _selectedReligion = value!),
          ),
        ],
      ),
    );
  }

  // PAGE 4: Documents
  Widget _buildDocumentsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            icon: Icons.upload_file_outlined,
            title: 'Documents (Optional)',
            subtitle: 'Upload your resume and video introduction',
          ),
          const SizedBox(height: 32),
          _buildFileUploadCard(
            title: 'Resume',
            description: 'PDF format only (Max 5MB)',
            icon: Icons.description_outlined,
            file: _resumeFile,
            fileName: _resumeFileName,
            onTap: _pickResumeFile,
          ),
          const SizedBox(height: 20),
          _buildFileUploadCard(
            title: 'Video Introduction',
            description: 'MP4, MOV, or AVI (Max 50MB)',
            icon: Icons.videocam_outlined,
            file: _videoIntroFile,
            fileName: _videoIntroFileName,
            onTap: _pickVideoFile,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your profile will be reviewed within 24 hours. Make sure all information is accurate before submitting.',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 13,
                      height: 1.4,
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

  Widget _buildPageHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // padding: const EdgeInsets.all(16),
          // decoration: BoxDecoration(
          //   color: AppTheme.primary.withOpacity(0.1),
          //   borderRadius: BorderRadius.circular(16),
          // ),
          // child: Icon(
          //   icon,
          //   color: AppTheme.primary,
          //   size: 32,
          // ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
      ],
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
    int? maxLines = 1,
    int? minLines,

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
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        counterText: '',
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,

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
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
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

  Widget _buildFileUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required File? file,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    final bool hasFile = file != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasFile ? AppTheme.primary : Colors.grey[300]!,
            width: hasFile ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasFile
                    ? AppTheme.primary.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasFile ? Icons.check_circle : icon,
                size: 32,
                color: hasFile ? AppTheme.primary : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? '$title Uploaded' : 'Upload $title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasFile
                          ? AppTheme.primary
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileName ?? description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.refresh : Icons.upload_file,
              color: hasFile ? AppTheme.primary : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
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
    // _languagesController.dispose();
    _streetAddressController.dispose();
    _careerObjectiveController.dispose();
    _otherRoleController.dispose();

    super.dispose();
  }

  // ========== Work Experience Methods ==========

  void _showAddExperienceDialog() {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    String startMonth = 'January';
    String startYear = DateTime.now().year.toString();
    String endMonth = 'January';
    String endYear = DateTime.now().year.toString();
    bool isCurrentlyWorking = false;

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final years = List.generate(
      50,
      (index) => (DateTime.now().year - index).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Work Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name *',
                    hintText: 'e.g., Pro HousyPoint Tech Solutions',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Role/Position *',
                    hintText: 'e.g., Mobile App Intern',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Start Date *',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: startMonth,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        items: months
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(month),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => startMonth = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: startYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        items: years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => startYear = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isCurrentlyWorking,
                  onChanged: (value) {
                    setDialogState(() => isCurrentlyWorking = value ?? false);
                  },
                  title: const Text('I am currently working in this role'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isCurrentlyWorking) ...[
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'End Date *',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: endMonth,
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(),
                          ),
                          items: months
                              .map(
                                (month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() => endMonth = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: endYear,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                          ),
                          items: years
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() => endYear = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (companyController.text.isEmpty ||
                    roleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  _workExperiences.add({
                    'company_name': companyController.text,
                    'job_role': roleController.text,
                    'start_month': startMonth,
                    'start_year': startYear,
                    'end_month': isCurrentlyWorking ? null : endMonth,
                    'end_year': isCurrentlyWorking ? null : endYear,
                    'is_current': isCurrentlyWorking,
                  });
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index) {
    String duration =
        '${experience['start_month']} ${experience['start_year']} - ';
    if (experience['is_current']) {
      duration += 'Present';
    } else {
      duration += '${experience['end_month']} ${experience['end_year']}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience['job_role'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  experience['company_name'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (experience['is_current'])
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Currently Working',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _workExperiences.removeAt(index);
              });
            },
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard({
    required CandidateController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required bool hasData,
    required VoidCallback onTap,
    required List<Widget> children,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasData
              ? AppTheme.primary
              : isExpanded
              ? AppTheme.primary.withOpacity(0.5)
              : Colors.grey[300]!,
          width: hasData ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasData
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasData ? Icons.check_circle : icon,
                      color: hasData ? AppTheme.primary : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: hasData
                                      ? AppTheme.primary
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            if (isRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Required',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}
