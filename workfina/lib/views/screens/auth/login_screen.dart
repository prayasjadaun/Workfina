import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final email = _emailController.text;
    final password = _passwordController.text;
    final isValid = email.trim().isNotEmpty && password.length >= 6;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'WorkFina',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Title
                    Text('Welcome Back!', style: AppTheme.getAuthTitleStyle(context)),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Login to continue your journey',
                      style: AppTheme.getAuthSubtitleStyle(context),
                    ),
                    const SizedBox(height: 40),

                    // Email Input Label
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getTextTertiaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getInputFillColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: AppTheme.getInputTextStyle(context),
                        decoration: AppTheme.getAuthInputDecoration(
                          context,
                          hintText: 'example@email.com',
                          prefixIcon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Input Label
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getTextTertiaryColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getInputFillColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        style: AppTheme.getInputTextStyle(context),
                        onFieldSubmitted: (_) async {
                          if (_isFormValid) {
                            FocusScope.of(context).unfocus();
                            final authController = Provider.of<AuthController>(context, listen: false);
                            if (!authController.isLoading) {
                              _handleLogin(authController);
                            }
                          }
                        },
                        decoration: AppTheme.getAuthInputDecoration(
                          context,
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.getInputIconColor(context),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your password';
                          }
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    Consumer<AuthController>(
                      builder: (context, authController, child) {
                        if (authController.error != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && authController.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authController.error!),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              authController.clearError();
                            }
                          });
                        }

                        final isButtonEnabled = _isFormValid && !authController.isLoading;

                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isButtonEnabled ? () => _handleLogin(authController) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isButtonEnabled ? AppTheme.blue : Colors.grey[300],
                              disabledBackgroundColor: Colors.grey[300],
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.grey[600],
                              elevation: isButtonEnabled ? 2 : 0,
                              shadowColor: isButtonEnabled ? AppTheme.primary.withOpacity(0.3) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authController.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isButtonEnabled ? Colors.white : Colors.grey[600],
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Divider with OR
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppTheme.getDividerColor(context), thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.getTextSecondaryColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: AppTheme.getDividerColor(context), thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.getTextTertiaryColor(context),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/email'),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthController authController) async {
    if (_formKey.currentState!.validate()) {
      final success = await authController.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!success && mounted) {
        // Clear password field on login failure
        _passwordController.clear();
      }

      if (success && mounted) {
        final userRole = authController.user?['role'];

        if (userRole == 'candidate') {
          final profile = await ApiService.getCandidateProfile();

          if (profile.containsKey('error') || profile['is_profile_completed'] == false) {
            Navigator.pushNamedAndRemoveUntil(context, '/candidate-setup', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/candidate-home', (route) => false);
          }
        } else if (userRole == 'hr') {
          final hrProfile = await ApiService.getRecruiterProfile();

          bool isProfileComplete = false;
          if (!hrProfile.containsKey('error')) {
            final companyName = hrProfile['company_name']?.toString() ?? '';
            final designation = hrProfile['designation']?.toString() ?? '';
            final phone = hrProfile['phone']?.toString() ?? '';
            isProfileComplete = companyName.isNotEmpty && designation.isNotEmpty && phone.isNotEmpty;
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            isProfileComplete ? '/hr-home' : '/hr-setup',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
        }
      }
    }
  }
}
