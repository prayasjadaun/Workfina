import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/controllers/recuriter_controller.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class RecruiterProfileScreen extends StatefulWidget {
  const RecruiterProfileScreen({super.key});

  @override
  State<RecruiterProfileScreen> createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends State<RecruiterProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _companyNameController;
  late TextEditingController _designationController;
  late TextEditingController _phoneController;
  late TextEditingController _companyWebsiteController;
  String? _selectedCompanySize;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _companyNameController = TextEditingController();
    _designationController = TextEditingController();
    _phoneController = TextEditingController();
    _companyWebsiteController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyNameController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _companyWebsiteController.dispose();
    super.dispose();
  }

  void _initializeControllers(Map<String, dynamic> profile) {
    _fullNameController.text = profile['full_name'] ?? '';
    _companyNameController.text = profile['company_name'] ?? '';
    _designationController.text = profile['designation'] ?? '';
    _phoneController.text = profile['phone'] ?? '';
    _companyWebsiteController.text = profile['company_website'] ?? '';
    _selectedCompanySize = profile['company_size'];
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ApiService.updateRecruiterProfile(
      fullName: _fullNameController.text,
      companyName: _companyNameController.text,
      designation: _designationController.text,
      phone: _phoneController.text,
      companyWebsite: _companyWebsiteController.text.isEmpty
          ? null
          : _companyWebsiteController.text,
      companySize: _selectedCompanySize,
    );

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    } else {
      setState(() => _isEditing = false);
      await context.read<RecruiterController>().loadHRProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: double.infinity,
        color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        child: Consumer<RecruiterController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              );
            }
      
            final profile = controller.hrProfile;
            if (profile == null) {
              return Center(
                child: Text(
                  'No profile data',
                  style: AppTheme.getBodyStyle(context),
                ),
              );
            }
      
            if (_fullNameController.text.isEmpty) {
              _initializeControllers(profile);
            }
      
            return _isEditing
                ? _buildEditForm(profile, isDark)
                : _buildProfileView(profile, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildProfileView(Map<String, dynamic> profile, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black26 
                    : Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (profile['full_name'] ?? 'R').substring(0, 1).toUpperCase(),
                      style: AppTheme.getHeadlineStyle(
                        context,
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name and Email
                Text(
                  profile['full_name'] ?? 'N/A',
                  style: AppTheme.getTitleStyle(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile['email'] ?? 'N/A',
                  style: AppTheme.getSubtitleStyle(
                    context,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Verified Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      SvgPicture.asset(
                        'assets/svgs/check.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppTheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Verified',
                        style: AppTheme.getLabelStyle(
                          context,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Profile Details Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black26 
                    : Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with Edit Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Details',
                        style: AppTheme.getTitleStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isEditing = true),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SvgPicture.asset(
                            'assets/svgs/edit.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Profile Information
                _buildProfileInfoItem(
                  svgPath: 'assets/svgs/company.svg',
                  title: 'Company Name',
                  value: profile['company_name'] ?? 'N/A',
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildProfileInfoItem(
                  svgPath: 'assets/svgs/badge1.svg',
                  title: 'Designation',
                  value: profile['designation'] ?? 'N/A',
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildProfileInfoItem(
                  svgPath: 'assets/svgs/phone.svg',
                  title: 'Phone',
                  value: profile['phone'] ?? 'N/A',
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildProfileInfoItem(
                  svgPath: 'assets/svgs/web.svg',
                  title: 'Company Website',
                  value: profile['company_website'] ?? 'Not provided',
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildProfileInfoItem(
                  svgPath: 'assets/svgs/users.svg',
                  title: 'Company Size',
                  value: profile['company_size'] ?? 'N/A',
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Logout Card
          Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Colors.black26 
                      : Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _showLogoutDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildProfileInfoItem(
                    svgPath: 'assets/svgs/logout.svg',
                    title: 'Log Out',
                    value: 'Log out from your account',
                    isDark: isDark,
                    isLast: true,
                    titleColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required String svgPath,
    required String title,
    required String value,
    required bool isDark,
    bool isLast = false,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: isLast ? 20 : 16,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgPath,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? AppTheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getBodyStyle(
                      context,
                      color: titleColor ?? (isDark ? Colors.white : Colors.black87),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTheme.getSubtitleStyle(
                      context,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
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

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
    );
  }

  Widget _buildEditForm(Map<String, dynamic> profile, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.black26 
                : Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: AppTheme.getTitleStyle(
                  context,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                isDark: isDark,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _companyNameController,
                label: 'Company Name',
                isDark: isDark,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _designationController,
                label: 'Designation',
                isDark: isDark,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                isDark: isDark,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _companyWebsiteController,
                label: 'Company Website (Optional)',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              
              _buildDropdown(isDark),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTheme.getBodyStyle(
                          context,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: AppTheme.getBodyStyle(
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTheme.getBodyStyle(context),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.getSubtitleStyle(
          context,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: isRequired 
        ? (v) => v?.isEmpty ?? true ? 'This field is required' : null
        : null,
    );
  }

  Widget _buildDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedCompanySize,
      style: AppTheme.getBodyStyle(context),
      decoration: InputDecoration(
        labelText: 'Company Size',
        labelStyle: AppTheme.getSubtitleStyle(
          context,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dropdownColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      items: const [
        DropdownMenuItem(value: '1-10', child: Text('1-10 employees')),
        DropdownMenuItem(value: '11-50', child: Text('11-50 employees')),
        DropdownMenuItem(value: '51-200', child: Text('51-200 employees')),
        DropdownMenuItem(value: '201-1000', child: Text('201-1000 employees')),
        DropdownMenuItem(value: '1000+', child: Text('1000+ employees')),
      ],
      onChanged: (v) => setState(() => _selectedCompanySize = v),
      validator: (v) => v == null ? 'Please select company size' : null,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: AppTheme.getTitleStyle(context, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTheme.getBodyStyle(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.getBodyStyle(
                context,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              await context.read<AuthController>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/email',
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: AppTheme.getBodyStyle(
                context,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}