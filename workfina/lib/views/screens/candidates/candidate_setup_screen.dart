import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'package:workfina/theme/app_theme.dart';
import 'dart:io';

class CandidateSetupScreen extends StatefulWidget {
  const CandidateSetupScreen({super.key});

  @override
  State<CandidateSetupScreen> createState() =>
      _CandidateSetupScreenSwipeableState();
}

class _CandidateSetupScreenSwipeableState
    extends State<CandidateSetupScreen> {
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

  String _selectedRole = 'IT';
  String _selectedReligion = 'PREFER_NOT_TO_SAY';
  File? _resumeFile;
  String? _resumeFileName;
  File? _videoIntroFile;
  String? _videoIntroFileName;

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
      // Personal Information
      return _fullNameController.text.isNotEmpty &&
          _phoneController.text.length == 10 &&
          _ageController.text.isNotEmpty &&
          _experienceController.text.isNotEmpty;
    case 1:
      // Professional Information - Check graduation (required) and skills
      final controller = Provider.of<CandidateController>(context, listen: false);
      return controller.graduationController.text.isNotEmpty &&
          controller.graduationUniversityController.text.isNotEmpty &&
          controller.graduationYearController.text.isNotEmpty &&
          _skillsController.text.isNotEmpty;
    case 2:
      // Compensation & Location
      return _stateController.text.isNotEmpty &&
          _cityController.text.isNotEmpty;
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

  Future<void> _submitProfile() async {
    final controller = context.read<CandidateController>();

    final success = await controller.registerCandidate(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      age: int.parse(_ageController.text),
      role: _selectedRole,
      experienceYears: int.parse(_experienceController.text),
      currentCtc: _currentCtcController.text.isEmpty
          ? null
          : double.parse(_currentCtcController.text),
      expectedCtc: _expectedCtcController.text.isEmpty
          ? null
          : double.parse(_expectedCtcController.text),
      religion: _selectedReligion,
      state: _stateController.text,
      city: _cityController.text,
      education: _educationController.text,
      skills: _skillsController.text,
      resumeFile: _resumeFile,
      videoIntroFile: _videoIntroFile,
    );

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/candidate-home',
        (route) => false,
      );
    } else if (controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error!),
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
              physics: const NeverScrollableScrollPhysics(), // Disable manual swipe
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPersonalInfoPage(),
                _buildProfessionalInfoPage(),
                _buildLocationPage(),
                _buildDocumentsPage(),
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
                '${((_currentPage + 1) / 4 * 100).toInt()}% Complete',
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
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
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
                            _currentPage < 3 ? 'Continue' : 'Submit Profile',
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
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _experienceController,
                  label: 'Experience (Years)',
                  icon: Icons.work_history,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
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
          _buildPageHeader(
            icon: Icons.work_outline,
            title: 'Professional Information',
            subtitle: 'Your career details',
          ),
          const SizedBox(height: 32),
          _buildDropdownField(
            value: _selectedRole,
            label: 'Role/Department',
            icon: Icons.business_center,
            items: _roles,
            onChanged: (value) => setState(() => _selectedRole = value!),
          ),
          const SizedBox(height: 20),
          // Education Section Header
const SizedBox(height: 24),

Row(
  children: [
    const Icon(Icons.school, color: AppTheme.primary, size: 20),
    const SizedBox(width: 8),
    const Text(
      'Education Details',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    ),
  ],
),
const SizedBox(height: 4),
Text(
  'Add your educational qualifications',
  style: TextStyle(
    fontSize: 13,
    color: Colors.grey[600],
  ),
),

const SizedBox(height: 16),

// 10th Standard
_buildEducationCard(
  controller: controller,
  title: '10th Standard',
  subtitle: controller.showClass10 ? 'Click to collapse' : 'Click to add details',
  icon: Icons.school_outlined,
  isExpanded: controller.showClass10,
  hasData: controller.hasClass10Data(),
  onTap: () => controller.toggleClass10(),
  children: [
    _buildTextField(
      controller: controller.class10Controller,
      label: 'School Name',
      icon: Icons.location_city,
      hintText: 'e.g., ABC High School',
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller.class10BoardController,
            label: 'Board',
            icon: Icons.corporate_fare,
            hintText: 'CBSE/ICSE/State',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: controller.class10YearController,
            label: 'Year',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            hintText: '2020',
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    _buildTextField(
      controller: controller.class10PercentageController,
      label: 'Percentage/CGPA',
      icon: Icons.grade,
      keyboardType: TextInputType.number,
      hintText: 'e.g., 85.5',
    ),
  ],
),

const SizedBox(height: 12),

// 12th Standard
_buildEducationCard(
  controller: controller,
  title: '12th Standard / Diploma',
  subtitle: controller.showClass12 ? 'Click to collapse' : 'Click to add details',
  icon: Icons.school_outlined,
  isExpanded: controller.showClass12,
  hasData: controller.hasClass12Data(),
  onTap: () => controller.toggleClass12(),
  children: [
    _buildTextField(
      controller: controller.class12Controller,
      label: 'School/College Name',
      icon: Icons.location_city,
      hintText: 'e.g., XYZ Senior Secondary School',
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller.class12BoardController,
            label: 'Board/Stream',
            icon: Icons.corporate_fare,
            hintText: 'Science/Commerce/Arts',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: controller.class12YearController,
            label: 'Year',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            hintText: '2022',
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    _buildTextField(
      controller: controller.class12PercentageController,
      label: 'Percentage/CGPA',
      icon: Icons.grade,
      keyboardType: TextInputType.number,
      hintText: 'e.g., 90.2',
    ),
  ],
),

const SizedBox(height: 12),

// Graduation (Required)
_buildEducationCard(
  controller: controller,
  title: 'Graduation (Bachelor\'s Degree)',
  subtitle: controller.showGraduation ? 'Click to collapse' : 'Click to add details',
  icon: Icons.school,
  isExpanded: controller.showGraduation,
  hasData: controller.hasGraduationData(),
  isRequired: true,
  onTap: () => controller.toggleGraduation(),
  children: [
    _buildTextField(
      controller: controller.graduationController,
      label: 'Degree',
      icon: Icons.workspace_premium,
      hintText: 'e.g., B.Tech Computer Science',
      isRequired: true,
    ),
    const SizedBox(height: 16),
    _buildTextField(
      controller: controller.graduationUniversityController,
      label: 'University/College',
      icon: Icons.account_balance,
      hintText: 'e.g., Delhi University',
      isRequired: true,
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller.graduationYearController,
            label: 'Year of Passing',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            hintText: '2024',
            isRequired: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: controller.graduationPercentageController,
            label: 'Percentage/CGPA',
            icon: Icons.grade,
            keyboardType: TextInputType.number,
            hintText: 'e.g., 8.5',
          ),
        ),
      ],
    ),
  ],
),

const SizedBox(height: 12),

// Post Graduation
_buildEducationCard(
  controller: controller,
  title: 'Post Graduation (Master\'s Degree)',
  subtitle: controller.showPostGraduation ? 'Click to collapse' : 'Click to add details (Optional)',
  icon: Icons.school,
  isExpanded: controller.showPostGraduation,
  hasData: controller.hasPostGraduationData(),
  onTap: () => controller.togglePostGraduation(),
  children: [
    _buildTextField(
      controller: controller.postGraduationController,
      label: 'Degree',
      icon: Icons.workspace_premium,
      hintText: 'e.g., M.Tech, MBA, MCA',
    ),
    const SizedBox(height: 16),
    _buildTextField(
      controller: controller.postGraduationUniversityController,
      label: 'University/College',
      icon: Icons.account_balance,
      hintText: 'e.g., IIT Delhi',
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller.postGraduationYearController,
            label: 'Year of Passing',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            hintText: '2026 or Pursuing',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: controller.postGraduationPercentageController,
            label: 'Percentage/CGPA',
            icon: Icons.grade,
            keyboardType: TextInputType.number,
            hintText: 'e.g., 9.0',
          ),
        ),
      ],
    ),
  ],
),

const SizedBox(height: 12),

// Other Certifications
_buildEducationCard(
  controller: controller,
  title: 'Other Certifications / Courses',
  subtitle: controller.showOtherEducation ? 'Click to collapse' : 'Click to add additional qualifications',
  icon: Icons.card_membership,
  isExpanded: controller.showOtherEducation,
  hasData: controller.hasOtherEducationData(),
  onTap: () => controller.toggleOtherEducation(),
  children: [
    _buildTextField(
      controller: controller.otherEducationController,
      label: 'Additional Qualifications',
      icon: Icons.emoji_events,
      maxLines: 4,
      hintText: 'e.g., AWS Certified, Google Analytics, Python Bootcamp',
    ),
  ],
),

const SizedBox(height: 32),

// Skills Header
Row(
  children: [
    const Icon(Icons.psychology, color: AppTheme.primary, size: 20),
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
          const SizedBox(height: 20),
          _buildTextField(
            controller: _skillsController,
            label: 'Skills',
            icon: Icons.psychology,
            isRequired: true,
            maxLines: 4,
            hintText: 'e.g., Python, Django, React (comma separated)',
          ),
        ],
      ),
    );
    },
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
                  label: 'Current CTC (₹)',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  hintText: 'Annual package',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _expectedCtcController,
                  label: 'Expected CTC (₹)',
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
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 32,
          ),
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
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
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
    super.dispose();
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
            child: Column(
              children: children,
            ),
          ),
      ],
    ),
  );
}
}