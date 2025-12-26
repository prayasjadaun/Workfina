import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/theme/app_theme.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Get Started',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
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
                    Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Enter Your Email',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll send you an OTP to verify your account',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,

                      textInputAction: TextInputAction.done, // ✅ DONE button

                      onFieldSubmitted: (_) async {
                        FocusScope.of(context).unfocus(); // keyboard band

                        if (_formKey.currentState!.validate()) {
                          final authController = Provider.of<AuthController>(
                            context,
                            listen: false,
                          );

                          final success = await authController.sendOTP(
                            _emailController.text,
                          );

                          if (success && mounted) {
                            Navigator.pushNamed(context, '/otp');
                          }
                        }
                      },

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
                                          .sendOTP(_emailController.text);
                                      if (success) {
                                        Navigator.pushNamed(context, '/otp');
                                      }
                                    }
                                  },
                            child: authController.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Send OTP',
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
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: Text(
                            'Login',
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
