import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
        const SnackBar(content: Text('Note added successfully'), backgroundColor: AppTheme.primary),
      );
    }
  }

  Future<void> _loadNotesAndFollowups() async {
    final result = await ApiService.getCandidateNotesFollowups(widget.candidate['id']);
    
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up reminder added')),
      );
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
                _launchURL(viewUrl);
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

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Video Introduction',
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
                  "assets/svgs/play.svg",
                  color: Colors.black,
                ),
              ),
              title: const Text('Play Video'),
              subtitle: const Text('Open in external player'),
              onTap: () {
                Navigator.pop(context);
                String playUrl = videoUrl.toString();
                if (!playUrl.startsWith('http')) {
                  final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                  playUrl = '$baseUrl$playUrl';
                }
                _launchURL(playUrl);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        // backgroundColor: Theme.of(context).colorScheme.background,
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.43,
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
              actions: [
                GestureDetector(
                  onTap: () => _openWhatsApp(widget.candidate['phone']),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      "assets/svgs/whatsapp.svg",
                      color: Colors.white,
                      // width: 16,
                      // height: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      _handlePhoneCall(context, widget.candidate['phone']),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      "assets/svgs/phone.svg",
                      color: Colors.white,
                      // width: 30,
                      // height: 30,
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: () {},
                //   child: Container(
                //     margin: const EdgeInsets.all(8),
                //     width: 40,
                //     height: 40,
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.2),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: const Icon(
                //       Icons.more_vert,
                //       color: Colors.white,
                //       size: 20,
                //     ),
                //   ),
                // ),
              ],
              flexibleSpace: FlexibleSpaceBar(
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
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context),
                      const SizedBox(height: 24),
                      if (widget.candidate['skills'] != null) ...[
                        _buildSkillsSection(context),
                        const SizedBox(height: 24),
                      ],
                      _buildContactInfo(context),
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
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _handleResumeClick(context, widget.candidate),
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        "assets/svgs/docs.svg",
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          AppTheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    label: Text(
                      'View Resume',
                      style: AppTheme.getBodyStyle(
                        context,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _handleVideoClick(context, widget.candidate),
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        "assets/svgs/play.svg",
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    label: Text(
                      'Watch Video',
                      style: AppTheme.getBodyStyle(
                        context,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.candidate['full_name'] ??
              widget.candidate['masked_name'] ??
              'Unknown',
          style: AppTheme.getHeadlineStyle(
            context,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.candidate['role_name'] ?? 'Role not specified',
          style: AppTheme.getBodyStyle(
            context,
            fontSize: 20,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w800
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              '${widget.candidate['city_name'] ?? ''}, ${widget.candidate['state_name'] ?? ''}',
              style: AppTheme.getSubtitleStyle(
                context,
                fontSize: 17,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.circle, size: 8, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              '${widget.candidate['experience_years'] ?? 0} yrs exp',
              style: AppTheme.getSubtitleStyle(
                context,
                fontSize: 17,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    final skills = widget.candidate['skills']?.split(',') ?? [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map<Widget>((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            skill.trim(),
            style: AppTheme.getLabelStyle(context, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
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
        const SizedBox(height: 12),
        // Display existing notes
        if (notes.isNotEmpty) ...[
          ...notes.map((note) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              note['note_text'] ?? '',
              style: AppTheme.getBodyStyle(context, fontSize: 14),
            ),
          )).toList(),
          const SizedBox(height: 12),
        ],
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
                    color: Colors.grey.shade500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(
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
                  fillColor: AppTheme.getCardColor(context),
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
                color: AppTheme.primary,
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
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                tooltip: 'Send Note',
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFollowupsSection(BuildContext context) {
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
                backgroundColor: AppTheme.primary,
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
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alarm_off_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'No follow-up reminders set',
                  style: AppTheme.getSubtitleStyle(
                    context,
                    color: Colors.grey.shade600,
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
              final dateStr = followup['followup_date']?.toString() ?? 
                             followup['date']?.toString() ?? '';
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
            final displayDate = DateFormat('dd/MM/yyyy hh:mm a').format(followupDateTime.toLocal());

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFF0FDF4)
                    : isPast
                    ? const Color(0xFFFEF2F2)
                    : AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF22C55E)
                      : isPast
                      ? const Color(0xFFEF4444)
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
                          ? const Color(0xFF22C55E).withOpacity(0.1)
                          : isPast
                          ? const Color(0xFFEF4444).withOpacity(0.1)
                          : AppTheme.primary.withOpacity(0.1),
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
                            color: isCompleted ? const Color(0xFF22C55E) : null,
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
                              color: Colors.grey.shade600,
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

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Column(
        children: [
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
            'Current CTC',
            _formatCurrency(widget.candidate['current_ctc']),
          ),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            context,
            'Expected CTC',
            _formatCurrency(widget.candidate['expected_ctc']),
          ),
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
            color: Colors.grey.shade600,
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
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.only(
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
                        color: CupertinoColors.systemBackground,
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.separator.withOpacity(0.3),
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
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const Text(
                            'Follow-up',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
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
                                color: CupertinoColors.systemGrey6,
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
                                      const Text(
                                        'Date & Time',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    DateFormat(
                                      'MMMM dd, yyyy',
                                    ).format(selectedDateTime),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'hh:mm a',
                                    ).format(selectedDateTime),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                'Pick Date',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
                            const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                'Pick Time',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
                                      const Text(
                                        'Notes (Optional)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
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
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemGrey6,
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
      // Android Material Design
      await showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Add Follow-up Reminder'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date & Time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
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
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(selectedDateTime),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat(
                                    'hh:mm a',
                                  ).format(selectedDateTime),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Notes (Optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add notes for this follow-up...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                  style: TextStyle(color: Colors.grey.shade400),
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