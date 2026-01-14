import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/theme/app_theme.dart';

class RecruiterSetupScreen extends StatefulWidget {
  const RecruiterSetupScreen({super.key});

  @override
  State<RecruiterSetupScreen> createState() => _RecruiterSetupScreenState();
}

class _RecruiterSetupScreenState extends State<RecruiterSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Form keys for each step
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  String _selectedCompanySize = '1-10';

  final List<Map<String, String>> _companySizes = [
    {'value': '1-10', 'label': '1-10 employees'},
    {'value': '11-50', 'label': '11-50 employees'},
    {'value': '51-200', 'label': '51-200 employees'},
    {'value': '201-1000', 'label': '201-1000 employees'},
    {'value': '1000+', 'label': '1000+ employees'},
  ];

  void _nextStep() {
    FocusScope.of(context).unfocus();
    final currentFormKey = _getCurrentFormKey();
    if (currentFormKey?.currentState?.validate() ?? false) {
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
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecruiterController(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Company Setup',
            style: AppTheme.getHeadlineStyle(context, fontSize: 18),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.getTextPrimaryColor(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildProgressHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
                ),
              ),
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
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        boxShadow: [AppTheme.getCardShadow(context)],
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
                              ? AppTheme.blue
                              : AppTheme.getDividerColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isActive
                              ? AppTheme.blue
                              : AppTheme.getDividerColor(context),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppTheme.getLabelStyle(
                                    context,
                                    color: isActive
                                        ? Colors.white
                                        : AppTheme.getTextSecondaryColor(
                                            context,
                                          ),
                                    fontWeight: FontWeight.w600,
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
            style: AppTheme.getSubtitleStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepContainer(
      title: 'Company Information',
      description: 'Tell us about your company',
      icon: Icons.business_outlined,
      child: Form(
        key: _step1FormKey,
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              isRequired: true,
              hintText: 'Full Name',
              validator: (value) =>
                  value?.isEmpty == true ? 'Full name is required' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _companyNameController,
              label: 'Company Name',
              icon: Icons.business_outlined,
              isRequired: true,
              hintText: 'e.g., TechCorp Solutions',
              validator: (value) =>
                  value?.isEmpty == true ? 'Company name is required' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _designationController,
              label: 'Your Designation',
              icon: Icons.person_pin_outlined,
              isRequired: true,
              hintText: 'e.g., HR Manager, Talent Acquisition Lead',
              validator: (value) =>
                  value?.isEmpty == true ? 'Designation is required' : null,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              value: _selectedCompanySize,
              label: 'Company Size',
              icon: Icons.groups_outlined,
              items: _companySizes,
              onChanged: (value) =>
                  setState(() => _selectedCompanySize = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      title: 'Contact Details',
      description: 'How can candidates reach you?',
      icon: Icons.contact_phone_outlined,
      child: Form(
        key: _step2FormKey,
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              isRequired: true,
              keyboardType: TextInputType.number,
              maxLength: 10,
              hintText: '9876543210',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value?.isEmpty == true) return 'Phone number is required';
                if (value!.length != 10) return 'Enter a valid 10-digit number';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _websiteController,
              label: 'Company Website',
              icon: Icons.web_outlined,
              hintText: 'yourcompany.com',
              prefixText: 'https://',
              isRequired: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onDone: _nextStep,
              validator: (value) {
                if (value?.isEmpty == true)
                  return 'Company website is required';
                final urlPattern = RegExp(
                  r'^[a-zA-Z0-9][a-zA-Z0-9-]*\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?(/.*)?$',
                );
                if (!urlPattern.hasMatch(value!))
                  return 'Enter a valid URL (e.g., yourcompany.com)';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      title: 'Review & Complete',
      description: 'Verify your company information',
      icon: Icons.verified_outlined,
      child: Form(
        key: _step3FormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildReviewCard('Company Details', [
                'Name: ${_fullNameController.text}',
                'Company: ${_companyNameController.text}',
                'Designation: ${_designationController.text}',
                'Size: ${_companySizes.firstWhere((s) => s['value'] == _selectedCompanySize)['label']}',
              ]),
              const SizedBox(height: 16),
              _buildReviewCard('Contact Information', [
                'Phone: ${_phoneController.text}',
                if (_websiteController.text.isNotEmpty)
                  'Website: https://${_websiteController.text}',
              ]),
              const SizedBox(height: 24),
              _buildInfoCard(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppTheme.getCardShadow(context)],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTheme.getHeadlineStyle(context, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTheme.getSubtitleStyle(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          child,
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
    String? prefixText,
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
      textInputAction: textInputAction,
      onFieldSubmitted: (_) {
        if (textInputAction == TextInputAction.done) {
          FocusScope.of(context).unfocus();
          onDone?.call();
        }
      },
      style: AppTheme.getBodyStyle(context),
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: hintText,
        prefixText: prefixText,
        labelStyle: AppTheme.getLabelStyle(context),
        hintStyle: AppTheme.getSubtitleStyle(context),
        prefixIcon: Icon(icon, color: AppTheme.getInputIconColor(context)),
        filled: true,
        fillColor: AppTheme.getCardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getDividerColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getDividerColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
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
      style: AppTheme.getBodyStyle(context),
      dropdownColor: AppTheme.getCardColor(context),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.getLabelStyle(context),
        prefixIcon: Icon(icon, color: AppTheme.getInputIconColor(context)),
        filled: true,
        fillColor: AppTheme.getCardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getDividerColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getDividerColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item['value'],
              child: Text(
                item['label']!,
                style: AppTheme.getBodyStyle(context),
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
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getDividerColor(context)),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.getTitleStyle(context, fontSize: 16)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item, style: AppTheme.getBodyStyle(context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'What happens next?',
                style: AppTheme.getTitleStyle(context, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '• Your company profile will be reviewed within 24 hours\n'
            '• Once approved, you\'ll receive credits to unlock candidate profiles\n'
            '• Start browsing our talent pool immediately after setup',
            style: AppTheme.getBodyStyle(
              context,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getInputFillColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: AppTheme.getInputIconColor(context),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By completing setup, you agree to our terms of service and privacy policy.',
                    style: AppTheme.getSubtitleStyle(context, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppTheme.getDividerColor(context)),
                ),
                child: Text(
                  'Previous',
                  style: AppTheme.getBodyStyle(
                    context,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Consumer<RecruiterController>(
              builder: (context, hrController, child) {
                return ElevatedButton(
                  onPressed: hrController.isLoading
                      ? null
                      : () {
                          if (_currentStep == _totalSteps - 1) {
                            _submitProfile(hrController);
                          } else {
                            _nextStep();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: hrController.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentStep == _totalSteps - 1
                              ? 'Complete Setup'
                              : 'Continue',
                          style: AppTheme.getPrimaryButtonTextStyle(context),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfile(RecruiterController hrController) async {
    // Prepend https:// to the website URL if not empty
    String? websiteUrl;
    if (_websiteController.text.isNotEmpty) {
      websiteUrl = 'https://${_websiteController.text}';
    }

    final success = await hrController.registerHR(
      fullName: _fullNameController.text,
      companyName: _companyNameController.text,
      designation: _designationController.text,
      phone: _phoneController.text,
      companyWebsite: websiteUrl,
      companySize: _selectedCompanySize,
    );

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/hr-home', (route) => false);
    } else if (hrController.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hrController.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _pageController.dispose();
    _companyNameController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
