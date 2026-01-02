import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workfina/theme/app_theme.dart';

class CandidateCardWidget extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final bool isUnlocked;
  final bool canAffordUnlock;
  final VoidCallback? onUnlock;
  final VoidCallback? onViewProfile;

  const CandidateCardWidget({
    super.key,
    required this.candidate,
    required this.isUnlocked,
    required this.canAffordUnlock,
    this.onUnlock,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile and status
            Row(
              children: [
                // Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFF5F5F5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: candidate['profile_image'] != null
                        ? Image.network(
                            candidate['profile_image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildInitialAvatar(isDark),
                          )
                        : _buildInitialAvatar(isDark),
                  ),
                ),
                const SizedBox(width: 16),
                // Name and Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUnlocked
                            ? (candidate['full_name'] ??
                                  candidate['masked_name'] ??
                                  'Unknown')
                            : (candidate['masked_name'] ?? 'Unknown'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate['role_name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFFB0B0B0)
                              : const Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
              ],
            ),

            const SizedBox(height: 20),

            // Info Row
            Row(
              children: [
                _buildInfoTile(
                  'City',
                  candidate['city_name'] ?? 'N/A',
                  isDark,
                ),
                const SizedBox(width: 24),
                _buildInfoTile(
                  'Experience',
                  '${candidate['experience_years'] ?? 0} years',
                  isDark,
                ),
                const SizedBox(width: 24),
                _buildInfoTile(
                  'Age',
                  '${candidate['age'] ?? 'N/A'} years',
                  isDark,
                ),
              ],
            ),

            // Additional Info for unlocked profiles
            if (isUnlocked) ...[
             
            ],
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  ],
                ),
              ),
            ),
            // Skills Row
            if (candidate['skills'] != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [_buildSkillsInfoTile(candidate['skills'], isDark)],
              ),
            ],
            // Action Button
            const SizedBox(height: 24),
            _buildActionButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(bool isDark) {
    return Center(
      child: Text(
        (candidate['masked_name']?.substring(0, 1) ?? 'P').toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsInfoTile(String skills, bool isDark) {
    final allSkills = skills.split(',').map((s) => s.trim()).toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  allSkills
                      .take(4)
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2D2D2D)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      )
                      .toList() +
                  (allSkills.length > 4
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${allSkills.length - 4}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ]
                      : []),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Skills',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    if (isUnlocked) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: onViewProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'View Full Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Row(
      children: [
        // Credit Info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: canAffordUnlock
                ? AppTheme.accentPrimary.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canAffordUnlock
                  ? AppTheme.accentPrimary.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars_outlined,
                size: 16,
                color: canAffordUnlock ? AppTheme.accentPrimary : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '10 credits to unlock',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: canAffordUnlock ? AppTheme.accentPrimary : Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Unlock Button
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: canAffordUnlock ? onUnlock : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAffordUnlock
                    ? AppTheme.primary
                    : (isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFE5E5E5)),
                foregroundColor: canAffordUnlock
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF6B6B6B)
                          : const Color(0xFF9B9B9B)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/lock.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      canAffordUnlock
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFF6B6B6B)
                                : const Color(0xFF9B9B9B)),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Unlock Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: canAffordUnlock
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFF6B6B6B)
                                : const Color(0xFF9B9B9B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
