import 'package:flutter/material.dart';
import 'package:workfina/services/api_service.dart';
import 'dart:io';

class CandidateController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _candidateProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get candidateProfile => _candidateProfile;

  // Education - 10th
final TextEditingController class10Controller = TextEditingController();
final TextEditingController class10BoardController = TextEditingController();
final TextEditingController class10YearController = TextEditingController();
final TextEditingController class10PercentageController = TextEditingController();

// Education - 12th
final TextEditingController class12Controller = TextEditingController();
final TextEditingController class12BoardController = TextEditingController();
final TextEditingController class12YearController = TextEditingController();
final TextEditingController class12PercentageController = TextEditingController();

// Education - Graduation
final TextEditingController graduationController = TextEditingController();
final TextEditingController graduationUniversityController = TextEditingController();
final TextEditingController graduationYearController = TextEditingController();
final TextEditingController graduationPercentageController = TextEditingController();

// Education - Post Graduation
final TextEditingController postGraduationController = TextEditingController();
final TextEditingController postGraduationUniversityController = TextEditingController();
final TextEditingController postGraduationYearController = TextEditingController();
final TextEditingController postGraduationPercentageController = TextEditingController();

// Other Education
final TextEditingController otherEducationController = TextEditingController();

// Skills
final TextEditingController skillsController = TextEditingController();

// Education section expansion states
bool showClass10 = false;
bool showClass12 = false;
bool showGraduation = true; // Open by default since required
bool showPostGraduation = false;
bool showOtherEducation = false;


void toggleClass10() {
  showClass10 = !showClass10;
  notifyListeners();
}

void toggleClass12() {
  showClass12 = !showClass12;
  notifyListeners();
}

void toggleGraduation() {
  showGraduation = !showGraduation;
  notifyListeners();
}

void togglePostGraduation() {
  showPostGraduation = !showPostGraduation;
  notifyListeners();
}

void toggleOtherEducation() {
  showOtherEducation = !showOtherEducation;
  notifyListeners();
}

// void setRole(String role) {
//   selectedRole = role;
//   notifyListeners();
// }

// void setReligion(String religion) {
//   selectedReligion = religion;
//   notifyListeners();
// }

// void setResumeFile(File? file, String? fileName) {
//   resumeFile = file;
//   resumeFileName = fileName;
//   notifyListeners();
// }

// void setVideoFile(File? file, String? fileName) {
//   videoIntroFile = file;
//   videoIntroFileName = fileName;
//   notifyListeners();
// }

String combineEducationData() {
  List<String> educationParts = [];

  if (class10Controller.text.isNotEmpty) {
    educationParts.add(
      '10th: ${class10Controller.text}, ${class10BoardController.text} (${class10YearController.text}) - ${class10PercentageController.text}%',
    );
  }

  if (class12Controller.text.isNotEmpty) {
    educationParts.add(
      '12th: ${class12Controller.text}, ${class12BoardController.text} (${class12YearController.text}) - ${class12PercentageController.text}%',
    );
  }

  if (graduationController.text.isNotEmpty) {
    educationParts.add(
      'Graduation: ${graduationController.text}, ${graduationUniversityController.text} (${graduationYearController.text}) - ${graduationPercentageController.text}%',
    );
  }

  if (postGraduationController.text.isNotEmpty) {
    educationParts.add(
      'Post-Graduation: ${postGraduationController.text}, ${postGraduationUniversityController.text} (${postGraduationYearController.text}) - ${postGraduationPercentageController.text}%',
    );
  }

  if (otherEducationController.text.isNotEmpty) {
    educationParts.add('Other: ${otherEducationController.text}');
  }

  return educationParts.join(' | ');
}


bool validateProfessionalInfo() {
  return graduationController.text.isNotEmpty &&
      graduationUniversityController.text.isNotEmpty &&
      graduationYearController.text.isNotEmpty &&
      skillsController.text.isNotEmpty;
}

bool hasClass10Data() => class10Controller.text.isNotEmpty;
bool hasClass12Data() => class12Controller.text.isNotEmpty;
bool hasGraduationData() {
  return graduationController.text.isNotEmpty ||
         graduationUniversityController.text.isNotEmpty ||
         graduationYearController.text.isNotEmpty ||
         graduationPercentageController.text.isNotEmpty;
}
bool hasPostGraduationData() => postGraduationController.text.isNotEmpty;
bool hasOtherEducationData() => otherEducationController.text.isNotEmpty;


  Future<bool> registerCandidate({
    required String fullName,
    required String phone,
    required int age,
    required String role,
    required int experienceYears,
    double? currentCtc,
    double? expectedCtc,
    String? religion,
    String country = 'India',
    required String state,
    required String city,
    required String education,
    required String skills,
    File? resumeFile,
    File? videoIntroFile,  // ✅ ADD THIS

  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.registerCandidate(
        fullName: fullName,
        phone: phone,
        age: age,
        role: role,
        experienceYears: experienceYears,
        currentCtc: currentCtc,
        expectedCtc: expectedCtc,
        religion: religion,
        country: country,
        state: state,
        city: city,
        education: combineEducationData(),
        skills: skills,
        resumeFile: resumeFile,
        videoIntroFile: videoIntroFile,  // ✅ ADD THIS

      );

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _candidateProfile = response;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkProfileExists() async {
    try {
      final response = await ApiService.getCandidateProfile();

      if (response.containsKey('error')) {
        return false;
      }

      _candidateProfile = response;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }


  // Add this method to your CandidateController class

Future<bool> updateProfile({
  String? fullName,
  String? phone,
  int? age,
  String? role,
  int? experienceYears,
  double? currentCtc,
  double? expectedCtc,
  String? religion,
  String? state,
  String? city,
  String? education,
  String? skills,
  File? resumeFile,
  File? videoIntroFile,
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await ApiService.updateCandidateProfile(
      fullName: fullName,
      phone: phone,
      age: age,
      role: role,
      experienceYears: experienceYears,
      currentCtc: currentCtc,
      expectedCtc: expectedCtc,
      religion: religion,
      state: state,
      city: city,
      education: education,
      skills: skills,
      resumeFile: resumeFile,
    );

    if (response.containsKey('error')) {
      _error = response['error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Update local profile data with the response
    if (response.containsKey('profile')) {
      _candidateProfile = response['profile'];
    }

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _error = 'Failed to update profile: $e';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
@override
void dispose() {
  // Personal Info
  // fullNameController.dispose();
  // phoneController.dispose();
  // ageController.dispose();
  // experienceController.dispose();
  
  // Education - 10th
  class10Controller.dispose();
  class10BoardController.dispose();
  class10YearController.dispose();
  class10PercentageController.dispose();
  
  // Education - 12th
  class12Controller.dispose();
  class12BoardController.dispose();
  class12YearController.dispose();
  class12PercentageController.dispose();
  
  // Education - Graduation
  graduationController.dispose();
  graduationUniversityController.dispose();
  graduationYearController.dispose();
  graduationPercentageController.dispose();
  
  // Education - Post Graduation
  postGraduationController.dispose();
  postGraduationUniversityController.dispose();
  postGraduationYearController.dispose();
  postGraduationPercentageController.dispose();
  
  // Other
  otherEducationController.dispose();
  skillsController.dispose();
  
  // Location
  // currentCtcController.dispose();
  // expectedCtcController.dispose();
  // stateController.dispose();
  // cityController.dispose();
  
  super.dispose();
}
}

