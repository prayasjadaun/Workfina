class Recruiter {
  final String id;
  final String fullName;
  final String companyName;
  final String designation;
  final String phone;
  final String? companyWebsite;
  final String companySize;
  final int totalSpent;
  final bool isVerified;
  final DateTime createdAt;

  Recruiter({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.designation,
    required this.phone,
    this.companyWebsite,
    required this.companySize,
    this.totalSpent = 0,
    this.isVerified = false,
    required this.createdAt,
  });

  factory Recruiter.fromJson(Map<String, dynamic> json) {
    return Recruiter(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      companyName: json['company_name'] ?? '',
      designation: json['designation'] ?? '',
      phone: json['phone'] ?? '',
      companyWebsite: json['company_website'],
      companySize: json['company_size'] ?? '',
      totalSpent: json['total_spent'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'company_name': companyName,
      'designation': designation,
      'phone': phone,
      'company_website': companyWebsite,
      'company_size': companySize,
      'total_spent': totalSpent,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}