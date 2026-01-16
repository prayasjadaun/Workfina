import 'package:flutter/material.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class HiringAvailabileWidget extends StatefulWidget {
  final String title;
  final String message;
  final bool currentStatus;

  const HiringAvailabileWidget({
    super.key,
    required this.title,
    required this.message,
    required this.currentStatus,
  });

  /// Show the hiring availability bottom sheet
  /// Returns true if user responded, false if not shown or error
  static Future<bool> showIfNeeded(BuildContext context) async {
    try {
      final response = await ApiService.getCandidateAvailability();

      if (response.containsKey('error')) {
        return false;
      }

      // Check if we need to show the prompt (backend controls this)
      final shouldShowPrompt = response['should_show_prompt'] ?? false;
      if (!shouldShowPrompt) {
        return false;
      }

      if (!context.mounted) return false;

      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => HiringAvailabileWidget(
          title: response['title'] ?? 'Are you still available for hiring?',
          message: response['message'] ??
              'Please confirm if you\'re still open to new job opportunities.',
          currentStatus: response['is_available_for_hiring'] ?? true,
        ),
      );

      return result ?? false;
    } catch (e) {
      debugPrint('[DEBUG] Error showing availability prompt: $e');
      return false;
    }
  }

  @override
  State<HiringAvailabileWidget> createState() => _HiringAvailabileWidgetState();
}

class _HiringAvailabileWidgetState extends State<HiringAvailabileWidget> {
  bool _isLoading = false;

  Future<void> _updateAvailability(bool isAvailable) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updateCandidateAvailability(
        isAvailableForHiring: isAvailable,
      );

      if (response.containsKey('error')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error']),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('[DEBUG] Error updating availability: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 1.0,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.greenCard.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.work_outline_rounded,
                          size: 60,
                          color: AppTheme.greenCard,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Message
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Buttons
                      if (_isLoading)
                        const CircularProgressIndicator(
                          color: AppTheme.greenCard,
                        )
                      else
                        Column(
                          children: [
                            // Yes Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => _updateAvailability(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.greenCard,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Yes, I\'m Available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // No Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () => _updateAvailability(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  side: BorderSide(color: Colors.grey[400]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'No, Not Available',
                                  style: TextStyle(
                                    fontSize: 18,
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
            ],
          ),
        ),
      ),
    );
  }
}
