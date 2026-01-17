import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/services/api_service.dart';
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
  // late TextEditingController _fullNameController;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _experienceController;
  late TextEditingController _currentCtcController;
  late TextEditingController _expectedCtcController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _skillsController;
  late TextEditingController _languagesController;
  late TextEditingController _streetAddressController;
  late TextEditingController _careerObjectiveController;

  late String _selectedRole;
  late String _selectedReligion;
  File? _resumeFile;
  String? _resumeFileName;
  File? _videoIntroFile;
  String? _videoIntroFileName;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool _willingToRelocate = false;
  List<Map<String, String>> _roles = [];
  List<Map<String, String>> _religions = [];
  bool _loadingOptions = false;

  // Dynamic lists
  List<Map<String, dynamic>> _workExperiences = [];
  List<Map<String, dynamic>> _educationList = [];

  // Helper method to parse backend list format
  List<Map<String, dynamic>> _parseBackendList(String? data) {
    if (data == null || data.isEmpty) return [];

    try {
      // Remove outer brackets if present
      String cleaned = data.trim();
      if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }

      // Split by '}, {' to get individual items
      List<String> items = [];
      int braceCount = 0;
      int startIndex = 0;

      for (int i = 0; i < cleaned.length; i++) {
        if (cleaned[i] == '{') {
          braceCount++;
          if (braceCount == 1) startIndex = i;
        } else if (cleaned[i] == '}') {
          braceCount--;
          if (braceCount == 0) {
            items.add(cleaned.substring(startIndex, i + 1));
          }
        }
      }

      // Parse each item
      List<Map<String, dynamic>> result = [];
      for (String item in items) {
        Map<String, dynamic> map = {};

        // Remove braces
        String content = item.substring(1, item.length - 1);

        // Split by ', ' to get key-value pairs
        List<String> pairs = [];
        int depth = 0;
        int lastSplit = 0;

        for (int i = 0; i < content.length; i++) {
          if (content[i] == '{') depth++;
          if (content[i] == '}') depth--;

          if (depth == 0 && i < content.length - 1) {
            if (content[i] == ',' && content[i + 1] == ' ') {
              pairs.add(content.substring(lastSplit, i));
              lastSplit = i + 2;
            }
          }
        }
        pairs.add(content.substring(lastSplit));

        // Parse each pair
        for (String pair in pairs) {
          List<String> parts = pair.split(': ');
          if (parts.length == 2) {
            String key = parts[0].trim();
            String value = parts[1].trim();

            // Convert value to appropriate type
            if (value == 'null') {
              map[key] = null;
            } else if (value == 'true') {
              map[key] = true;
            } else if (value == 'false') {
              map[key] = false;
            } else {
              map[key] = value;
            }
          }
        }

        result.add(map);
      }

      return result;
    } catch (e) {
      print('Error parsing backend list: $e');
      print('Data: $data');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    firstNameController.text = widget.profileData['first_name'] ?? '';
    lastNameController.text = widget.profileData['last_name'] ?? '';
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

    _languagesController = TextEditingController(
      text: widget.profileData['languages'] ?? '',
    );
    _streetAddressController = TextEditingController(
      text: widget.profileData['street_address'] ?? '',
    );
    _careerObjectiveController = TextEditingController(
      text: widget.profileData['career_objective'] ?? '',
    );

    final skillsList = widget.profileData['skills_list'] as List<dynamic>?;
    _skillsController = TextEditingController(
      text: skillsList?.join(', ') ?? widget.profileData['skills'] ?? '',
    );

    final workExpList = widget.profileData['work_experiences'];
    if (workExpList != null && workExpList is List) {
      _workExperiences = workExpList
          .map<Map<String, dynamic>>(
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
              'ctc': exp['current_ctc']?.toString() ?? '',  

            },
          )
          .toList();
    }

    // Fix education parsing
    final educationsList = widget.profileData['educations'];
    if (educationsList != null && educationsList is List) {
      _educationList = educationsList
          .map<Map<String, dynamic>>(
            (edu) => {
              'school': edu['institution_name'] ?? '',
              'degree': edu['degree'] ?? '',
              'field': edu['field_of_study'] ?? '',
              'start_month': 'January', // Default since API doesn't have month
              'start_year': edu['start_year']?.toString() ?? '',
              'end_month': 'December', // Default
              'end_year': edu['end_year']?.toString() ?? '',
              'grade': edu['grade_percentage']?.toString() ?? '',
              'location': edu['location'] ?? '',
            },
          )
          .toList();
    }
    _willingToRelocate = widget.profileData['willing_to_relocate'] ?? false;

    _selectedRole = '';
    _selectedReligion = '';
    _fetchDepartmentsAndReligions();
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

  Future<void> _fetchDepartmentsAndReligions() async {
  setState(() => _loadingOptions = true);
  try {
    final response = await ApiService.getDepartmentsAndReligions();
    if (response.containsKey('error')) {
      throw Exception(response['error']);
    }

    // ✅ CLEAR existing lists
    _roles.clear();
    _religions.clear();

    // Handle departments
    final departments = response['departments'] as List;
    for (var dept in departments) {
      final value = dept['value'].toString().trim();
      final label = dept['label'].toString().trim();
      _roles.add({'value': value, 'label': label});
    }
    _roles.sort((a, b) => a['label']!.compareTo(b['label']!));

    // Remove duplicates if any
    final Map<String, Map<String, String>> uniqueRoles = {};
    for (var role in _roles) {
      uniqueRoles[role['value']!] = role;
    }
    _roles = uniqueRoles.values.toList();
    _roles.sort((a, b) => a['label']!.compareTo(b['label']!));

    // Handle religions
    final religions = response['religions'] as List;
    for (var relig in religions) {
      final value = relig['value'].toString().trim();
      final label = relig['label'].toString().trim();
      _religions.add({'value': value, 'label': label});
    }
    _religions.sort((a, b) => a['label']!.compareTo(b['label']!));

    // Remove duplicates
    final Map<String, Map<String, String>> uniqueReligions = {};
    for (var relig in _religions) {
      uniqueReligions[relig['value']!] = relig;
    }
    _religions = uniqueReligions.values.toList();
    _religions.sort((a, b) => a['label']!.compareTo(b['label']!));

    // ✅ NOW SET THE ROLE FROM PROFILE DATA
    final roleFromProfile = widget.profileData['role_name'] ?? '';
    print('[EDIT] Role from profile: "$roleFromProfile"');
    print('[EDIT] Available roles: ${_roles.map((r) => r['label']).toList()}');
    
    if (roleFromProfile.isNotEmpty && _roles.isNotEmpty) {
      // Find by label
      final roleExists = _roles.any((r) => r['label'] == roleFromProfile);
      if (roleExists) {
        final matchingRole = _roles.firstWhere((r) => r['label'] == roleFromProfile);
        _selectedRole = matchingRole['value']!;
        print('[EDIT] Set role to: "$_selectedRole"');
      } else {
        // Not found, use first
        _selectedRole = _roles[0]['value']!;
        print('[EDIT] Role not found, using default: "$_selectedRole"');
      }
    } else if (_roles.isNotEmpty) {
      _selectedRole = _roles[0]['value']!;
    }

    // ✅ SET RELIGION FROM PROFILE DATA
    final religionFromProfile = widget.profileData['religion_name'] ?? '';
    if (religionFromProfile.isNotEmpty && _religions.isNotEmpty) {
      final religionExists = _religions.any((r) => r['label'] == religionFromProfile);
      if (religionExists) {
        final matchingReligion = _religions.firstWhere((r) => r['label'] == religionFromProfile);
        _selectedReligion = matchingReligion['value']!;
      } else {
        _selectedReligion = _religions[0]['value']!;
      }
    } else if (_religions.isNotEmpty) {
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

  @override
  void dispose() {
    // _fullNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _experienceController.dispose();
    _currentCtcController.dispose();
    _expectedCtcController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    _streetAddressController.dispose();
    _careerObjectiveController.dispose();
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

      status = await Permission.photos.request();

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
            if (_profileImage != null ||
                widget.profileData['profile_image_url'] != null)
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

  // ========== Work Experience Methods ==========

  void _showAddExperienceDialog({
    Map<String, dynamic>? experience,
    int? index,
  }) {
    final companyController = TextEditingController(
      text: experience?['company_name'] ?? '',
    );
    final roleController = TextEditingController(
      text: experience?['role_title'] ?? '',
    );
    final locationController = TextEditingController(
      text: experience?['location'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: experience?['description'] ?? '',
    );
      final ctcController = TextEditingController(text: experience?['ctc'] ?? '');  


    String startMonth = experience?['start_month'] ?? 'January';
    String startYear =
        experience?['start_year'] ?? DateTime.now().year.toString();
    String endMonth = experience?['end_month'] ?? 'January';
    String endYear = experience?['end_year'] ?? DateTime.now().year.toString();
    bool isCurrentlyWorking = experience?['is_current'] ?? false;

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
      (i) => (DateTime.now().year - i).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            experience == null ? 'Add Work Experience' : 'Edit Work Experience',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Same input fields as before...
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Role / Position *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g. Gurgaon, Haryana',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Briefly describe your role & work',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                controller: ctcController,
                decoration: const InputDecoration(
                  labelText: 'Current CTC (Annual in Lakhs)',
                  hintText: 'e.g., 5.5, 12, 18.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                            isExpanded: true, 
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        items: months
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m,overflow: TextOverflow.ellipsis,)),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => startMonth = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: startYear,
                        isExpanded: true, 

                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        items: years
                            .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => startYear = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: isCurrentlyWorking,
                  onChanged: (v) =>
                      setDialogState(() => isCurrentlyWorking = v ?? false),
                  title: const Text('I am currently working in this role'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isCurrentlyWorking) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: endMonth,
                          decoration: const InputDecoration(
                            labelText: 'End Month',
                            border: OutlineInputBorder(),
                          ),
                          items: months
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          onChanged: (v) => setDialogState(() => endMonth = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: endYear,
                          decoration: const InputDecoration(
                            labelText: 'End Year',
                            border: OutlineInputBorder(),
                          ),
                          items: years
                              .map(
                                (y) =>
                                    DropdownMenuItem(value: y, child: Text(y)),
                              )
                              .toList(),
                          onChanged: (v) => setDialogState(() => endYear = v!),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
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
                  final workData = {
                    'company_name': companyController.text,
                    'role_title':
                        roleController.text, 

                    'location': locationController.text,
                    'description': descriptionController.text,
                    'ctc': ctcController.text,  
                    'start_month': startMonth,
                    'start_year': startYear,
                    'end_month': isCurrentlyWorking ? null : endMonth,
                    'end_year': isCurrentlyWorking ? null : endYear,
                    'is_current': isCurrentlyWorking,
                  };

                  if (index != null) {
                    // EDIT existing experience
                    _workExperiences[index] = workData;
                  } else {
                    // ADD new experience
                    _workExperiences.add(workData);
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () => _showAddExperienceDialog(
                      experience: experience,
                      index: index,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _workExperiences.removeAt(index);
                      });
                    },
                  ),
                ],
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
          if (experience['ctc'] != null && experience['ctc'].toString().isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(Icons.payments_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '₹${experience['ctc']} LPA',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
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

  // ========== Education Methods ==========

  void _showAddEducationDialog({Map<String, dynamic>? education, int? index}) {
    final schoolController = TextEditingController(
      text: education?['school'] ?? '',
    );
    final degreeController = TextEditingController(
      text: education?['degree'] ?? '',
    );
    final fieldController = TextEditingController(
      text: education?['field'] ?? '',
    );
    final gradeController = TextEditingController(
      text: education?['grade'] ?? '',
    );
    final locationController = TextEditingController(
      text: education?['location'] ?? '',
    );

    String startMonth = education?['start_month'] ?? 'January';
    String startYear =
        education?['start_year'] ?? DateTime.now().year.toString();
    String endMonth = education?['end_month'] ?? 'January';
    String endYear = education?['end_year'] ?? DateTime.now().year.toString();

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
      (i) => (DateTime.now().year - i).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(education == null ? 'Add Education' : 'Edit Education'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: schoolController,
                  decoration: const InputDecoration(
                    labelText: 'School/University *',
                    hintText: 'Enter you University',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., Gurugram, Haryana',
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
                          isExpanded: true, 

                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                        ),
                        items: months
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m,overflow: TextOverflow.ellipsis,)),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => startMonth = v!),
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
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => startYear = v!),
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
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => endMonth = v!),
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
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() => endYear = v!),
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
                  final educationData = {
                    'school': schoolController.text,
                    'degree': degreeController.text,
                    'field': fieldController.text,
                    'start_month': startMonth,
                    'start_year': startYear,
                    'end_month': endMonth,
                    'end_year': endYear,
                    'grade': gradeController.text,
                    'location': locationController.text,
                  };

                  if (index != null) {
                    _educationList[index] = educationData;
                  } else {
                    _educationList.add(educationData);
                  }
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
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
            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
            onPressed: () =>
                _showAddEducationDialog(education: education, index: index),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => setState(() => _educationList.removeAt(index)),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 18 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid age (18-100)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final controller = context.read<CandidateController>();

    /// ---------------- WORK EXPERIENCE JSON ----------------
    String? workExperienceJson;

    if (_workExperiences.isNotEmpty) {
      workExperienceJson = jsonEncode(
        _workExperiences.map((exp) {
          return {
            'company_name': exp['company_name'],
            'role_title': exp['role_title'], 

            'location': exp['location'],
            'description': exp['description'],
            'ctc': exp['ctc'],  

            'start_month': exp['start_month'],
            'start_year': exp['start_year'],
            'end_month': exp['is_current'] ? null : exp['end_month'],
            'end_year': exp['is_current'] ? null : exp['end_year'],
            'is_current': exp['is_current'],
          };
        }).toList(),
      );
    }

    /// ---------------- EDUCATION JSON ----------------
    String? educationJson;

    if (_educationList.isNotEmpty) {
      educationJson = jsonEncode(
        _educationList.map((edu) {
          return {
            'school': edu['school'],
            'degree': edu['degree'],
            'field': edu['field'],
            'start_month': edu['start_month'],
            'start_year': edu['start_year'],
            'end_month': edu['end_month'],
            'end_year': edu['end_year'],
            'grade': edu['grade'],
            'location': edu['location'],
          };
        }).toList(),
      );
    }

    final String fullName =
        '${firstNameController.text.trim()} ${lastNameController.text.trim()}';

    /// ---------------- API CALL ----------------
    final success = await controller.updateProfile(
      fullName: fullName, // Use the combined fullName

      phone: _phoneController.text,
      age: age,
      role: _selectedRole,
      // experienceYears: int.tryParse(_experienceController.text),
      currentCtc: _currentCtcController.text.isEmpty
          ? null
          : double.tryParse(_currentCtcController.text),
      expectedCtc: _expectedCtcController.text.isEmpty
          ? null
          : double.tryParse(_expectedCtcController.text),
      religion: _selectedReligion,
      state: _stateController.text,
      city: _cityController.text,
      education: educationJson,
      skills: _skillsController.text,
      resumeFile: _resumeFile,
      videoIntroFile: _videoIntroFile,
      profileImage: _profileImage,
      languages: _languagesController.text.isEmpty
          ? null
          : _languagesController.text,
      streetAddress: _streetAddressController.text.isEmpty
          ? null
          : _streetAddressController.text,
      willingToRelocate: _willingToRelocate,
      workExperience: workExperienceJson,
      careerObjective: _careerObjectiveController.text.isEmpty
          ? null
          : _careerObjectiveController.text,
    );

    /// ---------------- RESPONSE ----------------
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.primary,
        ),
      );
      Navigator.pop(context, true);
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
        backgroundColor: AppTheme.primary,
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
                  // Profile Picture Section
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
                                    color: AppTheme.primary,
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
                                    : widget.profileData['profile_image_url'] !=
                                          null
                                    ? ClipOval(
                                        child: Image.network(
                                          widget
                                              .profileData['profile_image_url'],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
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
                                    color: AppTheme.primary,
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

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: firstNameController,
                          icon: Icons.person,

                          label: 'First Name',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: lastNameController,
                          icon: Icons.person,
                          label: 'Last Name',
                        ),
                      ),
                    ],
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
                      if (value!.length != 10)
                        return 'Enter valid 10-digit number';
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
                      // const SizedBox(width: 16),
                      // Expanded(
                      //   child: _buildTextField(
                      //     controller: _experienceController,
                      //     label: 'Experience (Years)',
                      //     icon: Icons.work_history,
                      //     isRequired: true,
                      //     keyboardType: TextInputType.number,
                      //     validator: (value) => value?.isEmpty == true
                      //         ? 'Experience is required'
                      //         : null,
                      //   ),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _loadingOptions
                      ? _buildLoadingField('Loading roles...')
                      : _buildDropdownField(
                          value: _selectedRole,
                          label: 'Role/Department',
                          icon: Icons.business_center,
                          items: _roles,
                          onChanged: (value) =>
                              setState(() => _selectedRole = value!),
                        ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Additional Information'),
                  const SizedBox(height: 16),

                  // Languages
                  _buildTextField(
                    controller: _languagesController,
                    label: 'Languages',
                    icon: Icons.language,
                    hintText: 'e.g., Hindi, English, Punjabi (comma separated)',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Street Address
                  _buildTextField(
                    controller: _streetAddressController,
                    label: 'Street Address',
                    icon: Icons.home,
                    hintText: 'House no., Street, Area',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  // Career Objective
                  _buildTextField(
                    controller: _careerObjectiveController,
                    label: 'Career Objective',
                    icon: Icons.flag,
                    hintText: 'Describe your career goals...',
                    maxLines: 2,
                  ),

                  const SizedBox(height: 20),

                  // Work Experience Section
                  _buildSectionTitle('Work Experience'),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add at least one work experience (Required)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
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
                  const SizedBox(height: 6),

                  // Display Work Experiences
                  ...(_workExperiences.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> exp = entry.value;
                    return _buildExperienceCard(exp, index);
                  }).toList()),

                  const SizedBox(height: 6),

                  // Education Section
                  _buildSectionTitle('Education'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add at least one educational qualification (Required)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
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
                  const SizedBox(height: 10),

                  // Display Education Cards
                  ...(_educationList.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> edu = entry.value;
                    return _buildEducationDisplayCard(edu, index);
                  }).toList()),

                  const SizedBox(height: 24),

                  // Professional Information Section
                  _buildSectionTitle('Professional Information'),
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
                  _buildSectionTitle(' Location'),
                  const SizedBox(height: 16),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildTextField(
                  //         controller: _currentCtcController,
                  //         label: 'Current CTC',
                  //         icon: Icons.currency_rupee,
                  //         keyboardType: TextInputType.number,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: _buildTextField(
                  //         controller: _expectedCtcController,
                  //         label: 'Expected CTC',
                  //         icon: Icons.trending_up,
                  //         keyboardType: TextInputType.number,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.location_on,
                          isRequired: true,
                          validator: (value) => value?.isEmpty == true
                              ? 'State is required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city,
                          isRequired: true,
                          validator: (value) => value?.isEmpty == true
                              ? 'City is required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _loadingOptions
                      ? _buildLoadingField('Loading religions...')
                      : _buildDropdownField(
                          value: _selectedReligion,
                          label: 'Religion ',
                          icon: Icons.account_circle,
                          items: _religions,
                          onChanged: (value) =>
                              setState(() => _selectedReligion = value!),
                        ),

                  const SizedBox(height: 24),

                  // Documents Section
                  _buildSectionTitle('Documents'),
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
                              ? AppTheme.primary
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
                            _resumeFile != null
                                ? Icons.refresh
                                : Icons.upload_file,
                          ),
                          label: Text(
                            _resumeFile != null ? 'Change File' : 'Choose File',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Video Intro Upload Section
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
                              ? AppTheme.primary
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
                            _videoIntroFile != null
                                ? Icons.refresh
                                : Icons.upload_file,
                          ),
                          label: Text(
                            _videoIntroFile != null
                                ? 'Change Video'
                                : 'Choose Video',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
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
                        backgroundColor: AppTheme.primary,
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
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
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
          isExpanded: true,
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
              child: Text(item['label']!,
              overflow: TextOverflow.ellipsis,
              ),
              
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
