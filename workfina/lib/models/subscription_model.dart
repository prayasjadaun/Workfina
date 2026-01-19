class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final String planType;
  final String planTypeDisplay;
  final int durationDays;
  final double price;
  final bool isUnlimited;
  final int? creditsLimit;
  final bool isActive;
  final DateTime createdAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.planType,
    required this.planTypeDisplay,
    required this.durationDays,
    required this.price,
    required this.isUnlimited,
    this.creditsLimit,
    required this.isActive,
    required this.createdAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      planType: json['plan_type'],
      planTypeDisplay: json['plan_type_display'],
      durationDays: json['duration_days'],
      price: double.parse(json['price'].toString()),
      isUnlimited: json['is_unlimited'],
      creditsLimit: json['credits_limit'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'plan_type': planType,
      'plan_type_display': planTypeDisplay,
      'duration_days': durationDays,
      'price': price.toString(),
      'is_unlimited': isUnlimited,
      'credits_limit': creditsLimit,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SubscriptionStatus {
  final bool hasSubscription;
  final String? status;
  final String? plan;
  final String? planType;
  final DateTime? expiresAt;
  final int? daysRemaining;
  final bool isUnlimited;
  final int creditsUsed;
  final int? creditsLimit;
  final String? warningLevel;

  SubscriptionStatus({
    required this.hasSubscription,
    this.status,
    this.plan,
    this.planType,
    this.expiresAt,
    this.daysRemaining,
    required this.isUnlimited,
    required this.creditsUsed,
    this.creditsLimit,
    this.warningLevel,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      hasSubscription: json['has_subscription'],
      status: json['status'],
      plan: json['plan'],
      planType: json['plan_type'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      daysRemaining: json['days_remaining'],
      isUnlimited: json['is_unlimited'],
      creditsUsed: json['credits_used'],
      creditsLimit: json['credits_limit'],
      warningLevel: json['warning_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_subscription': hasSubscription,
      'status': status,
      'plan': plan,
      'plan_type': planType,
      'expires_at': expiresAt?.toIso8601String(),
      'days_remaining': daysRemaining,
      'is_unlimited': isUnlimited,
      'credits_used': creditsUsed,
      'credits_limit': creditsLimit,
      'warning_level': warningLevel,
    };
  }
}

class SubscriptionHistory {
  final String id;
  final String action;
  final String performedBy;
  final String performedByName;
  final Map<String, dynamic> details;
  final String notes;
  final DateTime createdAt;

  SubscriptionHistory({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.performedByName,
    required this.details,
    required this.notes,
    required this.createdAt,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'],
      action: json['action'],
      performedBy: json['performed_by'],
      performedByName: json['performed_by_name'],
      details: json['details'] ?? {},
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'performed_by': performedBy,
      'performed_by_name': performedByName,
      'details': details,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SubscriptionNotification {
  final String id;
  final String notificationType;
  final String message;
  final bool isSent;
  final DateTime? sentAt;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  SubscriptionNotification({
    required this.id,
    required this.notificationType,
    required this.message,
    required this.isSent,
    this.sentAt,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory SubscriptionNotification.fromJson(Map<String, dynamic> json) {
    return SubscriptionNotification(
      id: json['id'],
      notificationType: json['notification_type'],
      message: json['message'],
      isSent: json['is_sent'],
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : null,
      isRead: json['is_read'],
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'message': message,
      'is_sent': isSent,
      'sent_at': sentAt?.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Subscription {
  final String id;
  final String hrProfile;
  final String companyName;
  final String companyEmail;
  final SubscriptionPlan plan;
  final String status;
  final String statusDisplay;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;
  final String? warningLevel;
  final bool isCurrentlyActive;
  final bool hasUnlimited;
  final int creditsUsed;
  final String? paymentReference;
  final String? approvedBy;
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? cancelledBy;
  final String? cancelledByName;
  final DateTime? cancelledAt;
  final String cancellationReason;
  final String adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SubscriptionHistory>? history;
  final List<SubscriptionNotification>? notifications;

  Subscription({
    required this.id,
    required this.hrProfile,
    required this.companyName,
    required this.companyEmail,
    required this.plan,
    required this.status,
    required this.statusDisplay,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    this.warningLevel,
    required this.isCurrentlyActive,
    required this.hasUnlimited,
    required this.creditsUsed,
    this.paymentReference,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.cancelledBy,
    this.cancelledByName,
    this.cancelledAt,
    required this.cancellationReason,
    required this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.history,
    this.notifications,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      hrProfile: json['hr_profile'],
      companyName: json['company_name'],
      companyEmail: json['company_email'],
      plan: SubscriptionPlan.fromJson(json['plan']),
      status: json['status'],
      statusDisplay: json['status_display'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      daysRemaining: json['days_remaining'] ?? 0,
      warningLevel: json['warning_level'],
      isCurrentlyActive: json['is_currently_active'] ?? false,
      hasUnlimited: json['has_unlimited'] ?? false,
      creditsUsed: json['credits_used'] ?? 0,
      paymentReference: json['payment_reference'],
      approvedBy: json['approved_by'],
      approvedByName: json['approved_by_name'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      cancelledBy: json['cancelled_by'],
      cancelledByName: json['cancelled_by_name'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancellationReason: json['cancellation_reason'] ?? '',
      adminNotes: json['admin_notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      history: json['history'] != null
          ? (json['history'] as List)
              .map((h) => SubscriptionHistory.fromJson(h))
              .toList()
          : null,
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
              .map((n) => SubscriptionNotification.fromJson(n))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hr_profile': hrProfile,
      'company_name': companyName,
      'company_email': companyEmail,
      'plan': plan.toJson(),
      'status': status,
      'status_display': statusDisplay,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'days_remaining': daysRemaining,
      'warning_level': warningLevel,
      'is_currently_active': isCurrentlyActive,
      'has_unlimited': hasUnlimited,
      'credits_used': creditsUsed,
      'payment_reference': paymentReference,
      'approved_by': approvedBy,
      'approved_by_name': approvedByName,
      'approved_at': approvedAt?.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancelled_by_name': cancelledByName,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'history': history?.map((h) => h.toJson()).toList(),
      'notifications': notifications?.map((n) => n.toJson()).toList(),
    };
  }
}
