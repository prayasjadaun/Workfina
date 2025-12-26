import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Login',
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, size: 80, color: AppTheme.primaryGreen),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to your account',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) async {
                        final authController = Provider.of<AuthController>(
                          context,
                          listen: false,
                        );
                        if (authController.isLoading) return;
                        FocusScope.of(context).unfocus(); // keyboard close
                        if (_formKey.currentState!.validate()) {
                          final authController = Provider.of<AuthController>(
                            context,
                            listen: false,
                          );

                          final success = await authController.login(
                            _emailController.text,
                            _passwordController.text,
                          );

                          if (success && mounted) {
                            final userRole = authController.user?['role'];

                            if (userRole == 'candidate') {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/candidate-home',
                                (route) => false,
                              );
                            } else if (userRole == 'hr') {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/hr-home',
                                (route) => false,
                              );
                            } else {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/role-selection',
                                (route) => false,
                              );
                            }
                          }
                        }
                      },

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
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    Consumer<AuthController>(
                      builder: (context, authController, child) {
                        if (authController.error != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && authController.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authController.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              authController.clearError();
                            }
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
                                          .login(
                                            _emailController.text,
                                            _passwordController.text,
                                          );
                                      if (success) {
                                        final userRole =
                                            authController.user?['role'];
                                        if (userRole == 'candidate') {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/candidate-home',
                                            (route) => false,
                                          );
                                        } else if (userRole == 'hr') {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/hr-home',
                                            (route) => false,
                                          );
                                        } else {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/role-selection',
                                            (route) => false,
                                          );
                                        }
                                      }
                                    }
                                  },
                            child: authController.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login',
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
                          'Don\'t have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/email'),
                          child: Text(
                            'Sign Up',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.primaryGreen,
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
    );
  }
}
