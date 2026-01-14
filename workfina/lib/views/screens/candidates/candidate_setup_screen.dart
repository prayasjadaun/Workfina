import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workfina/views/screens/candidates/candidate_education_screen.dart';
import 'dart:convert';

import 'package:workfina/views/screens/candidates/candidate_experience_screen.dart';

class CandidateSetupScreen extends StatefulWidget {
  const CandidateSetupScreen({super.key});

  @override
  State<CandidateSetupScreen> createState() =>
      _CandidateSetupScreenSwipeableState();
}

class _CandidateSetupScreenSwipeableState extends State<CandidateSetupScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _personalFormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  // final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

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
  final TextEditingController _otherReligionController =
      TextEditingController();
  final TextEditingController _otherStateController = TextEditingController();
  final TextEditingController _otherCityController = TextEditingController();
  final TextEditingController _otherSkillController = TextEditingController();
  final TextEditingController _otherLanguageController =
      TextEditingController();
  final TextEditingController _noticePeriodController = TextEditingController();

  List<String> _selectedLanguages = [];
  String? _currentLanguageValue;
  String _joiningAvailability = 'NOTICE_PERIOD';
  String? _noticePeriodError;

  List<Map<String, String>> _states = [];
  List<Map<String, String>> _cities = [];
  bool _loadingStates = false;
  bool _loadingCities = false;
  String? _selectedStateId;
  String? _selectedCityId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchStates();
    _fetchDepartmentsAndReligions();
    _loadSavedProfile();
  }

  // Dynamic lists fetched from backend
  List<String> _availableSkills = [];
  List<String> _selectedSkills = [];
  String? _currentSkillValue;

  List<String> _availableLanguages = [];
  // List<String> _selectedLanguages = [];
  // String? _currentLanguageValue;

  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _careerObjectiveController =
      TextEditingController();

  // Work Experience List
  List<Map<String, dynamic>> _workExperiences = [];
  List<Map<String, dynamic>> _educationList = [];

  bool _willingToRelocate = false;

  String _selectedRole = '';
  bool _isOtherRole = false;

  String _selectedReligion = '';
  bool _isOtherReligion = false;
  bool _isOtherState = false;
  bool _isOtherCity = false;
  File? _resumeFile;
  String? _resumeFileName;
  File? _videoIntroFile;
  String? _videoIntroFileName;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _fetchStates() async {
    setState(() => _loadingStates = true);
    try {
      final response = await ApiService.getStates();
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      final statesList = response['states'] as List;
      setState(() {
        _states = statesList
            .map(
              (state) => {
                'id': state['id'].toString(),
                'name': state['name'].toString(),
                'slug': state['slug'].toString(),
              },
            )
            .toList();
        _selectedStateId = null; // Add this line
        _stateController.clear(); // Add this line
        _loadingStates = false;
      });
    } catch (e) {
      setState(() => _loadingStates = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load states: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchCities(String stateSlug) async {
    setState(() {
      _loadingCities = true;
      _cities = [];
      _selectedCityId = null;
      _cityController.clear();
    });
    try {
      final response = await ApiService.getCities(stateSlug);
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }
      final citiesList = response['cities'] as List;
      setState(() {
        _cities = citiesList
            .map(
              (city) => {
                'id': city['id'].toString(),
                'name': city['name'].toString(),
                'slug': city['slug'].toString(),
              },
            )
            .toList();
        _loadingCities = false;
      });
    } catch (e) {
      setState(() => _loadingCities = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, String>> _roles = [];
  List<Map<String, String>> _religions = [];
  bool _loadingOptions = false;

  // final List<Map<String, String>> _roles = [
  //   {'value': 'IT', 'label': 'Information Technology'},
  //   {'value': 'HR', 'label': 'Human Resources'},
  //   {'value': 'SUPPORT', 'label': 'Customer Support'},
  //   {'value': 'SALES', 'label': 'Sales'},
  //   {'value': 'MARKETING', 'label': 'Marketing'},
  //   {'value': 'FINANCE', 'label': 'Finance'},
  //   {'value': 'DESIGN', 'label': 'Design'},
  //   {'value': 'OTHER', 'label': 'Other'},
  // ];

  // final List<Map<String, String>> _religions = [
  //   {'value': 'HINDU', 'label': 'Hindu'},
  //   {'value': 'MUSLIM', 'label': 'Muslim'},
  //   {'value': 'CHRISTIAN', 'label': 'Christian'},
  //   {'value': 'SIKH', 'label': 'Sikh'},
  //   {'value': 'BUDDHIST', 'label': 'Buddhist'},
  //   {'value': 'JAIN', 'label': 'Jain'},
  //   {'value': 'OTHER', 'label': 'Other'},
  //   // {'value': 'PREFER_NOT_TO_SAY', 'label': 'Prefer not to say'},
  // ];

  void _nextPage() {
    if (_currentPage < 3) {
      _autoSaveCurrentStep();

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
        return _profileImage != null &&
            _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty &&
            _phoneController.text.length == 10 &&
            _ageController.text.isNotEmpty &&
            _careerObjectiveController.text.isNotEmpty &&
            _streetAddressController.text.isNotEmpty &&
            _selectedStateId != null &&
            _selectedCityId != null &&
            (_stateController.text.isNotEmpty ||
                (_isOtherState && _otherStateController.text.isNotEmpty)) &&
            (_cityController.text.isNotEmpty ||
                (_isOtherCity && _otherCityController.text.isNotEmpty)) &&
            (!_isOtherRole || _otherRoleController.text.isNotEmpty) &&
            (!_isOtherReligion || _otherReligionController.text.isNotEmpty);

      case 1:
        return _workExperiences.isNotEmpty &&
            _joiningAvailability == 'IMMEDIATE' ||
            _noticePeriodController.text.isNotEmpty;

      case 2:
        return _educationList.isNotEmpty && _selectedSkills.isNotEmpty;

      case 3:
        return true;

      default:
        return false;
    }
  }

  void _handleContinue() {
    bool isValid = false;
    switch (_currentPage) {
      case 0:
        isValid = _personalFormKey.currentState!.validate();
        // if (isValid && _joiningAvailability == 'NOTICE_PERIOD') {
        //   final noticeError = _validateNoticePeriod();
        //   if (noticeError != null) {
        //     setState(() {
        //       _noticePeriodError = noticeError;
        //     });
        //     isValid = false;
        //   }
        // }
        break;
      // Add cases for other pages similarly
      default:
        isValid = _validateCurrentPage(); // Fallback for other pages
    }

    if (isValid) {
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

  Future<void> _fetchDepartmentsAndReligions() async {
    setState(() => _loadingOptions = true);
    try {
      final response = await ApiService.getDepartmentsAndReligions();
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      // Handle departments
      final departments = response['departments'] as List;
      final Map<String, Map<String, String>> uniqueDepts = {};
      for (var dept in departments) {
        final value = dept['value'].toString();
        uniqueDepts[value] = {
          'value': value,
          'label': dept['label'].toString(),
        };
      }
      _roles = uniqueDepts.values.toList();

      // Handle religions
      final religions = response['religions'] as List;
      final Map<String, Map<String, String>> uniqueReligions = {};
      for (var relig in religions) {
        final value = relig['value'].toString();
        uniqueReligions[value] = {
          'value': value,
          'label': relig['label'].toString(),
        };
      }
      _religions = uniqueReligions.values.toList();

      // Handle skills
      final skills = response['skills'] as List?;
      if (skills != null) {
        _availableSkills = skills
            .map((skill) => skill['label'].toString())
            .toList();
      }

      // Handle languages
      final languages = response['languages'] as List?;
      if (languages != null) {
        _availableLanguages = languages
            .map((lang) => lang['label'].toString())
            .toList();
      }

      // Set default values
      if (_roles.isNotEmpty) {
        final roleExists = _roles.any((r) => r['value'] == _selectedRole);
        if (_selectedRole.isEmpty || !roleExists) {
          _selectedRole = _roles[0]['value']!;
        }
      }

      if (_religions.isNotEmpty && _selectedReligion.isEmpty) {
        _selectedReligion = _religions[0]['value']!;
      }

      setState(() => _loadingOptions = false);
    } catch (e) {
      setState(() => _loadingOptions = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load options: $e'),
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
    print('[DEBUG] Submit Profile Started');

    // STEP 1: VALIDATE ALL FIELDS
    if (_firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your first name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your last name'),
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

    if (_selectedSkills.isEmpty) {
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

    print('[DEBUG] Validation Passed');

    // STEP 2: PREPARE DATA
    String workExperienceJson = _workExperiences.isNotEmpty
        ? jsonEncode(_workExperiences)
        : '';

    String educationJson = _educationList.isNotEmpty
        ? jsonEncode(_educationList)
        : '';

    // STEP 3: JUST MARK PROFILE AS COMPLETE (since auto-save already created it)
    try {
      print('[DEBUG] Calling save-step API for step 4');

      final response = await ApiService.saveCandidateStep(
        step: 4, // Final step
        data: {
          // Include resume and video if uploaded
          if (_resumeFile != null) 'resume': _resumeFile,
          if (_videoIntroFile != null) 'video_intro': _videoIntroFile,
        },
      );

      print('[DEBUG] Save Step Response: $response');

      if (response['success'] == true) {
        print('[DEBUG] Profile completed successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to candidate home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/candidate-home',
          (route) => false,
        );
      } else {
        print('[DEBUG] Failed to complete profile: ${response['error']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to complete profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[DEBUG] Exception during submit: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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
                'Step ${_currentPage + 1} of 4',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(_currentPage / 4 * 100).toInt()}% Complete',
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
    return Form(
      key: _personalFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Tell us about yourself',
            ),
            const SizedBox(height: 20),
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: _showImageSourceBottomSheet,
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person_outline,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _profileImage != null ? 'Change photo' : 'Add photo ',
                
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            if (_profileImage == null &&
                _personalFormKey.currentState != null &&
                !_personalFormKey.currentState!.validate())
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Profile image is required',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Basic Info
            // NEW
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person_outline,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'last name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.cake_outlined,
              isRequired: true,
              maxLength: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Age is required';
                }
                if (value.length != 2) {
                  return 'Age must be valid';
                }
                final age = int.tryParse(value);
                if (age == null || age < 18 || age > 99) {
                  // Change to 99 for consistency with maxLength=2
                  return 'Enter a valid age (18-99)';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 16),

            // Languages
            _loadingOptions
                ? _buildLoadingField('Loading languages...')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedLanguages.length),
                        value: _currentLanguageValue,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Languages',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.language_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        hint: Text(
                          _availableLanguages.isEmpty
                              ? 'No languages available'
                              : 'Select language',
                        ),
                        items: _availableLanguages
                            .where((lang) => !_selectedLanguages.contains(lang))
                            .map(
                              (lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                        onChanged: _availableLanguages.isEmpty
                            ? null
                            : (value) {
                                if (value != null) {
                                  if (value.toLowerCase() == 'other') {
                                    // Show dialog to enter custom language
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Add Custom Language',
                                        ),
                                        content: TextField(
                                          controller: _otherLanguageController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter language name',
                                            border: OutlineInputBorder(),
                                          ),
                                          textCapitalization:
                                              TextCapitalization.words,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (_otherLanguageController
                                                  .text
                                                  .isNotEmpty) {
                                                setState(() {
                                                  _selectedLanguages.add(
                                                    _otherLanguageController
                                                        .text,
                                                  );
                                                  _currentLanguageValue = null;
                                                  _otherLanguageController
                                                      .clear();
                                                });
                                                Navigator.pop(context);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primary,
                                            ),
                                            child: const Text(
                                              'Add',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _selectedLanguages.add(value);
                                      _currentLanguageValue = null;
                                    });
                                  }
                                }
                              },
                        validator: (value) {
                          if (_selectedLanguages.isEmpty) {
                            return 'At least one language is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
            if (_selectedLanguages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedLanguages
                    .map(
                      (lang) => Chip(
                        label: Text(lang, style: const TextStyle(fontSize: 13)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedLanguages.remove(lang)),
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppTheme.primary),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),

            // Address Section
            Text(
              'Address',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _streetAddressController,
              label: 'Street Address',
              icon: Icons.home_outlined,
              hintText: 'House no., Street, Area',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Street Address is required';
                }
                return null;
              },
              minLines: 1,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _loadingStates
                ? _buildLoadingField('Loading states...')
                : DropdownButtonFormField<String>(
                    value: _selectedStateId,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 15,
                    ),
                    decoration: _buildDropdownDecoration(
                      'State',
                      Icons.location_on_outlined,
                      true,
                    ),
                    hint: const Text('Select State'),
                    items: _states
                        .map(
                          (state) => DropdownMenuItem(
                            value: state['id'],
                            child: Text(state['name']!),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final selectedState = _states.firstWhere(
                          (s) => s['id'] == value,
                        );
                        setState(() {
                          _selectedStateId = value;
                          _stateController.text = selectedState['name']!;
                          _isOtherState = selectedState['slug'] == 'other';
                          if (!_isOtherState) {
                            _otherStateController.clear();
                            _fetchCities(selectedState['slug']!);
                          }
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null && !_isOtherState) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),

            if (_isOtherState) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _otherStateController,
                label: 'Specify State',
                icon: Icons.edit_outlined,
                isRequired: true,
                hintText: 'Enter your state',
              ),
            ],
            const SizedBox(height: 16),

            _loadingCities
                ? _buildLoadingField('Loading cities...')
                : DropdownButtonFormField<String>(
                    value: _selectedCityId,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 15,
                    ),
                    decoration: _buildDropdownDecoration(
                      'City',
                      Icons.location_city_outlined,
                      true,
                    ),
                    hint: Text(
                      _selectedStateId == null
                          ? 'Select a state first'
                          : 'Select City',
                    ),
                    items: _cities
                        .map(
                          (city) => DropdownMenuItem(
                            value: city['id'],
                            child: Text(city['name']!),
                          ),
                        )
                        .toList(),
                    onChanged: _selectedStateId == null || _isOtherState
                        ? null
                        : (value) {
                            if (value != null) {
                              final selectedCity = _cities.firstWhere(
                                (c) => c['id'] == value,
                              );
                              setState(() {
                                _selectedCityId = value;
                                _cityController.text = selectedCity['name']!;
                                _isOtherCity = selectedCity['slug']!.endsWith(
                                  '-other',
                                );
                                if (!_isOtherCity) {
                                  _otherCityController.clear();
                                }
                              });
                            }
                          },
                    validator: (value) {
                      if (value == null && !_isOtherCity) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),

            if (_isOtherCity) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _otherCityController,
                label: 'Specify City',
                icon: Icons.edit_outlined,
                isRequired: true,
                hintText: 'Enter your city',
              ),
            ],
            const SizedBox(height: 16),

            // Willing to Relocate
            _buildDropdownField(
              value: _willingToRelocate ? 'YES' : 'NO',
              label: 'Willing to Relocate?',
              icon: Icons.location_on,
              items: [
                {'value': 'YES', 'label': 'Yes'},
                {'value': 'NO', 'label': 'No'},
              ],
              onChanged: (value) {
                setState(() {
                  _willingToRelocate = value == 'YES';
                });
              },
            ),

            const SizedBox(height: 24),

            _loadingOptions
                ? _buildLoadingField('Loading roles...')
                : _buildDropdownField(
                    value: _selectedRole,
                    label: 'Role/Department',
                    icon: Icons.work_outline,
                    items: _roles,
                    onChanged: (value) => setState(() {
                      _selectedRole = value!;
                      _isOtherRole = value == 'other';
                      if (!_isOtherRole) {
                        _otherRoleController.clear();
                      }
                    }),
                  ),

            if (_isOtherRole) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _otherRoleController,
                label: 'Specify Role',
                icon: Icons.edit_outlined,
                isRequired: true,
                hintText: 'Enter your role',
              ),
            ],
            const SizedBox(height: 16),

            _buildTextField(
              controller: _careerObjectiveController,
              label: 'Career Objective',
              icon: Icons.flag_outlined,
              hintText: 'Describe your career goals...',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Career Objective is required';
                }
                return null;
              },
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),

            // const SizedBox(height: 16),
            _loadingOptions
                ? _buildLoadingField('Loading religions...')
                : _buildDropdownField(
                    value: _selectedReligion,
                    label: 'Religion ',
                    icon: Icons.account_circle_outlined,
                    items: _religions,
                    onChanged: (value) => setState(() {
                      _selectedReligion = value!;
                      _isOtherReligion = value == 'other';
                      if (!_isOtherReligion) {
                        _otherReligionController.clear();
                      }
                    }),
                  ),

            if (_isOtherReligion) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _otherReligionController,
                label: 'Specify Religion',
                icon: Icons.edit_outlined,
                isRequired: true,
                hintText: 'Enter your religion',
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _buildDropdownDecoration(
    String label,
    IconData icon, [
    bool isRequired = false,
  ]) {
    return InputDecoration(
      labelText: '$label${isRequired ? ' *' : ''}',
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildLoadingField(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
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
                icon: const Icon(Icons.add, color: AppTheme.primary, size: 28),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExperienceScreen(),
                    ),
                  );

                  if (result == null || result is! Map<String, dynamic>) {
                    return;
                  }

                  final bool isNewCurrent = result['is_current'] == true;

                  // Block second current job (keep your existing check)
                  if (isNewCurrent && _hasCurrentJob()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You already have a job marked as "Currently Working".\n'
                          'Please end the current one first if this new role is ongoing.',
                        ),
                        duration: Duration(seconds: 4),
                      ),
                    );
                    return;
                  }

                  // ── NEW: Block overlapping long-duration experiences ──
                  final newStartY =
                      int.tryParse(result['start_year'] ?? '0') ?? 0;
                  final newEndY = result['is_current'] == true
                      ? DateTime.now().year + 1
                      : int.tryParse(result['end_year'] ?? '0') ?? 0;

                  final hasOverlap = _workExperiences.any((exp) {
                    final expStart =
                        int.tryParse(exp['start_year'] ?? '0') ?? 0;
                    final expEnd = exp['is_current'] == true
                        ? DateTime.now().year + 1
                        : int.tryParse(exp['end_year'] ?? '0') ?? 0;

                    // Overlap if new range intersects existing range
                    // and at least one is long enough (≥1 year to catch short spam too)
                    return newStartY <= expEnd &&
                        newEndY >= expStart &&
                        (newEndY - newStartY >= 1 || expEnd - expStart >= 1);
                  });

                  if (hasOverlap) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot add this experience'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }

                  // All good → add and sort
                  setState(() {
                    _workExperiences.add(result);

                    _workExperiences.sort((a, b) {
                      final yA = int.tryParse(a['start_year'] ?? '0') ?? 0;
                      final yB = int.tryParse(b['start_year'] ?? '0') ?? 0;
                      if (yA != yB) return yB.compareTo(yA);

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
                      final mA = months.indexOf(a['start_month'] ?? 'January');
                      final mB = months.indexOf(b['start_month'] ?? 'January');
                      return mB.compareTo(mA);
                    });
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Experience added')),
                  );
                },
                tooltip: 'Add Experience',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Display Work Experiences
          if (_workExperiences.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No work experience added yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddExperienceScreen(),
                        ),
                      );

                      if (result == null || result is! Map<String, dynamic>) {
                        return;
                      }

                      final bool isNewCurrent = result['is_current'] == true;

                      // Only block if trying to add ANOTHER current job
                      if (isNewCurrent && _hasCurrentJob()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'You already have a job marked as "Currently Working"',
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _workExperiences.add(result);

                        _workExperiences.sort((a, b) {
                          final yA = int.tryParse(a['start_year'] ?? '0') ?? 0;
                          final yB = int.tryParse(b['start_year'] ?? '0') ?? 0;
                          if (yA != yB) return yB.compareTo(yA);

                          final mA = [
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
                          ].indexOf(a['start_month'] ?? 'January');
                          final mB = [
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
                          ].indexOf(b['start_month'] ?? 'January');
                          return mB.compareTo(mA);
                        });
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Experience added')),
                      );
                    },
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
          // Joining Availability Section
          const SizedBox(height: 20),

          Text(
            'Joining Availability',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ready to join immediately?',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Switch(
                      value: _joiningAvailability == 'IMMEDIATE',
                      onChanged: (value) {
                        setState(() {
                          _joiningAvailability = value
                              ? 'IMMEDIATE'
                              : 'NOTICE_PERIOD';

                          if (value) {
                            // Immediate → clear notice + remove error
                            _noticePeriodController.clear();
                            _noticePeriodError = null;
                          } else {
                            // Not immediate → validate right away (good UX)
                            _noticePeriodError = _validateNoticePeriod();
                          }
                        });
                      },
                      activeColor: AppTheme.primary,
                    ),
                  ],
                ),
                // Notice period field will now show by default
                if (_joiningAvailability == 'NOTICE_PERIOD') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noticePeriodController,
                    decoration: InputDecoration(
                      labelText: 'Notice Period Details *', // ← added *
                      hintText: 'e.g. 30 days, 2 months, serving notice period',
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,

                      // ── These three lines make it show red error ──
                      errorText: _noticePeriodError,
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (_joiningAvailability != 'NOTICE_PERIOD') {
                        return; // no need to validate when immediate
                      }

                      setState(() {
                        _noticePeriodError = _validateNoticePeriod();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasCurrentJob() {
    return _workExperiences.any((exp) => exp['is_current'] == true);
  }

  bool _hasActiveTimelineInCurrentYear() {
    final currentYear = DateTime.now().year.toString();

    return _workExperiences.any((exp) {
      final endY = exp['end_year'] as String?;
      final isCurrentFlag = exp['is_current'] == true;

      // Considered "active/current timeline" if:
      // - explicitly current, or
      // - end year is current year or missing/null, or
      // - end year >= current year
      return isCurrentFlag ||
          endY == null ||
          endY == currentYear ||
          (int.tryParse(endY ?? '0') ?? 0) >= int.parse(currentYear);
    });
  }

  String? _validateNoticePeriod() {
    if (_joiningAvailability == 'NOTICE_PERIOD') {
      final text = _noticePeriodController.text.trim();

      if (text.isEmpty) {
        return 'Notice period is required if not joining immediately';
      }
    }

    return null; // No error when immediate or filled correctly
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEducationScreen(),
                        ),
                      );

                      if (result == null || result is! Map<String, dynamic>) {
                        return;
                      }

                      // 1. Block exact duplicate (same school + degree + exact same years)
                      final newSchool =
                          (result['school'] as String?)?.trim().toLowerCase() ??
                          '';
                      final newDegree =
                          (result['degree'] as String?)?.trim().toLowerCase() ??
                          '';
                      final newStartY = result['start_year'] ?? '';
                      final newEndY = result['end_year'] ?? '';

                      final isExactDuplicate = _educationList.any((edu) {
                        return (edu['school'] as String?)
                                    ?.trim()
                                    .toLowerCase() ==
                                newSchool &&
                            (edu['degree'] as String?)?.trim().toLowerCase() ==
                                newDegree &&
                            edu['start_year'] == newStartY &&
                            edu['end_year'] == newEndY;
                      });

                      if (isExactDuplicate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'This exact education entry already exists',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // 2. Block if timeline matches / overlaps with any existing long education
                      final newStartYearInt = int.tryParse(newStartY) ?? 0;
                      final newEndYearInt = int.tryParse(newEndY) ?? 0;
                      final newDuration = newEndYearInt - newStartYearInt;

                      final hasTimelineConflict = _educationList.any((edu) {
                        final eduStart =
                            int.tryParse(edu['start_year'] ?? '0') ?? 0;
                        final eduEnd =
                            int.tryParse(edu['end_year'] ?? '0') ?? 0;

                        final overlaps =
                            newStartYearInt <= eduEnd &&
                            newEndYearInt >= eduStart;
                        final longDuration =
                            (eduEnd - eduStart) >= 2 || newDuration >= 2;

                        return overlaps && longDuration;
                      });

                      if (hasTimelineConflict) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot add this education \n'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                          ),
                        );
                        return;
                      }

                      // If reached here → safe to add
                      setState(() {
                        _educationList.add(result);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Education added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add skills',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Autocomplete<String>(
                    optionsMaxHeight: 200,
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    option,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: 'e.g., Adobe Photoshop',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty &&
                                  !_selectedSkills.contains(value)) {
                                setState(() {
                                  _selectedSkills.add(value);
                                });
                                controller.clear();
                              }
                            },
                          );
                        },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final input = textEditingValue.text.toLowerCase();
                      if (input.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _availableSkills.where(
                        (skill) => skill.toLowerCase().contains(input),
                      );
                    },
                    onSelected: (String selection) {
                      if (!_selectedSkills.contains(selection)) {
                        setState(() {
                          _selectedSkills.add(selection);
                        });
                      }
                    },
                  ),
                  if (_selectedSkills.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedSkills
                          .map(
                            (skill) => Chip(
                              label: Text(
                                skill,
                                style: const TextStyle(fontSize: 13),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () =>
                                  setState(() => _selectedSkills.remove(skill)),
                              backgroundColor: AppTheme.primary.withOpacity(
                                0.1,
                              ),
                              labelStyle: const TextStyle(
                                color: AppTheme.primary,
                              ),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSkillsBottomSheet() {
    final TextEditingController searchController = TextEditingController();
    List<String> filteredSkills = List.from(_availableSkills);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------- HEADER ----------
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // -------- SEARCH FIELD ----------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setModalState(() {
                          filteredSkills = _availableSkills
                              .where(
                                (skill) => skill.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Add skills',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------- SUGGESTION LIST ----------
                  Flexible(
                    child: ListView.builder(
                      itemCount: filteredSkills.length,
                      itemBuilder: (context, index) {
                        final skill = filteredSkills[index];

                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (!_selectedSkills.contains(skill)) {
                                _selectedSkills.add(skill);
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ========== Education Methods ==========

  // void _showAddEducationDialog() {
  //   final schoolController = TextEditingController();
  //   final degreeController = TextEditingController();
  //   final fieldController = TextEditingController();
  //   final gradeController = TextEditingController();
  //   final locationController = TextEditingController();

  //   String startMonth = 'January';
  //   String startYear = DateTime.now().year.toString();
  //   String endMonth = 'January';
  //   String endYear = DateTime.now().year.toString();

  //   final months = [
  //     'January',
  //     'February',
  //     'March',
  //     'April',
  //     'May',
  //     'June',
  //     'July',
  //     'August',
  //     'September',
  //     'October',
  //     'November',
  //     'December',
  //   ];
  //   final years = List.generate(
  //     50,
  //     (index) => (DateTime.now().year - index).toString(),
  //   );

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.95,
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //       ),
  //       child: StatefulBuilder(
  //         builder: (context, setDialogState) => Column(
  //           children: [
  //             // Handle bar
  //             Container(
  //               margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
  //               height: 4,
  //               width: 40,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[300],
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),

  //             // Header
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20),
  //               child: Row(
  //                 children: [
  //                   const Expanded(
  //                     child: Text(
  //                       'Add education',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                   IconButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     icon: const Icon(Icons.close),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             // Form
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 padding: const EdgeInsets.symmetric(horizontal: 20),
  //                 child: Column(
  //                   children: [
  //                     TextField(
  //                       controller: schoolController,
  //                       decoration: const InputDecoration(
  //                         labelText: 'School/University *',
  //                         hintText: 'Enter your school or university name',
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     TextField(
  //                       controller: locationController,
  //                       decoration: const InputDecoration(
  //                         labelText: 'Location',
  //                         hintText: 'Enter your Location',
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     TextField(
  //                       controller: degreeController,
  //                       decoration: const InputDecoration(
  //                         labelText: 'Degree *',
  //                         hintText: "e.g., Bachelor's, Master's",
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     TextField(
  //                       controller: fieldController,
  //                       decoration: const InputDecoration(
  //                         labelText: 'Field of Study',
  //                         hintText: 'e.g., Computer Science',
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 16),

  //                     // Start Date
  //                     const Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: Text(
  //                         'Start Date *',
  //                         style: TextStyle(fontWeight: FontWeight.w600),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: DropdownButtonFormField<String>(
  //                             value: startMonth,
  //                             decoration: const InputDecoration(
  //                               labelText: 'Month',
  //                               border: OutlineInputBorder(),
  //                             ),
  //                             items: months
  //                                 .map(
  //                                   (month) => DropdownMenuItem(
  //                                     value: month,
  //                                     child: Text(month),
  //                                   ),
  //                                 )
  //                                 .toList(),
  //                             onChanged: (value) =>
  //                                 setDialogState(() => startMonth = value!),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: DropdownButtonFormField<String>(
  //                             value: startYear,
  //                             decoration: const InputDecoration(
  //                               labelText: 'Year',
  //                               border: OutlineInputBorder(),
  //                             ),
  //                             items: years
  //                                 .map(
  //                                   (year) => DropdownMenuItem(
  //                                     value: year,
  //                                     child: Text(year),
  //                                   ),
  //                                 )
  //                                 .toList(),
  //                             onChanged: (value) =>
  //                                 setDialogState(() => startYear = value!),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 16),

  //                     // End Date
  //                     const Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: Text(
  //                         'End Date (or Expected) *',
  //                         style: TextStyle(fontWeight: FontWeight.w600),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: DropdownButtonFormField<String>(
  //                             value: endMonth,
  //                             decoration: const InputDecoration(
  //                               labelText: 'Month',
  //                               border: OutlineInputBorder(),
  //                             ),
  //                             items: months
  //                                 .map(
  //                                   (month) => DropdownMenuItem(
  //                                     value: month,
  //                                     child: Text(month),
  //                                   ),
  //                                 )
  //                                 .toList(),
  //                             onChanged: (value) =>
  //                                 setDialogState(() => endMonth = value!),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: DropdownButtonFormField<String>(
  //                             value: endYear,
  //                             decoration: const InputDecoration(
  //                               labelText: 'Year',
  //                               border: OutlineInputBorder(),
  //                             ),
  //                             items: years
  //                                 .map(
  //                                   (year) => DropdownMenuItem(
  //                                     value: year,
  //                                     child: Text(year),
  //                                   ),
  //                                 )
  //                                 .toList(),
  //                             onChanged: (value) =>
  //                                 setDialogState(() => endYear = value!),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 16),
  //                     TextField(
  //                       controller: gradeController,
  //                       decoration: const InputDecoration(
  //                         labelText: 'Grade/Percentage',
  //                         hintText: 'e.g., 8.5 CGPA or 85%',
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 40),
  //                   ],
  //                 ),
  //               ),
  //             ),

  //             // Buttons
  //             Container(
  //               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
  //               decoration: const BoxDecoration(
  //                 border: Border(top: BorderSide(color: Color(0xFFF1F3F4))),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text('Discard'),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       if (schoolController.text.isEmpty ||
  //                           degreeController.text.isEmpty) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text('Please fill all required fields'),
  //                             backgroundColor: Colors.red,
  //                           ),
  //                         );
  //                         return;
  //                       }

  //                       // Ã¢Å“â€¦ DUPLICATE EDUCATION PREVENTION
  //                       final newEducationKey =
  //                           '${schoolController.text.toLowerCase()}-${degreeController.text.toLowerCase()}-${startYear}-${endYear}';
  //                       if (_educationList.any((edu) {
  //                         final existingKey =
  //                             '${edu['school'].toLowerCase()}-${edu['degree'].toLowerCase()}-${edu['start_year']}-${edu['end_year']}';
  //                         return existingKey == newEducationKey;
  //                       })) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text(
  //                               'This education entry already exists',
  //                             ),
  //                             backgroundColor: Colors.orange,
  //                           ),
  //                         );
  //                         return;
  //                       }
  //                       final startDate = DateTime(
  //                         int.parse(startYear),
  //                         _getMonthIndex(startMonth),
  //                         1,
  //                       );
  //                       final endDate = DateTime(
  //                         int.parse(endYear),
  //                         _getMonthIndex(endMonth),
  //                         1,
  //                       );

  //                       if (endDate.isBefore(startDate)) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text(
  //                               'End date must be after or same as start date',
  //                             ),
  //                             backgroundColor: Colors.red,
  //                           ),
  //                         );
  //                         return;
  //                       }

  //                       if (startYear == endYear && startMonth == endMonth) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           const SnackBar(
  //                             content: Text(
  //                               'Start and end dates cannot be the same',
  //                             ),
  //                             backgroundColor: Colors.red,
  //                           ),
  //                         );
  //                         return;
  //                       }

  //                       if (endDate.isAfter(DateTime.now())) {
  //                         // Future dates OK for education (expected graduation)
  //                       }

  //                       setState(() {
  //                         _educationList.add({
  //                           'school': schoolController.text,
  //                           'degree': degreeController.text,
  //                           'field': fieldController.text,
  //                           'location': locationController.text,
  //                           'start_month': startMonth,
  //                           'start_year': startYear,
  //                           'end_month': endMonth,
  //                           'end_year': endYear,
  //                           'grade': gradeController.text,
  //                         });
  //                       });
  //                       Navigator.pop(context);
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(
  //                           content: Text('Education added successfully'),
  //                           backgroundColor: Colors.green,
  //                         ),
  //                       );
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppTheme.primary,
  //                       foregroundColor: Colors.white,
  //                       minimumSize: const Size(100, 44),
  //                     ),
  //                     child: const Text('Save'),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // int _getMonthIndex(String month) {
  //   const months = {
  //     'January': 1,
  //     'February': 2,
  //     'March': 3,
  //     'April': 4,
  //     'May': 5,
  //     'June': 6,
  //     'July': 7,
  //     'August': 8,
  //     'September': 9,
  //     'October': 10,
  //     'November': 11,
  //     'December': 12,
  //   };
  //   return months[month] ?? 1;
  // }

  Widget _buildEducationDisplayCard(Map<String, dynamic> education, int index) {
    String startYear = education['start_year']?.toString() ?? '';
    String endYear = education['end_year']?.toString() ?? 'Present';
    String duration = '$startYear - $endYear';

    String degreeText = education['degree']?.toString() ?? 'N/A';

    String? fieldOfStudy =
        education['field_of_study']?.toString() ??
        education['field']?.toString();

    if (fieldOfStudy != null && fieldOfStudy.isNotEmpty) {
      degreeText += ' $fieldOfStudy';
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
                  education['institution_name']?.toString() ??
                      education['school']?.toString() ??
                      'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                // Ã°Å¸â€œÂ Location
                if (education['location'] != null &&
                    education['location'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    education['location'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],

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

                if (education['grade_percentage'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.grade, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Grade: ${education['grade_percentage']}',
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

  // PAGE 4: Documents
  Widget _buildDocumentsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            icon: Icons.upload_file_outlined,
            title: 'Documents ',
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
    String? Function(String?)? validator, // Add this new parameter
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),

        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        suffixText: isRequired
            ? '*'
            : null, // Optional: Add asterisk for required fields
        counterText: '',
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      validator: validator, // Pass the validator here
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    final valueExists = items.any((item) => item['value'] == value);
    final validValue = valueExists
        ? value
        : (items.isNotEmpty ? items[0]['value']! : '');
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
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
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _currentCtcController.dispose();
    _expectedCtcController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _educationController.dispose();
    _streetAddressController.dispose();
    _careerObjectiveController.dispose();
    _otherRoleController.dispose();
    _otherReligionController.dispose();
    _otherStateController.dispose();
    _otherCityController.dispose();
    _otherSkillController.dispose();
    _otherLanguageController.dispose();
    _noticePeriodController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      print('[LIFECYCLE] App going to background, auto-saving...');
      _autoSaveCurrentStep();
    }
  }

  Future<void> _loadSavedProfile() async {
    try {
      final response = await ApiService.getCandidateProfile();

      if (response.containsKey('error')) {
        return;
      }

      final profile = response;
      int savedStep = profile['profile_step'] ?? 1;
      bool isCompleted = profile['is_profile_completed'] ?? false;

      if (isCompleted) {
        Navigator.pushReplacementNamed(context, '/candidate-home');
        return;
      }

      setState(() {
        // _fullNameController.text = profile['full_name'] ?? '';
        _firstNameController.text = profile['first_name'] ?? '';
        _lastNameController.text = profile['last_name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _ageController.text = profile['age']?.toString() ?? '';
        _currentCtcController.text = profile['current_ctc']?.toString() ?? '';
        _expectedCtcController.text = profile['expected_ctc']?.toString() ?? '';
        _stateController.text = profile['state_name'] ?? '';
        _cityController.text = profile['city_name'] ?? '';
        _selectedRole = profile['role_name'] ?? 'IT';
        _selectedReligion = profile['religion_name'] ?? '';
        _streetAddressController.text = profile['street_address'] ?? '';
        _careerObjectiveController.text = profile['career_objective'] ?? '';
        _willingToRelocate = profile['willing_to_relocate'] ?? false;
        _joiningAvailability = profile['joining_availability'] ?? 'IMMEDIATE';
        _noticePeriodController.text = profile['notice_period_details'] ?? '';

        if (profile['languages'] != null &&
            profile['languages'].toString().isNotEmpty) {
          _selectedLanguages = profile['languages']
              .toString()
              .split(',')
              .map((e) => e.trim())
              .toList();
        }

        if (profile['work_experiences'] != null) {
          final workExpList = profile['work_experiences'] as List<dynamic>;
          _workExperiences = workExpList
              .map(
                (exp) => {
                  'company_name': exp['company_name'] ?? '',
                  'role_title': exp['role_title'] ?? '',
                  'start_month': _getMonthFromDate(exp['start_date']),
                  'start_year': _getYearFromDate(exp['start_date']),
                  'end_month': exp['end_date'] != null
                      ? _getMonthFromDate(exp['end_date'])
                      : null,
                  'end_year': exp['end_date'] != null
                      ? _getYearFromDate(exp['end_date'])
                      : null,
                  'is_current': exp['is_current'] ?? false,
                  'location': exp['location'] ?? '',
                  'description': exp['description'] ?? '',
                },
              )
              .cast<Map<String, dynamic>>()
              .toList();
        }

        if (profile['skills'] != null &&
            profile['skills'].toString().isNotEmpty) {
          _selectedSkills = profile['skills']
              .toString()
              .split(',')
              .map((e) => e.trim())
              .toList();
        }

        if (profile['educations'] != null) {
          final educationsList = profile['educations'] as List<dynamic>;
          _educationList = educationsList
              .map(
                (edu) => {
                  'school': edu['institution_name'] ?? '',
                  'degree': edu['degree'] ?? '',
                  'field': edu['field_of_study'] ?? '',
                  'start_month': 'January',
                  'start_year': edu['start_year']?.toString() ?? '',
                  'end_month': 'December',
                  'end_year': edu['end_year']?.toString() ?? '',
                  'grade': edu['grade_percentage']?.toString() ?? '',
                  'location': edu['location'] ?? '',
                },
              )
              .cast<Map<String, dynamic>>()
              .toList();
        }

        if (savedStep > 1 && savedStep <= 4) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _pageController.hasClients) {
              _pageController.jumpToPage(savedStep - 1);
              setState(() => _currentPage = savedStep - 1);
            }
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resuming from Step $savedStep'),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('[LOAD] Error loading saved profile: $e');
    }
  }

  Future<void> _autoSaveCurrentStep() async {
    Map<String, dynamic> stepData = {};

    switch (_currentPage) {
      case 0:
        stepData = {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'phone': _phoneController.text,
          'age': _ageController.text,
          'role': _isOtherRole ? _otherRoleController.text : _selectedRole,
          'current_ctc': _currentCtcController.text,
          'expected_ctc': _expectedCtcController.text,
          'state': _isOtherState
              ? _otherStateController.text
              : _stateController.text,
          'city': _isOtherCity
              ? _otherCityController.text
              : _cityController.text,
          'religion': _isOtherReligion
              ? _otherReligionController.text
              : _selectedReligion,
          'languages': _selectedLanguages.join(', '),
          'street_address': _streetAddressController.text,
          'willing_to_relocate': _willingToRelocate.toString(),
          'career_objective': _careerObjectiveController.text,
          // 'joining_availability': _joiningAvailability ?? 'NOTICE_PERIOD',
          // 'notice_period_details': _noticePeriodController.text,
        };

        if (_profileImage != null) {
          stepData['profile_image'] = _profileImage;
        }
        break;

      case 1:
        stepData = {
          // ✅ Notice period ONLY here
          'joining_availability': _joiningAvailability,
          'notice_period_details': _noticePeriodController.text,

          // Work experience
          if (_workExperiences.isNotEmpty)
            'work_experience': jsonEncode(_workExperiences),
        };

        break;

      case 2:
        stepData['skills'] = _selectedSkills.join(', ');
        if (_educationList.isNotEmpty) {
          stepData['education'] = jsonEncode(_educationList);
        }
        break;

      case 3:
        if (_resumeFile != null) {
          stepData['resume'] = _resumeFile;
        }
        if (_videoIntroFile != null) {
          stepData['video_intro'] = _videoIntroFile;
        }
        break;
    }

    try {
      final response = await ApiService.saveCandidateStep(
        step: _currentPage + 1,
        data: stepData,
      );

      if (response.containsKey('success') && response['success'] == true) {
        print('[AUTO-SAVE] Step ${_currentPage + 1} saved successfully');
      }
    } catch (e) {
      print('[AUTO-SAVE] Error: $e');
    }
  }

  String _getMonthFromDate(String? dateStr) {
    if (dateStr == null) return 'January';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
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
      return months[date.month - 1];
    } catch (e) {
      return 'January';
    }
  }

  String _getYearFromDate(String? dateStr) {
    if (dateStr == null) return DateTime.now().year.toString();
    try {
      final date = DateTime.parse(dateStr);
      return date.year.toString();
    } catch (e) {
      return DateTime.now().year.toString();
    }
  }

  // ========== Work Experience Methods ==========

  // void _showAddExperienceDialog() {
  //   final companyController = TextEditingController();
  //   final locationController = TextEditingController();
  //   final descriptionController = TextEditingController();
  //   final ctcController = TextEditingController();
  //   final roleController = TextEditingController();

  //   final int currentYear = DateTime.now().year;

  //   String startMonth = 'January';
  //   String startYear = currentYear.toString();
  //   String endMonth = 'January';
  //   String endYear = currentYear.toString();
  //   bool isCurrentlyWorking = false;

  //   final months = [
  //     'January',
  //     'February',
  //     'March',
  //     'April',
  //     'May',
  //     'June',
  //     'July',
  //     'August',
  //     'September',
  //     'October',
  //     'November',
  //     'December',
  //   ];

  //   /// ✅ YEARS (past → present)
  //   final years = List.generate(
  //     50,
  //     (index) => (currentYear - 49 + index).toString(),
  //   );

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.95,
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //       ),
  //       child: StatefulBuilder(
  //         builder: (context, setDialogState) => Column(
  //           children: [
  //             const SizedBox(height: 12),

  //             /// Header
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20),
  //               child: Row(
  //                 children: [
  //                   const Expanded(
  //                     child: Text(
  //                       'Add work experience',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                   IconButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     icon: const Icon(Icons.close),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             /// Form
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 padding: const EdgeInsets.symmetric(horizontal: 20),
  //                 child: Column(
  //                   children: [
  //                     _buildTextField(
  //                       controller: companyController,
  //                       label: 'Company Name *',
  //                       icon: Icons.person,
  //                       // hint: 'Enter company name',
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildTextField(
  //                       controller: roleController,
  //                       label: 'Job Role / Position *',
  //                       icon: Icons.person,
  //                       // hint: 'Enter role',
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildTextField(
  //                       icon: Icons.location_city,
  //                       controller: locationController,
  //                       label: 'Location',
  //                       // hint: 'e.g. Gurugram',
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildTextField(
  //                       controller: descriptionController,
  //                       icon: Icons.description,
  //                       label: 'Description',
  //                       // hint: 'Describe your role',
  //                       maxLines: null,
  //                     ),
  //                     const SizedBox(height: 16),
  //                     _buildTextField(
  //                       controller: ctcController,
  //                       label: 'CTC (Annual)',
  //                       icon: Icons.money,
  //                       // hint: 'e.g. 500000',
  //                       keyboardType: TextInputType.number,
  //                     ),
  //                     const SizedBox(height: 16),

  //                     /// Start Date
  //                     const Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: Text(
  //                         'Start Date *',
  //                         style: TextStyle(fontWeight: FontWeight.w600),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: _buildDropdown(
  //                             value: startMonth,
  //                             items: months,
  //                             label: 'Month',
  //                             onChanged: (v) =>
  //                                 setDialogState(() => startMonth = v),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: _buildDropdown(
  //                             value: startYear,
  //                             items: years,
  //                             label: 'Year',
  //                             onChanged: (v) =>
  //                                 setDialogState(() => startYear = v),
  //                           ),
  //                         ),
  //                       ],
  //                     ),

  //                     const SizedBox(height: 12),

  //                     CheckboxListTile(
  //                       value: isCurrentlyWorking,
  //                       onChanged: (value) {
  //                         setDialogState(() => isCurrentlyWorking = value!);
  //                       },
  //                       title: const Text(
  //                         'I am currently working in this role',
  //                       ),
  //                       contentPadding: EdgeInsets.zero,
  //                       controlAffinity: ListTileControlAffinity.leading,
  //                     ),

  //                     if (!isCurrentlyWorking) ...[
  //                       const SizedBox(height: 8),
  //                       const Align(
  //                         alignment: Alignment.centerLeft,
  //                         child: Text(
  //                           'End Date *',
  //                           style: TextStyle(fontWeight: FontWeight.w600),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: _buildDropdown(
  //                               value: endMonth,
  //                               items: months,
  //                               label: 'Month',
  //                               onChanged: (v) =>
  //                                   setDialogState(() => endMonth = v),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Expanded(
  //                             child: _buildDropdown(
  //                               value: endYear,
  //                               items: years,
  //                               label: 'Year',
  //                               onChanged: (v) =>
  //                                   setDialogState(() => endYear = v),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                     const SizedBox(height: 40),
  //                   ],
  //                 ),
  //               ),
  //             ),

  //             /// Save Button
  //             Padding(
  //               padding: const EdgeInsets.all(20),
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppTheme.primary,
  //                   minimumSize: const Size(double.infinity, 48),
  //                 ),
  //                 child: const Text('Save'),
  //                 onPressed: () {
  //                   /// REQUIRED FIELDS
  //                   if (companyController.text.isEmpty ||
  //                       roleController.text.isEmpty) {
  //                     _showSnack('Please fill all required fields', Colors.red);
  //                     return;
  //                   }

  //                   /// DATE VALIDATION
  //                   if (!isCurrentlyWorking &&
  //                       int.parse(endYear) < int.parse(startYear)) {
  //                     _showSnack(
  //                       'End year cannot be before start year',
  //                       Colors.red,
  //                     );
  //                     return;
  //                   }

  //                   setState(() {
  //                     if (isCurrentlyWorking) {
  //                       for (var exp in _workExperiences) {
  //                         exp['is_current'] = false;
  //                       }
  //                     }

  //                     _workExperiences.add({
  //                       'company_name': companyController.text,
  //                       'role_title': roleController.text,
  //                       'location': locationController.text,
  //                       'description': descriptionController.text,
  //                       'ctc': ctcController.text,
  //                       'start_month': startMonth,
  //                       'start_year': startYear,
  //                       'end_month': isCurrentlyWorking ? null : endMonth,
  //                       'end_year': isCurrentlyWorking ? null : endYear,
  //                       'is_current': isCurrentlyWorking,
  //                     });
  //                   });

  //                   Navigator.pop(context);
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index) {
    String duration =
        '${experience['start_month']} ${experience['start_year']}';
    duration += experience['is_current']
        ? ' - Present'
        : ' - ${experience['end_month']} ${experience['end_year']}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER ROW (Icon + Title + Delete)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience['job_role'] ??
                          experience['role_title'] ??
                          'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience['company_name'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () =>
                    setState(() => _workExperiences.removeAt(index)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                /// LEFT: Location
                Expanded(
                  child:
                      experience['location'] != null &&
                          experience['location'].toString().isNotEmpty
                      ? Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                experience['location'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),

                /// RIGHT: Date
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
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
              ],
            ),
          ),

          /// CTC
          if (experience['ctc'] != null &&
              experience['ctc'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${NumberFormat.compact().format(int.parse(experience['ctc'].toString()))} CTC',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          /// DESCRIPTION
          if (experience['description'] != null &&
              experience['description'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                experience['description'],
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
            ),

          /// CURRENTLY WORKING BADGE
          if (experience['is_current'])
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Currently Working',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
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
