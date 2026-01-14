class AppVersionModel {
  final bool updateAvailable;
  final bool isMandatory;
  final bool forceUpdate;
  final String latestVersion;
  final String? releaseNotes;
  final String? downloadUrl;
  final List<String> features;
  final List<String> bugFixes;
  final String? message;

  AppVersionModel({
    required this.updateAvailable,
    required this.isMandatory,
    required this.forceUpdate,
    required this.latestVersion,
    this.releaseNotes,
    this.downloadUrl,
    this.features = const [],
    this.bugFixes = const [],
    this.message,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      updateAvailable: json['update_available'] ?? false,
      isMandatory: json['is_mandatory'] ?? false,
      forceUpdate: json['force_update'] ?? false,
      latestVersion: json['latest_version'] ?? '',
      releaseNotes: json['release_notes'],
      downloadUrl: json['download_url'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      bugFixes: json['bug_fixes'] != null
          ? List<String>.from(json['bug_fixes'])
          : [],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'update_available': updateAvailable,
      'is_mandatory': isMandatory,
      'force_update': forceUpdate,
      'latest_version': latestVersion,
      'release_notes': releaseNotes,
      'download_url': downloadUrl,
      'features': features,
      'bug_fixes': bugFixes,
      'message': message,
    };
  }

  /// Check if user can dismiss the update dialog
  bool get canDismiss => !isMandatory && !forceUpdate;
}
