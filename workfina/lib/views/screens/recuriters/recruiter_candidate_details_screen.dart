import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workfina/services/api_service.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateDetailScreen extends StatefulWidget {
  final Map<String, dynamic> candidate;
  final bool isAlreadyUnlocked;

  const CandidateDetailScreen({
    super.key,
    required this.candidate,
    this.isAlreadyUnlocked = false,
  });

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen> {
  List<Map<String, dynamic>> followups = [];
  List<Map<String, dynamic>> notes = [];
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  bool _isLoadingNotes = false;
  bool _isObjectiveExpanded = false;
  // ignore: unused_field
  final Map<int, bool> _workExpDescriptionExpanded = {};

  @override
  void initState() {
    super.initState();
    _loadNotesAndFollowups();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  String _getTruncatedText(String text) {
    const maxLength = 150; // Approximately 3 lines worth of text
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }

  bool _needsViewMore(String text) {
    const maxLength = 150;
    return text.length > maxLength;
  }

  double _calculateExpandedHeight() {
    final baseHeight = MediaQuery.of(context).size.height * 0.43;
    if (widget.candidate['career_objective'] != null &&
        widget.candidate['career_objective'].toString().isNotEmpty) {
      if (_isObjectiveExpanded) {
        return baseHeight + 60;
      }
      return baseHeight + 20;
    }
    return baseHeight;
  }

  Future<void> _sendNote() async {
    if (_notesController.text.trim().isEmpty) return;

    setState(() => _isLoadingNotes = true);

    final result = await ApiService.addCandidateNote(
      candidateId: widget.candidate['id'],
      noteText: _notesController.text.trim(),
    );

    setState(() => _isLoadingNotes = false);

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
      );
    } else {
      setState(() {
        notes.add(result['note']);
      });
      _notesController.clear();
      _notesFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added successfully'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  Future<void> _loadNotesAndFollowups() async {
    final result = await ApiService.getCandidateNotesFollowups(
      widget.candidate['id'],
    );

    if (!result.containsKey('error')) {
      setState(() {
        notes = List<Map<String, dynamic>>.from(result['notes'] ?? []);
        followups = List<Map<String, dynamic>>.from(result['followups'] ?? []);
      });
    }
  }

  Future<void> _addFollowup(DateTime selectedDateTime, String? notes) async {
    final result = await ApiService.addCandidateFollowup(
      candidateId: widget.candidate['id'],
      followupDate: selectedDateTime.toIso8601String(),
      notes: notes,
    );

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
      );
    } else {
      setState(() {
        followups.add(result['followup']);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Follow-up reminder added')));
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Not Specified';
    final formatter = NumberFormat('#,##,###');
    double value = double.tryParse(amount.toString()) ?? 0;
    return formatter.format(value.toInt());
  }

  void _handleResumeClick(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    final resumeUrl = profileData['resume_url'];

    if (resumeUrl == null || resumeUrl.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No resume uploaded yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Resume',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  "assets/svgs/eye.svg",
                  color: Colors.black,
                ),
              ),
              title: const Text('View Resume'),
              onTap: () {
                Navigator.pop(context);
                String viewUrl = resumeUrl.toString();
                if (!viewUrl.startsWith('http')) {
                  final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                  viewUrl = '$baseUrl$viewUrl';
                }
                _launchURL(viewUrl, mode: LaunchMode.inAppWebView);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  "assets/svgs/download.svg",
                  color: Colors.black,
                ),
              ),
              title: const Text('Download Resume'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(resumeUrl.toString(), context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleVideoClick(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    final videoUrl = profileData['video_intro_url'];

    if (videoUrl == null || videoUrl.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video introduction available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String playUrl = videoUrl.toString();
    if (!playUrl.startsWith('http')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      playUrl = '$baseUrl$playUrl';
    }
    _launchURL(playUrl, mode: LaunchMode.inAppWebView);
  }

  void _launchURL(String url, {LaunchMode? mode}) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: mode ?? LaunchMode.externalApplication);
    }
  }

  void _downloadFile(String url, BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting download...'),
          backgroundColor: AppTheme.primary,
        ),
      );

      String downloadUrl = url;
      if (!url.startsWith('http')) {
        final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
        downloadUrl = '$baseUrl$url';
      }

      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final filePath = '${directory.path}/$fileName';

      await dio.download(downloadUrl, filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $fileName'),
            backgroundColor: AppTheme.primary,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => _launchURL('file://$filePath'),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        // backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: _calculateExpandedHeight(),
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              flexibleSpace: FlexibleSpaceBar(
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final collapsed =
                        constraints.biggest.height <=
                        kToolbarHeight + MediaQuery.of(context).padding.top;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      transform: Matrix4.translationValues(
                        0,
                        collapsed ? 0 : 30,
                        0,
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: collapsed ? 1.0 : 0.0,
                        child: Text(
                          widget.candidate['full_name'] ??
                              widget.candidate['masked_name'] ??
                              'Unknown',
                          style: AppTheme.getAppBarTextStyle().copyWith(
                            fontSize: collapsed ? 18 : 0,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  },
                ),
                background: Container(
                  decoration: BoxDecoration(
                    image: widget.candidate['profile_image_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(
                              _getFullImageUrl(
                                widget.candidate['profile_image_url'],
                              ),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //   begin: Alignment.center,
                      //   end: Alignment.bottomCenter,
                      //   colors: [
                      //     Colors.black.withOpacity(0.3),
                      //     Colors.black.withOpacity(0.8),
                      //   ],
                      // ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.candidate['career_objective'] != null &&
                            widget.candidate['career_objective']
                                .toString()
                                .isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Career Objective',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _isObjectiveExpanded
                                            ? widget
                                                  .candidate['career_objective']
                                                  .toString()
                                            : _getTruncatedText(
                                                widget
                                                    .candidate['career_objective']
                                                    .toString(),
                                              ),
                                      ),
                                      if (!_isObjectiveExpanded &&
                                          _needsViewMore(
                                            widget.candidate['career_objective']
                                                .toString(),
                                          ))
                                        TextSpan(
                                          text: ' View More',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              setState(() {
                                                _isObjectiveExpanded = true;
                                              });
                                            },
                                        ),
                                    ],
                                  ),
                                ),
                                if (_isObjectiveExpanded) ...[
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isObjectiveExpanded = false;
                                      });
                                    },
                                    child: const Text(
                                      'View Less',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  // borderRadius: const BorderRadius.only(
                  //   topLeft: Radius.circular(24),
                  //   topRight: Radius.circular(24),
                  // ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context),
                      const SizedBox(height: 24),
                      // _buildCareerObjectiveSection(context),
                      // const SizedBox(height: 24),
                      _buildVideoIntroSection(context),
                      const SizedBox(height: 24),
                      _buildWorkExperienceSection(context),
                      const SizedBox(height: 24),
                      if (widget.candidate['skills'] != null) ...[
                        _buildSkillsSection(context),
                        const SizedBox(height: 24),
                      ],
                      _buildPersonalInfoSection(context),
                      const SizedBox(height: 24),
                      _buildEducationSection(context),
                      const SizedBox(height: 24),
                      _buildFollowupsSection(context),
                      const SizedBox(height: 24),
                      _buildNotesSection(context),
                      const SizedBox(height: 170),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Left side - Contact buttons
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handlePhoneCall(
                            context,
                            widget.candidate['phone'],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.blueLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/call.svg",
                                  color: isDark
                                      ? Colors.black
                                      : AppTheme.blueDark,
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openWhatsApp(widget.candidate['phone']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.blueLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: SvgPicture.asset(
                              "assets/svg/whatsapp.svg",
                              color: isDark ? Colors.black : AppTheme.blueDark,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final email = widget.candidate['email'];
                            if (email != null && email.isNotEmpty) {
                              final uri = Uri.parse('mailto:$email');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email not available'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.blueLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: SvgPicture.asset(
                              "assets/svg/email.svg",
                              color: isDark ? Colors.black : AppTheme.blueDark,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Resume button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _handleResumeClick(context, widget.candidate),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/docs.svg",
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    label: Text(
                      'Resume',
                      style: AppTheme.getBodyStyle(
                        context,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: isDark ? Colors.white : Colors.black,
                      backgroundColor: AppTheme.blue,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) return imageUrl;
    final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
    return '$baseUrl$imageUrl';
  }

  void _handlePhoneCall(BuildContext context, String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Try WhatsApp scheme first
    final whatsappScheme = Uri.parse('whatsapp://send?phone=$cleanPhone');
    if (await canLaunchUrl(whatsappScheme)) {
      await launchUrl(whatsappScheme, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to web version
    final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Widget _buildProfileHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCandidateName(widget.candidate),
          style: AppTheme.getHeadlineStyle(
            context,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SvgPicture.asset(
              "assets/svgs/location.svg",
              color: isDark ? Colors.white : AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.candidate['city_name'] ?? ''}, ${widget.candidate['state_name'] ?? ''}',
                style: AppTheme.getBodyStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Experience & Role box
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [AppTheme.getCardShadow(context)],
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/work.svg",
                      color: isDark ? Colors.white : AppTheme.primary,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.candidate['role_name'] ?? 'Role not specified',
                        style: AppTheme.getBodyStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [AppTheme.getCardShadow(context)],
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/schedule.svg",
                      color: isDark ? Colors.white : AppTheme.primary,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.candidate['experience_years'] ?? 0} yrs exp',
                        style: AppTheme.getBodyStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getCandidateName(Map<String, dynamic> candidate) {
    final firstName = candidate['first_name'] ?? '';
    final lastName = candidate['last_name'] ?? '';

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }

    return candidate['masked_name'] ?? 'Unknown';
  }

  Widget _buildSkillsSection(BuildContext context) {
    final skills = widget.candidate['skills']?.split(',') ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: AppTheme.getTitleStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 5,
            runSpacing: 8,
            children: skills.map<Widget>((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.primary.withOpacity(0.5)
                        : AppTheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  skill.trim(),
                  style: AppTheme.getLabelStyle(
                    context,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.black : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelocateInfoRow(BuildContext context) {
    final isWillingToRelocate = widget.candidate['willing_to_relocate'] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Willing to Relocate',
          style: AppTheme.getSubtitleStyle(
            context,
            // color: Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isWillingToRelocate
                    ? AppTheme.primary.withOpacity(0.1)
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isWillingToRelocate
                      ? AppTheme.primary.withOpacity(0.3)
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isWillingToRelocate ? Icons.check_circle : Icons.cancel,
                    color: isDark ? Colors.white : Colors.black,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isWillingToRelocate ? 'Yes' : 'No',
                    style: AppTheme.getBodyStyle(
                      context,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: AppTheme.getTitleStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Display existing notes
          if (notes.isNotEmpty) ...[
            ...notes.map((note) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurface.withOpacity(0.5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.grey.shade700
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.sticky_note_2_rounded,
                        color: isDark ? Colors.white : AppTheme.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        note['note_text'] ?? '',
                        style: AppTheme.getBodyStyle(context, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
          // Add note input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _notesController,
                  focusNode: _notesFocusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendNote(),
                  style: AppTheme.getBodyStyle(context),
                  decoration: InputDecoration(
                    hintText: 'Add notes about this candidate...',
                    hintStyle: AppTheme.getSubtitleStyle(
                      context,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey.shade600
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey.shade600
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppTheme.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _isLoadingNotes ? null : _sendNote,
                  icon: _isLoadingNotes
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: isDark ? Colors.black : Colors.white,
                          size: 20,
                        ),
                  tooltip: 'Send Note',
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          if (notes.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurface.withOpacity(0.3)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.grey.shade700
                      : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_add_rounded,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No notes added yet',
                    style: AppTheme.getSubtitleStyle(
                      context,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowupsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Follow-up Reminders',
              style: AppTheme.getTitleStyle(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showAddFollowupDialog(context),
              icon: const Icon(Icons.add_alarm_rounded, size: 18),
              label: Text(
                'Add Follow-up',
                style: AppTheme.getBodyStyle(
                  context,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blueDark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (followups.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.grey.shade700
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alarm_off_rounded,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'No follow-up reminders set',
                  style: AppTheme.getSubtitleStyle(
                    context,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ...followups.map((followup) {
            DateTime followupDateTime;
            try {
              // Handle API response format
              final dateStr =
                  followup['followup_date']?.toString() ??
                  followup['date']?.toString() ??
                  '';
              if (dateStr.contains('/') && dateStr.contains(' ')) {
                followupDateTime = DateFormat(
                  'dd/MM/yyyy hh:mm a',
                ).parse(dateStr);
              } else {
                followupDateTime = DateTime.parse(dateStr);
              }
            } catch (e) {
              followupDateTime = DateTime.now();
            }

            final isCompleted = followup['is_completed'] ?? false;
            final isPast = followupDateTime.isBefore(DateTime.now());

            // Format the date for display - adjust for IST timezone
            final displayDate = DateFormat(
              'dd/MM/yyyy hh:mm a',
            ).format(followupDateTime.toLocal());

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted
                    ? (isDark
                          ? const Color(0xFF0F4F3C)
                          : const Color(0xFFF0FDF4))
                    : isPast
                    ? (isDark
                          ? const Color(0xFF4F1E1E)
                          : const Color(0xFFFEF2F2))
                    : AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF22C55E)
                      : isPast
                      ? const Color(0xFFEF4444)
                      : isDark
                      ? Colors.grey.shade700
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [AppTheme.getCardShadow(context)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF22C55E).withOpacity(0.2)
                          : isPast
                          ? const Color(0xFFEF4444).withOpacity(0.2)
                          : AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : isPast
                          ? Icons.warning_rounded
                          : Icons.alarm_rounded,
                      color: isCompleted
                          ? const Color(0xFF22C55E)
                          : isPast
                          ? const Color(0xFFEF4444)
                          : AppTheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayDate,
                          style: AppTheme.getBodyStyle(
                            context,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? const Color(0xFF22C55E)
                                : (isDark ? Colors.white : null),
                            fontSize: 14,
                          ),
                        ),
                        if (followup['notes'] != null &&
                            followup['notes'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            followup['notes'].toString(),
                            style: AppTheme.getSubtitleStyle(
                              context,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildVideoIntroSection(BuildContext context) {
    final videoUrl = widget.candidate['video_intro_url'];

    if (videoUrl == null || videoUrl.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    String fullVideoUrl = videoUrl.toString();
    if (!fullVideoUrl.startsWith('http')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      fullVideoUrl = '$baseUrl$fullVideoUrl';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Introduction',
          style: AppTheme.getTitleStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppTheme.getCardShadow(context)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('$fullVideoUrl#t=0.1'),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                    ),
                    child: Icon(
                      Icons.videocam,
                      size: 50,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.3)),
                Center(
                  child: GestureDetector(
                    onTap: () => _handleVideoClick(context, widget.candidate),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: AppTheme.primary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationSection(BuildContext context) {
    final educations = widget.candidate['educations'];

    if (educations == null || educations.isEmpty) {
      return const SizedBox.shrink();
    }

    List<dynamic> educationList = educations is List ? educations : [];

    if (educationList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Education',
                style: AppTheme.getTitleStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '${educationList.length} ${educationList.length == 1 ? 'Qualification' : 'Qualifications'}',
                  style: AppTheme.getLabelStyle(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...educationList.asMap().entries.map<Widget>((entry) {
            final index = entry.key + 1;
            final edu = entry.value;
            final institutionName = edu['institution_name'] ?? '';
            final degree = edu['degree'] ?? '';
            final fieldOfStudy = edu['field_of_study'] ?? '';
            final startYear = edu['start_year'] ?? '';
            final endYear = edu['end_year'] ?? '';
            final isOngoing = edu['is_ongoing'] ?? false;
            final gradePercentage = edu['grade_percentage'] ?? '';
            final location = edu['location'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800.withOpacity(0.3)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: AppTheme.getBodyStyle(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Degree: ',
                            style: AppTheme.getBodyStyle(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                '$degree${fieldOfStudy.isNotEmpty ? ' in $fieldOfStudy' : ''}\n',
                            style: AppTheme.getBodyStyle(context, fontSize: 14),
                          ),
                          TextSpan(
                            text: 'Institution: ',
                            style: AppTheme.getBodyStyle(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '$institutionName\n',
                            style: AppTheme.getBodyStyle(context, fontSize: 14),
                          ),
                          TextSpan(
                            text: 'Duration: ',
                            style: AppTheme.getBodyStyle(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: isOngoing
                                ? '$startYear - Ongoing'
                                : '$startYear - $endYear',
                            style: AppTheme.getBodyStyle(context, fontSize: 14),
                          ),
                          if (gradePercentage.isNotEmpty) ...[
                            TextSpan(
                              text: '\nGrade: ',
                              style: AppTheme.getBodyStyle(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$gradePercentage%',
                              style: AppTheme.getBodyStyle(
                                context,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          if (location.isNotEmpty) ...[
                            TextSpan(
                              text: '\nLocation: ',
                              style: AppTheme.getBodyStyle(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: location,
                              style: AppTheme.getBodyStyle(
                                context,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTheme.getTitleStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            context,
            'Email',
            widget.candidate['email'] ?? 'Not Available',
          ),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            context,
            'Phone',
            widget.candidate['phone'] ?? 'Not Available',
          ),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            context,
            'Languages',
            widget.candidate['languages'] ?? 'Not Available',
          ),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            context,
            'Address',
            widget.candidate['street_address'] ?? 'Not Available',
          ),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            context,
            'Current CTC',
            _formatCurrency(widget.candidate['current_ctc']),
          ),
          const SizedBox(height: 16),
          _buildRelocateInfoRow(context),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            context,
            'Joining Availability',
            widget.candidate['joining_availability'] ?? 'Not Specified',
          ),
          if (widget.candidate['joining_availability'] != 'IMMEDIATE') ...[
            const SizedBox(height: 16),
            _buildContactInfoRow(
              context,
              'Notice Period',
              widget.candidate['notice_period_details'] ?? 'Not Specified',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkExperienceSection(BuildContext context) {
    final workExperiences = widget.candidate['work_experiences'];

    if (workExperiences == null || workExperiences.isEmpty) {
      return const SizedBox.shrink();
    }

    List<dynamic> experiences = workExperiences is List ? workExperiences : [];

    if (experiences.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Work Experience',
                style: AppTheme.getTitleStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '${experiences.length} ${experiences.length == 1 ? 'Company' : 'Companies'}',
                  style: AppTheme.getLabelStyle(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...experiences.asMap().entries.map<Widget>((entry) {
            final index = entry.key + 1;
            final exp = entry.value;
            final companyName = exp['company_name'] ?? '';
            final roleTitle = exp['role_title'] ?? '';
            final startDate = exp['start_date'] ?? '';
            final endDate = exp['end_date'] ?? '';
            final isCurrent = exp['is_current'] ?? false;
            final location = exp['location'] ?? '';

            // Format dates
            String duration = '';
            if (startDate.isNotEmpty) {
              try {
                final start = DateTime.parse(startDate);
                final startFormatted = DateFormat('MMM yyyy').format(start);

                if (isCurrent) {
                  duration = '$startFormatted - Present';
                } else if (endDate.isNotEmpty) {
                  final end = DateTime.parse(endDate);
                  final endFormatted = DateFormat('MMM yyyy').format(end);
                  duration = '$startFormatted - $endFormatted';
                } else {
                  duration = startFormatted;
                }
              } catch (e) {
                duration = isCurrent
                    ? '$startDate - Present'
                    : '$startDate - $endDate';
              }
            }

            final description = exp['description'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800.withOpacity(0.3)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: AppTheme.getBodyStyle(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Company: ',
                                style: AppTheme.getBodyStyle(
                                  context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '$companyName\n',
                                style: AppTheme.getBodyStyle(
                                  context,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: 'Role: ',
                                style: AppTheme.getBodyStyle(
                                  context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '$roleTitle\n',
                                style: AppTheme.getBodyStyle(
                                  context,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: 'Duration: ',
                                style: AppTheme.getBodyStyle(
                                  context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: duration,
                                style: AppTheme.getBodyStyle(
                                  context,
                                  fontSize: 14,
                                ),
                              ),
                              if (location.isNotEmpty) ...[
                                TextSpan(
                                  text: '\nLocation: ',
                                  style: AppTheme.getBodyStyle(
                                    context,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: location,
                                  style: AppTheme.getBodyStyle(
                                    context,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // if (description.isNotEmpty) ...[
                  //   const SizedBox(height: 12),
                  //   Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const SizedBox(width: 36), // Align with content above
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               'Description: ',
                  //               style: AppTheme.getBodyStyle(
                  //                 context,
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //             const SizedBox(height: 4),
                  //             RichText(
                  //               text: TextSpan(
                  //                 style: AppTheme.getBodyStyle(context, fontSize: 14),
                  //                 children: [
                  //                   TextSpan(
                  //                     text: _workExpDescriptionExpanded[index] == true
                  //                         ? description
                  //                         : _getTruncatedText(description),
                  //                   ),
                  //                   if (description.length > 120) ...[
                  //                     TextSpan(text: ' '),
                  //                     TextSpan(
                  //                       text: _workExpDescriptionExpanded[index] == true
                  //                           ? 'View Less'
                  //                           : 'View More',
                  //                       style: AppTheme.getBodyStyle(
                  //                         context,
                  //                         color: AppTheme.primary,
                  //                         fontWeight: FontWeight.w600,
                  //                       ),
                  //                       recognizer: TapGestureRecognizer()
                  //                         ..onTap = () {
                  //                           setState(() {
                  //                             _workExpDescriptionExpanded[index] =
                  //                                 !(_workExpDescriptionExpanded[index] ?? false);
                  //                           });
                  //                         },
                  //                     ),
                  //                   ],
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.getSubtitleStyle(
            context,
            // color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: AppTheme.getBodyStyle(context, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showAddFollowupDialog(BuildContext context) async {
    DateTime selectedDateTime = DateTime.now().add(const Duration(minutes: 5));
    final TextEditingController notesController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSavingFollowup = false;

    if (Platform.isIOS) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) => StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final now = DateTime.now();
            final minimumDate = DateTime(now.year, now.month, now.day);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height:
                    MediaQuery.of(context).size.height * 0.85 -
                    MediaQuery.of(context).viewInsets.bottom,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurface
                      : CupertinoColors.systemBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurface
                            : CupertinoColors.systemBackground,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : CupertinoColors.separator.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(bottomSheetContext),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 17,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            'Follow-up',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: isSavingFollowup
                                ? null
                                : () async {
                                    setBottomSheetState(
                                      () => isSavingFollowup = true,
                                    );
                                    try {
                                      await _addFollowup(
                                        selectedDateTime,
                                        notesController.text.trim().isEmpty
                                            ? null
                                            : notesController.text.trim(),
                                      );
                                      Navigator.pop(bottomSheetContext);
                                    } catch (e) {
                                      setBottomSheetState(
                                        () => isSavingFollowup = false,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to add follow-up: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: isSavingFollowup
                                ? const CupertinoActivityIndicator()
                                : const Text(
                                    'Done',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date & Time Display
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkCardBackground
                                    : CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.calendar,
                                        size: 20,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Date & Time',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    DateFormat(
                                      'MMMM dd, yyyy',
                                    ).format(selectedDateTime),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'hh:mm a',
                                    ).format(selectedDateTime),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'Pick Date',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            // Date Picker
                            SizedBox(
                              height: 200,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                ).toLocal(),
                                minimumDate: minimumDate,
                                maximumDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                                onDateTimeChanged: (DateTime newDate) {
                                  setBottomSheetState(() {
                                    selectedDateTime = DateTime(
                                      newDate.year,
                                      newDate.month,
                                      newDate.day,
                                      selectedDateTime.hour,
                                      selectedDateTime.minute,
                                    ).toLocal();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'Pick Time',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            // Time Picker
                            SizedBox(
                              height: 200,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: selectedDateTime.toLocal(),
                                use24hFormat: false,
                                onDateTimeChanged: (DateTime newTime) {
                                  setBottomSheetState(() {
                                    selectedDateTime = DateTime(
                                      selectedDateTime.year,
                                      selectedDateTime.month,
                                      selectedDateTime.day,
                                      newTime.hour,
                                      newTime.minute,
                                    ).toLocal();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Notes Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.text_alignleft,
                                        size: 20,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Notes (Optional)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  CupertinoTextField(
                                    controller: notesController,
                                    placeholder:
                                        'Add notes for this follow-up...',
                                    maxLines: 4,
                                    padding: const EdgeInsets.all(12),
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    placeholderStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : CupertinoColors.placeholderText,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.darkCardBackground
                                          : CupertinoColors.systemGrey6,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Android Material Design - keep existing code but add dark mode support
      await showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.getCardColor(context),
            title: Text(
              'Add Follow-up Reminder',
              style: AppTheme.getTitleStyle(context),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date & Time',
                    style: AppTheme.getBodyStyle(
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme
                                  .copyWith(
                                    primary: AppTheme.primary,
                                    surface: AppTheme.getCardColor(context),
                                  ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme
                                    .copyWith(
                                      primary: AppTheme.primary,
                                      surface: AppTheme.getCardColor(context),
                                    ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade600
                              : const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.getCardColor(context),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(selectedDateTime),
                                  style: AppTheme.getBodyStyle(
                                    context,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat(
                                    'hh:mm a',
                                  ).format(selectedDateTime),
                                  style: AppTheme.getSubtitleStyle(
                                    context,
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notes (Optional)',
                    style: AppTheme.getBodyStyle(
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    style: AppTheme.getBodyStyle(context),
                    decoration: InputDecoration(
                      hintText: 'Add notes for this follow-up...',
                      hintStyle: AppTheme.getSubtitleStyle(
                        context,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.getCardColor(context),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSavingFollowup
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: AppTheme.getBodyStyle(
                    context,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isSavingFollowup
                    ? null
                    : () async {
                        setDialogState(() => isSavingFollowup = true);
                        try {
                          await _addFollowup(
                            selectedDateTime,
                            notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                          );
                          Navigator.pop(dialogContext);
                        } catch (e) {
                          setDialogState(() => isSavingFollowup = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to add follow-up: ${e.toString()}',
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: isSavingFollowup
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add Follow-up'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
