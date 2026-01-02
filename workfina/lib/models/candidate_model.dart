

class Candidate {
  final String id;
  final String fullName;
  final String maskedName;
  final String phone;
  final String email;
  final int age;
  final String role;
  final int experienceYears;
  final double? currentCtc;
  final double? expectedCtc;
  final String? religion;
  final String country;
  final String state;
  final String city;
  final String education;
  final String skills;
  final String? resumeUrl;
  final String? videoIntroUrl;
  final String? profileImageUrl;
  final bool isUnlocked;
  final DateTime createdAt;

  Candidate({
    required this.id,
    required this.fullName,
    required this.maskedName,
    required this.phone,
    required this.email,
    required this.age,
    required this.role,
    required this.experienceYears,
    this.currentCtc,
    this.expectedCtc,
    this.religion,
    required this.country,
    required this.state,
    required this.city,
    required this.education,
    required this.skills,
    this.resumeUrl,
    this.videoIntroUrl,
    this.profileImageUrl,
    this.isUnlocked = false,
    required this.createdAt,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      maskedName: json['masked_name'] ?? json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      role: json['role'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      currentCtc: json['current_ctc']?.toDouble(),
      expectedCtc: json['expected_ctc']?.toDouble(),
      religion: json['religion'],
      country: json['country'] ?? 'India',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      education: json['education'] ?? '',
      skills: json['skills'] ?? '',
      resumeUrl: json['resume_url'],
      videoIntroUrl: json['video_intro_url'],
      profileImageUrl: json['profile_image_url'],
      isUnlocked: json['is_unlocked'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'masked_name': maskedName,
      'phone': phone,
      'email': email,
      'age': age,
      'role': role,
      'experience_years': experienceYears,
      'current_ctc': currentCtc,
      'expected_ctc': expectedCtc,
      'religion': religion,
      'country': country,
      'state': state,
      'city': city,
      'education': education,
      'skills': skills,
      'resume_url': resumeUrl,
      'video_intro_url': videoIntroUrl,
      'profile_image_url': profileImageUrl,
      'is_unlocked': isUnlocked,
      'created_at': createdAt.toIso8601String(),
    };
  }
}