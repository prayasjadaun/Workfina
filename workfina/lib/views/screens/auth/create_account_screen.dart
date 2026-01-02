import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/theme/app_theme.dart';

class UsernameTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove spaces and convert to lowercase
    final filteredText = newValue.text.replaceAll(' ', '').toLowerCase();

    return newValue.copyWith(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus(); // ✅ keyboard close
        },
        child: Container(
          height: double.infinity,
          decoration: AppTheme.getGradientDecoration(context),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.person_add_outlined,
                        size: 80,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Create Your Account',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Setup your profile to get started',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _usernameController,

                        textInputAction: TextInputAction.next, // ✅ NEXT

                        inputFormatters: [
                          UsernameTextInputFormatter(),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-z0-9_.]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your username';
                          }
                          if (value!.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,

                        textInputAction: TextInputAction.next, // ✅ NEXT

                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
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

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,

                        textInputAction: TextInputAction.done, // ✅ DONE

                        onFieldSubmitted: (_) async {
                          final authController = Provider.of<AuthController>(
                            context,
                            listen: false,
                          );

                          // ✅ double submit protection
                          if (authController.isLoading) return;

                          FocusScope.of(context).unfocus(); // keyboard close

                          if (_formKey.currentState!.validate()) {
                            final success = await authController.createAccount(
                              email: authController.tempEmail!,
                              username: _usernameController.text,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                            );

                            if (success && mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/role-selection',
                                (route) => false,
                              );
                            }
                          }
                        },

                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),
                      Consumer<AuthController>(
                        builder: (context, authController, child) {
                          if (authController.error != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authController.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              authController.clearError();
                            });
                          }

                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authController.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final success = await authController
                                            .createAccount(
                                              email: authController.tempEmail!,
                                              username:
                                                  _usernameController.text,
                                              password:
                                                  _passwordController.text,
                                              confirmPassword:
                                                  _confirmPasswordController
                                                      .text,
                                            );
                                        if (success) {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/role-selection',
                                            (route) => false,
                                          );
                                        }
                                      }
                                    },
                              child: authController.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            ),
                            child: Text(
                              'Login',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
