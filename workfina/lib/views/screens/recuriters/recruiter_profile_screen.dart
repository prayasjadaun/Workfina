import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['error'])));
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
    return Container(
      height: double.infinity,
      decoration: AppTheme.getGradientDecoration(context),
      child: Consumer<RecruiterController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = controller.hrProfile;
          if (profile == null) {
            return const Center(child: Text('No profile data'));
          }

          if (_fullNameController.text.isEmpty) {
            _initializeControllers(profile);
          }

          return _isEditing
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildEditForm(profile),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppTheme.primaryGreen,
                                  child: Text(
                                    profile['full_name']?.substring(0, 1) ??
                                        'R',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile['full_name'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile['email'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Account Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Account',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _isEditing = true),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 4,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 24),

                              _buildMenuItem(
                                icon: Icons.business_outlined,
                                title: 'Company Details',
                                subtitle: profile['company_name'] ?? 'N/A',
                                onTap: () {},
                              ),
                              _buildMenuItem(
                                icon: Icons.badge_outlined,
                                title: 'Designation',
                                subtitle: profile['designation'] ?? 'N/A',
                                onTap: () {},
                              ),
                              _buildMenuItem(
                                icon: Icons.phone_outlined,
                                title: 'Phone',
                                subtitle: profile['phone'] ?? 'N/A',
                                onTap: () {},
                              ),
                              _buildMenuItem(
                                icon: Icons.language_outlined,
                                title: 'Company Website',
                                subtitle:
                                    profile['company_website'] ??
                                    'Not provided',
                                onTap: () {},
                              ),
                              _buildMenuItem(
                                icon: Icons.people_outline,
                                title: 'Company Size',
                                subtitle: profile['company_size'] ?? 'N/A',
                                onTap: () {},
                              ),

                              // const SizedBox(height: 32),

                              // _buildMenuItem(
                              //   icon: Icons.settings_outlined,
                              //   title: 'Settings',
                              //   subtitle: 'Privacy & preferences',
                              //   onTap: () {},
                              // ),
                              // _buildMenuItem(
                              //   icon: Icons.support_agent_outlined,
                              //   title: 'Support',
                              //   subtitle: 'Get assistance',
                              //   onTap: () {},
                              // ),

                              const SizedBox(height: 16),

                              _buildMenuItem(
                                icon: Icons.logout,
                                iconColor: Colors.red,
                                title: 'Log Out',
                                titleColor: Colors.red,
                                subtitle: 'Log out from your account',
                                onTap: () => _showLogoutDialog(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryGreen,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        // trailing: Icon(
        //   Icons.arrow_forward_ios,
        //   size: 16,
        //   color: Colors.grey[400],
        // ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEditForm(Map<String, dynamic> profile) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(labelText: 'Company Name'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _designationController,
            decoration: const InputDecoration(labelText: 'Designation'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyWebsiteController,
            decoration: const InputDecoration(
              labelText: 'Company Website (Optional)',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCompanySize,
            decoration: const InputDecoration(labelText: 'Company Size'),
            items: const [
              DropdownMenuItem(value: '1-10', child: Text('1-10 employees')),
              DropdownMenuItem(value: '11-50', child: Text('11-50 employees')),
              DropdownMenuItem(
                value: '51-200',
                child: Text('51-200 employees'),
              ),
              DropdownMenuItem(
                value: '201-1000',
                child: Text('201-1000 employees'),
              ),
              DropdownMenuItem(value: '1000+', child: Text('1000+ employees')),
            ],
            onChanged: (v) => setState(() => _selectedCompanySize = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<AuthController>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/email',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
