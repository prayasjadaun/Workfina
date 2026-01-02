class FilterOptions {
  final List<String> roles;
  final List<String> cities;
  final List<String> states;
  final List<String> countries;
  final List<String> religions;
  final List<String> educations;
  final List<String> skills;

  FilterOptions({
    required this.roles,
    required this.cities,
    required this.states,
    required this.countries,
    required this.religions,
    required this.educations,
    required this.skills,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      roles: List<String>.from(json['roles'] ?? []),
      cities: List<String>.from(json['cities'] ?? []),
      states: List<String>.from(json['states'] ?? []),
      countries: List<String>.from(json['countries'] ?? []),
      religions: List<String>.from(json['religions'] ?? []),
      educations: List<String>.from(json['educations'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roles': roles,
      'cities': cities,
      'states': states,
      'countries': countries,
      'religions': religions,
      'educations': educations,
      'skills': skills,
    };
  }
}