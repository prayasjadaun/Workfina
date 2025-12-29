import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/candidate_controller.dart';
import 'dart:io';

class CandidateSetupScreen extends StatefulWidget {
  const CandidateSetupScreen({super.key});

  @override
  State<CandidateSetupScreen> createState() => _CandidateSetupScreenState();
}

class _CandidateSetupScreenState extends State<CandidateSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form keys for each step
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step4FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step5FormKey = GlobalKey<FormState>();

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
  String _selectedReligion = 'HINDU';
  File? _resumeFile;
  String? _resumeFileName;

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

  void _nextStep() {
    FocusScope.of(context).unfocus();
    final currentFormKey = _getCurrentFormKey();
    if (currentFormKey?.currentState?.validate() ?? false) {
      // Check resume file on step 4 (resume upload step)
      if (_currentStep == 3 && _resumeFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your resume to continue'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  GlobalKey<FormState>? _getCurrentFormKey() {
    switch (_currentStep) {
      case 0:
        return _step1FormKey;
      case 1:
        return _step2FormKey;
      case 2:
        return _step3FormKey;
      case 3:
        return _step4FormKey;
      case 4:
        return _step5FormKey;
      default:
        return null;
    }
  }

  void _pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
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
              backgroundColor: Color(0xFFEF4444),
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
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CandidateController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Complete Your Profile',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus(); // ✅ keyboard close
          },
          child: Column(
            children: [
              // Progress Header
              _buildProgressHeader(),

              // Step Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                    _buildStep5(),
                  ],
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _totalSteps - 1 ? 8 : 0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isCompleted || isActive
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isActive
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE0E0E0),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF757575),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepContainer(
      title: 'Personal Information',
      description: 'Let\'s start with your basic details',
      icon: Icons.person_outline,
      child: Form(
        key: _step1FormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              hintText: 'Enter your full name',
              icon: Icons.person,
              isRequired: true,
              validator: (value) =>
                  value?.isEmpty == true ? 'Full name is required' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hintText: '9876543210',
              icon: Icons.phone,
              isRequired: true,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value?.isEmpty == true) return 'Phone number is required';
                if (value!.length != 10) return 'Enter a valid 10-digit number';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ageController,
                    label: 'Age',
                    hintText: '25',
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
                    hintText: '2',
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
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      title: 'Professional Details',
      description: 'Tell us about your professional background',
      icon: Icons.work_outline,
      child: Form(
        key: _step2FormKey,
        child: Column(
          children: [
            _buildDropdownField(
              value: _selectedRole,
              label: 'Role/Department',
              icon: Icons.business_center,
              items: _roles,
              onChanged: (value) => setState(() => _selectedRole = value!),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _educationController,
              label: 'Education',
              icon: Icons.school,
              isRequired: true,
              maxLines: 2,
              hintText: 'e.g., B.Tech Computer Science',
              validator: (value) =>
                  value?.isEmpty == true ? 'Education is required' : null,
            ),
            const SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      title: 'Compensation & Location',
      description: 'Share your expectations and location',
      icon: Icons.location_on_outlined,
      child: Form(
        key: _step3FormKey,
        child: Column(
          children: [
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
                    textInputAction: TextInputAction.done,
                    onDone: _nextStep,
                    validator: (value) =>
                        value?.isEmpty == true ? 'City is required' : null,
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
      ),
    );
  }

  Widget _buildStep4() {
    return _buildStepContainer(
      title: 'Resume Upload',
      description: 'Upload your resume (PDF or DOC)',
      icon: Icons.upload_file_outlined,
      child: Form(
        key: _step4FormKey,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  style: BorderStyle.solid,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF9FAFB),
              ),
              child: Column(
                children: [
                  Icon(
                    _resumeFile != null
                        ? Icons.check_circle
                        : Icons.cloud_upload_outlined,
                    size: 64,
                    color: _resumeFile != null
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _resumeFile != null ? 'Resume Uploaded' : 'Upload Resume',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resumeFileName ?? 'PDF or DOC format only',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickResumeFile,
                    icon: Icon(
                      _resumeFile != null ? Icons.refresh : Icons.upload_file,
                    ),
                    label: Text(
                      _resumeFile != null ? 'Change Resume' : 'Choose File',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Accepted formats: PDF, DOC, DOCX\nMax file size: 5MB',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5() {
    return _buildStepContainer(
      title: 'Review & Submit',
      description: 'Please review your information',
      icon: Icons.check_circle_outline,
      child: Form(
        key: _step5FormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildReviewCard('Personal Info', [
                'Name: ${_fullNameController.text}',
                'Phone: ${_phoneController.text}',
                'Age: ${_ageController.text} years',
                'Experience: ${_experienceController.text} years',
              ]),
              const SizedBox(height: 16),
              _buildReviewCard('Professional Info', [
                'Role: ${_roles.firstWhere((r) => r['value'] == _selectedRole)['label']}',
                'Education: ${_educationController.text}',
                'Skills: ${_skillsController.text}',
              ]),
              const SizedBox(height: 16),
              _buildReviewCard('Location & Compensation', [
                'Location: ${_cityController.text}, ${_stateController.text}',
                if (_currentCtcController.text.isNotEmpty)
                  'Current CTC: ₹${_currentCtcController.text}',
                if (_expectedCtcController.text.isNotEmpty)
                  'Expected CTC: ₹${_expectedCtcController.text}',
                'Religion: ${_religions.firstWhere((r) => r['value'] == _selectedReligion)['label']}',
              ]),
              const SizedBox(height: 16),
              _buildReviewCard('Resume', [
                _resumeFileName != null
                    ? 'Resume: $_resumeFileName'
                    : 'Resume: Not uploaded',
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'By submitting, you agree to our terms and conditions. Your profile will be reviewed within 24 hours.',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String description,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(child: child),
        ],
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
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onDone,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction, // ✅

      onFieldSubmitted: (_) {
        if (textInputAction == TextInputAction.done) {
          FocusScope.of(context).unfocus(); // ✅ keyboard close
          onDone?.call(); // optional submit
        }
      },
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        hintStyle: const TextStyle(color: Color(0xFF374151), fontSize: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
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
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
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
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
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
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item['value'],
              child: Text(
                item['label']!,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildReviewCard(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Consumer<CandidateController>(
              builder: (context, candidateController, child) {
                return ElevatedButton(
                  onPressed: candidateController.isLoading
                      ? null
                      : () {
                          if (_currentStep == _totalSteps - 1) {
                            _submitProfile(candidateController);
                          } else {
                            _nextStep();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: candidateController.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentStep == _totalSteps - 1
                              ? 'Submit Profile'
                              : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfile(CandidateController candidateController) async {
    final success = await candidateController.registerCandidate(
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
    );

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/candidate-home',
        (route) => false,
      );
    } else if (candidateController.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(candidateController.error!),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
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
}
