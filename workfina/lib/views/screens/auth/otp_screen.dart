import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workfina/controllers/auth_controller.dart';
import 'package:workfina/theme/app_theme.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get otpCode =>
      _otpControllers.map((controller) => controller.text).join();

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Verify OTP',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Enter Verification Code',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to ${authController.tempEmail ?? "your email"}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) async {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }

                            // ✅ AUTO SUBMIT WHEN OTP COMPLETE
                            if (index == 5 && value.isNotEmpty) {
                              FocusScope.of(context).unfocus(); // keyboard band

                              final authController =
                                  Provider.of<AuthController>(
                                    context,
                                    listen: false,
                                  );

                              if (otpCode.length == 6 &&
                                  !authController.isLoading) {
                                final success = await authController
                                    .verifyOTPOnly(
                                      email: authController.tempEmail!,
                                      otp: otpCode,
                                    );

                                if (success && mounted) {
                                  Navigator.pushNamed(
                                    context,
                                    '/create-account',
                                  );
                                }
                              }
                            }

                            setState(() {});
                          },
                        ),
                      );
                    }),
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
                          onPressed:
                              authController.isLoading || otpCode.length != 6
                              ? null
                              : () async {
                                  final success = await authController
                                      .verifyOTPOnly(
                                        email: authController.tempEmail!,
                                        otp: otpCode,
                                      );
                                  if (success) {
                                    Navigator.pushNamed(
                                      context,
                                      '/create-account',
                                    );
                                  }
                                },
                          child: authController.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Verify OTP',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () async {
                      if (authController.tempEmail != null) {
                        await authController.sendOTP(authController.tempEmail!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP sent again')),
                        );
                      }
                    },
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
