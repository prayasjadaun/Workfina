import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfina/models/banner_model.dart';

class ApiService {
  //   static const String baseUrl =
  //       kDebugMode
  //           ? 'http://192.168.1.3:8000/api'
  //           :
  //       'http://localhost:8000/api';

  static const bool testingOnRealDevice =
      false; // true = iPhone, false = Mac/Simulator

  static String get baseUrl {
    if (kDebugMode) {
      if (testingOnRealDevice) {
        return 'http://192.168.1.3:8000/api'; // Your Mac's IP
      } else {
        return 'http://localhost:8000/api'; // For Mac or iOS Simulator
      }
    }
    return 'http://localhost:8000/api'; // Production
  }

  static late Dio _dio;
  static bool _isRefreshing = false;

  static void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!await isTokenValid()) {
            try {
              await refreshToken();
            } catch (e) {
              // Token refresh failed, logout user
              await logout();
              // Clear token from this request
              options.headers.remove('Authorization');
              handler.next(options);
              return;
            }
          }

          final token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('[DEBUG] ${options.method} $baseUrl${options.path}');
            print('[DEBUG] Request Headers: ${options.headers}');
            if (options.data != null) {
              print('[DEBUG] Request Data: ${options.data}');
            }
            if (options.queryParameters.isNotEmpty) {
              print('[DEBUG] Query Parameters: ${options.queryParameters}');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          if (kDebugMode) {
            print('[DEBUG] Response Status: ${response.statusCode}');
            print('[DEBUG] Response Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print('[DEBUG] API Error: ${e.message}');
            print('[DEBUG] Error Type: ${e.type}');
            print(
              '[DEBUG] Request: ${e.requestOptions.method} ${e.requestOptions.path}',
            );
            print('[DEBUG] Status Code: ${e.response?.statusCode}');
          }

          // Handle connection errors specifically
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            print('[DEBUG] Network connection error detected');
            handler.next(e);
            return;
          }

          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              await refreshToken();
              final newToken = await getAccessToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

              final retryResponse = await _dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );

              handler.resolve(retryResponse);
              return;
            } catch (refreshError) {
              if (kDebugMode) {
                print('[DEBUG] Token refresh failed');
              }
              await logout();
            } finally {
              _isRefreshing = false;
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (kDebugMode) {
        print('[DEBUG] Token being sent: $token');
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('refresh_token');
    } catch (e) {
      return null;
    }
  }

  // Add this helper method after getRefreshToken()
  static Future<bool> isTokenValid() async {
    final token = await getAccessToken();
    if (token == null) return false;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Token expires in less than 30 seconds, consider it invalid
      return exp > (now + 30);
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final userData = await getUserData();
    return token != null && userData != null;
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
  }

  static Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      final response = await _dio.post(
        '/auth/send-otp/',
        data: {'email': email},
      );
      if (kDebugMode) {
        print('[DEBUG] OTP Response: ${response.data}');
      }
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[DEBUG] OTP Error: ${e.message}');
        print('[DEBUG] Response: ${e.response?.data}');
      }

      // Handle complex validation errors
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data;

        // Check for non_field_errors first
        if (errorData.containsKey('non_field_errors') &&
            errorData['non_field_errors'] is List) {
          return {
            'error': (errorData['non_field_errors'] as List).first.toString(),
          };
        }

        // Check for message field
        if (errorData.containsKey('message')) {
          return {'error': errorData['message']};
        }

        // Try to extract first validation error
        for (var key in errorData.keys) {
          if (errorData[key] is List && (errorData[key] as List).isNotEmpty) {
            return {'error': (errorData[key] as List).first.toString()};
          }
        }
      }

      return {'error': e.response?.data['message'] ?? 'Failed to send OTP'};
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Network Error: $e');
      }
      return {
        'error': 'Network connection failed. Check your internet connection.',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOTPOnly({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp/',
        data: {'email': email, 'otp': otp},
      );
      if (kDebugMode) {
        print('[DEBUG] Verify OTP Response: ${response.data}');
      }
      return response.data;
    } on DioException catch (e) {
      // Handle complex validation errors
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data;

        // Check for non_field_errors first
        if (errorData.containsKey('non_field_errors') &&
            errorData['non_field_errors'] is List) {
          return {
            'error': (errorData['non_field_errors'] as List).first.toString(),
          };
        }

        // Check for message field
        if (errorData.containsKey('message')) {
          return {'error': errorData['message']};
        }

        // Try to extract first validation error
        for (var key in errorData.keys) {
          if (errorData[key] is List && (errorData[key] as List).isNotEmpty) {
            return {'error': (errorData[key] as List).first.toString()};
          }
        }
      }

      return {
        'error': e.response?.data['message'] ?? 'OTP verification failed',
      };
    }
  }

  static Future<Map<String, dynamic>> createAccount({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/create-account/',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (kDebugMode) {
        print('[DEBUG] Create Account Response: ${response.data}');
      }

      if (response.data['access'] != null) {
        await saveTokens(
          response.data['access'],
          response.data['refresh'] ?? '',
        );
        await saveUserData(response.data['user']);
      }

      return response.data;
    } on DioException catch (e) {
      // Handle complex validation errors
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data;

        // Check for non_field_errors first
        if (errorData.containsKey('non_field_errors') &&
            errorData['non_field_errors'] is List) {
          return {
            'error': (errorData['non_field_errors'] as List).first.toString(),
          };
        }

        // Check if it's a field-specific validation error
        if (errorData.containsKey('username') &&
            errorData['username'] is List) {
          return {
            'error': 'Username already taken. Please choose a different one.',
          };
        }
        if (errorData.containsKey('email') && errorData['email'] is List) {
          return {
            'error': 'This email is already registered. Please login instead.',
          };
        }

        // Check for message field
        if (errorData.containsKey('message')) {
          return {'error': errorData['message']};
        }

        // Try to extract first validation error
        for (var key in errorData.keys) {
          if (errorData[key] is List && (errorData[key] as List).isNotEmpty) {
            return {'error': (errorData[key] as List).first.toString()};
          }
        }
      }

      return {
        'error': e.response?.data['message'] ?? 'Account creation failed',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp/',
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'username': username,
        },
      );

      if (response.data['access_token'] != null) {
        await saveTokens(
          response.data['access_token'],
          response.data['refresh_token'] ?? '',
        );
        await saveUserData(response.data['user']);
      }

      return response.data;
    } on DioException catch (e) {
      return {
        'error': e.response?.data['message'] ?? 'OTP verification failed',
      };
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      if (kDebugMode) {
        print('[DEBUG] Attempting login with baseUrl: $baseUrl');
      }
      print('[DEBUG] Attempting login to: $baseUrl/auth/login/');
      print(
        '[DEBUG] Data: ${jsonEncode({'email': email, 'password': password})}',
      );

      final response = await _dio.post(
        '/auth/login/',
        data: {'email': email, 'password': password},
      );
      print('[DEBUG] Response received: ${response.statusCode}');
      print('[DEBUG] Response data: ${response.data}');

      if (response.data['access'] != null) {
        await saveTokens(
          response.data['access'],
          response.data['refresh'] ?? '',
        );
        await saveUserData(response.data['user']);
      }

      return response.data;
    } on DioException catch (e) {
      print('[DEBUG] DioException type: ${e.type}');
      print('[DEBUG] DioException message: ${e.message}');
      print('[DEBUG] Response status: ${e.response?.statusCode}');
      print('[DEBUG] Response data: ${e.response?.data}');

      if (kDebugMode) {
        print('[DEBUG] Login Error: ${e.message}');
        print('[DEBUG] Response: ${e.response?.data}');
      }

      // Handle complex validation errors
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data;

        // Check if it's a field-specific validation error
        if (errorData.containsKey('email') && errorData['email'] is List) {
          return {'error': 'Email address is invalid or not registered.'};
        }
        if (errorData.containsKey('password') &&
            errorData['password'] is List) {
          return {'error': 'Password is incorrect.'};
        }

        // Check for message field
        if (errorData.containsKey('message')) {
          return {'error': errorData['message']};
        }

        // Try to extract first validation error
        for (var key in errorData.keys) {
          if (errorData[key] is List && (errorData[key] as List).isNotEmpty) {
            return {'error': (errorData[key] as List).first.toString()};
          }
        }
      }

      return {
        'error':
            e.response?.data['message'] ??
            'Login failed. Check your network connection.',
      };
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Network Error: $e');
      }
      return {
        'error':
            'Network connection failed. Please check your internet connection.',
      };
    }
  }

  static Future<void> logoutWithToken(String refreshToken) async {
    try {
      await _dio.post('/auth/logout/', data: {'refresh_token': refreshToken});
    } catch (e) {
      // Ignore logout errors
    }
  }

  static Future<void> updateUserRole(String role) async {
    try {
      final token = await getAccessToken();
      await _dio.patch(
        '/auth/update-role/',
        data: {'role': role},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (kDebugMode) {
        print('[DEBUG] Update Role Success');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update role');
    }
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Create a new Dio instance to avoid infinite loop with interceptor
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await saveTokens(data['access'], refreshToken);
        return data;
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> registerCandidate({
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
    File? videoIntroFile,
    File? profileImage,
    String? languages,
    String? streetAddress,
    bool willingToRelocate = false,
    String? workExperience,
    String? careerObjective,
  }) async {
    try {
      final token = await getAccessToken();

      FormData formData = FormData.fromMap({
        'full_name': fullName,
        'phone': phone,
        'age': age,
        'role': role,
        'experience_years': experienceYears,
        if (currentCtc != null) 'current_ctc': currentCtc,
        if (expectedCtc != null) 'expected_ctc': expectedCtc,
        if (religion != null) 'religion': religion,
        'country': country,
        'state': state,
        'city': city,
        'education': education,
        'skills': skills,
        if (languages != null && languages.isNotEmpty) 'languages': languages,
      if (streetAddress != null && streetAddress.isNotEmpty) 'street_address': streetAddress,
      'willing_to_relocate': willingToRelocate,
      if (workExperience != null && workExperience.isNotEmpty) 'work_experience': workExperience,
      if (careerObjective != null && careerObjective.isNotEmpty) 'career_objective': careerObjective,
        if (resumeFile != null)
          'resume': await MultipartFile.fromFile(
            resumeFile.path,
            filename: resumeFile.path.split('/').last,
          ),
        if (videoIntroFile != null) 
          'video_intro': await MultipartFile.fromFile(
            videoIntroFile.path,
            filename: videoIntroFile.path.split('/').last,
          ),
          if (profileImage != null)  
        'profile_image': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
      });

      if (kDebugMode) {
        print('[DEBUG] Register Candidate FormData: ${formData.fields}');
        if (resumeFile != null) {
          print('[DEBUG] Resume file: ${resumeFile.path}');
        }
      }

      final response = await _dio.post(
        '/candidates/register/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (kDebugMode) {
        print('[DEBUG] Register Candidate Response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['message'] ?? 'Registration failed'};
    }
  }

  static Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      final response = await _dio.get('/candidates/filter-options/');
      return response.data;
    } on DioException catch (e) {
      return {
        'error': e.response?.data['message'] ?? 'Failed to load filter options',
      };
    }
  }

  static Future<Map<String, dynamic>> getSpecificFilterOptions({
    required String type,
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': type,
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/candidates/filter-options/',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'error': e.response?.data['message'] ?? 'Failed to load filter options',
      };
    }
  }

  static Future<Map<String, dynamic>> getFilteredCandidates({
    String? role,
    int? minExperience,
    int? maxExperience,
    int? minAge,
    int? maxAge,
    String? city,
    String?name,
    String? state,
    String? country,
    String? religion,
    String? education,
    String? skills,
    double? minCtc,
    double? maxCtc,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null) queryParams['role'] = role;
      if (minExperience != null) queryParams['min_experience'] = minExperience;
      if (maxExperience != null) queryParams['max_experience'] = maxExperience;
      if (minAge != null) queryParams['min_age'] = minAge;
      if (maxAge != null) queryParams['max_age'] = maxAge;
      if (city != null) queryParams['city'] = city;
      if (state != null) queryParams['state'] = state;
      if (country != null) queryParams['country'] = country;
      if (religion != null) queryParams['religion'] = religion;
      if (education != null) queryParams['education'] = education;
      if (skills != null) queryParams['skills'] = skills;
      if (minCtc != null) queryParams['min_ctc'] = minCtc;
      if (maxCtc != null) queryParams['max_ctc'] = maxCtc;
      queryParams['page'] = page;
      queryParams['page_size'] = pageSize;

      final response = await _dio.get(
        '/recruiters/candidates/filter/',
        queryParameters: queryParams,
      );

      return response.data;
    } on DioException catch (e) {
      return {
        'error': e.response?.data['message'] ?? 'Failed to load candidates',
      };
    }
  }

  static Future<Map<String, dynamic>> registerRecruiter({
    required String fullName,
    required String companyName,
    required String designation,
    required String phone,
    String? companyWebsite,
    required String companySize,
  }) async {
    try {
      final response = await _dio.post(
        '/recruiters/register/',
        data: {
          'full_name': fullName,
          'company_name': companyName,
          'designation': designation,
          'phone': phone,
          'company_website': companyWebsite,
          'company_size': companySize,
        },
      );

      if (kDebugMode) {
        print('[DEBUG] Register Recruiter Response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['message'] ?? 'Registration failed'};
    }
  }

  static Future<Map<String, dynamic>> getRecruiterProfile() async {
    try {
      final response = await _dio.get('/recruiters/profile/');
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['message'] ?? 'Failed to load profile'};
    }
  }

  static Future<Map<String, dynamic>> updateRecruiterProfile({
    String? fullName,
    String? companyName,
    String? designation,
    String? phone,
    String? companyWebsite,
    String? companySize,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (companyName != null) data['company_name'] = companyName;
      if (designation != null) data['designation'] = designation;
      if (phone != null) data['phone'] = phone;
      if (companyWebsite != null) data['company_website'] = companyWebsite;
      if (companySize != null) data['company_size'] = companySize;

      final response = await _dio.patch(
        '/recruiters/profile/update/',
        data: data,
      );

      if (kDebugMode) {
        print('[DEBUG] Update Recruiter Profile Response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['message'] ?? 'Update failed'};
    }
  }

  static Future<Map<String, dynamic>> getCandidateProfile() async {
    try {
      final response = await _dio.get('/candidates/profile/');
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['message'] ?? 'Failed to load profile'};
    }
  }

  static Future<Map<String, dynamic>> updateCandidateProfile({
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
    File? profileImage,
    String? languages,
    String? streetAddress,
    bool? willingToRelocate,
    String? workExperience,
    String? careerObjective,
  }) async {
    try {
      final token = await getAccessToken();

      FormData formData = FormData.fromMap({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (age != null) 'age': age,
        if (role != null) 'role': role,
        if (experienceYears != null) 'experience_years': experienceYears,
        if (currentCtc != null) 'current_ctc': currentCtc,
        if (expectedCtc != null) 'expected_ctc': expectedCtc,
        if (religion != null) 'religion': religion,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (education != null) 'educations': education,
        if (skills != null) 'skills': skills,
        if (languages != null) 'languages': languages,
        if (streetAddress != null) 'street_address': streetAddress,
        if (willingToRelocate != null) 'willing_to_relocate': willingToRelocate,
        if (workExperience != null) 'work_experiences': workExperience,
        if (careerObjective != null) 'career_objective': careerObjective,
        if (resumeFile != null)
          'resume': await MultipartFile.fromFile(
            resumeFile.path,
            filename: resumeFile.path.split('/').last,
          ),
        if (videoIntroFile != null)
          'video_intro': await MultipartFile.fromFile(
            videoIntroFile.path,
            filename: videoIntroFile.path.split('/').last,
          ),
        if (profileImage != null)
          'profile_image': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
      });

      final response = await _dio.put(
        '/candidates/profile/update/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      return {
        'error':
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to update profile',
      };
    }
  }

  static Future<Map<String, dynamic>> getCandidatesList({
    String? role,
    int? minExperience,
    int? maxExperience,
    String? city,
    String? state,
    String? religion,
    String? skills,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null) queryParams['role'] = role;
      if (minExperience != null) queryParams['min_experience'] = minExperience;
      if (maxExperience != null) queryParams['max_experience'] = maxExperience;
      if (city != null) queryParams['city'] = city;
      if (state != null) queryParams['state'] = state;
      if (religion != null) queryParams['religion'] = religion;
      if (skills != null) queryParams['skills'] = skills;

      final response = await _dio.get(
        '/candidates/list',
        queryParameters: queryParams,
      );

      // Wrap the direct array response in the expected format
      return {'candidates': response.data};
    } on DioException catch (e) {
      return {
        'error': e.response?.data['message'] ?? 'Failed to load candidates',
      };
    }
  }

  // static Future<Map<String, dynamic>> updateRecruiterProfile({
  //   String? fullName,
  //   String? companyName,
  //   String? designation,
  //   String? phone,
  //   String? companyWebsite,
  //   String? companySize,
  // }) async {
  //   try {
  //     final data = <String, dynamic>{};
  //     if (fullName != null) data['full_name'] = fullName;
  //     if (companyName != null) data['company_name'] = companyName;
  //     if (designation != null) data['designation'] = designation;
  //     if (phone != null) data['phone'] = phone;
  //     if (companyWebsite != null) data['company_website'] = companyWebsite;
  //     if (companySize != null) data['company_size'] = companySize;

  //     final response = await _dio.patch(
  //       '/recruiters/profile/update/',
  //       data: data,
  //     );

  //     if (kDebugMode) {
  //       print('[DEBUG] Update Recruiter Profile Response: ${response.data}');
  //     }

  //     return response.data;
  //   } on DioException catch (e) {
  //     return {'error': e.response?.data['message'] ?? 'Update failed'};
  //   }
  // }

  static Future<Map<String, dynamic>> unlockCandidate(
    String candidateId,
  ) async {
    try {
      final response = await _dio.post('/candidates/$candidateId/unlock/');
      if (kDebugMode) {
        print('[DEBUG] Unlock Candidate Response: ${response.data}');
      }
      return response.data;
    } on DioException catch (e) {
      return {
        'error': e.response?.data['message'] ?? 'Failed to unlock candidate',
      };
    }
  }

  static Future<Map<String, dynamic>> getUnlockedCandidates() async {
    try {
      final response = await _dio.get('/candidates/unlocked/');
      return response.data;
    } on DioException catch (e) {
      return {
        'error':
            e.response?.data['message'] ?? 'Failed to load unlocked candidates',
      };
    }
  }

  static Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallet/balance/');
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['message'] ?? 'Failed to load wallet'};
    }
  }

  static Future<Map<String, dynamic>> addCandidateNote({
    required String candidateId,
    required String noteText,
  }) async {
    try {
      if (kDebugMode) {
        print('[DEBUG] Adding note for candidate: $candidateId');
        print('[DEBUG] Note text: $noteText');
      }

      final response = await _dio.post(
        '/candidates/$candidateId/note/',
        data: {'note_text': noteText},
      );

      if (kDebugMode) {
        print('[DEBUG] Add Note Response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Add Note Error: ${e.message}');
        print('[DEBUG] Response: ${e.response?.data}');
      }
      return {
        'error':
            e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Failed to add note',
      };
    }
  }

  static Future<Map<String, dynamic>> addCandidateFollowup({
    required String candidateId,
    required String followupDate,
    String? notes,
    bool isCompleted = false,
  }) async {
    try {
      if (kDebugMode) {
        print('[DEBUG] Adding followup for candidate: $candidateId');
        print('[DEBUG] Followup date: $followupDate');
      }

      final response = await _dio.post(
        '/candidates/$candidateId/followup/',
        data: {
          'followup_date': followupDate,
          if (notes != null) 'notes': notes,
          'is_completed': isCompleted,
        },
      );

      if (kDebugMode) {
        print('[DEBUG] Add Followup Response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Add Followup Error: ${e.message}');
        print('[DEBUG] Response: ${e.response?.data}');
      }
      return {
        'error':
            e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Failed to add followup',
      };
    }
  }

  static Future<Map<String, dynamic>> getCandidateNotesFollowups(
    String candidateId,
  ) async {
    try {
      if (kDebugMode) {
        print('[DEBUG] Loading notes/followups for candidate: $candidateId');
      }

      final response = await _dio.get(
        '/candidates/$candidateId/notes-followups/',
      );

      if (kDebugMode) {
        print('[DEBUG] Notes/Followups Response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Load Notes/Followups Error: ${e.message}');
        print('[DEBUG] Response: ${e.response?.data}');
      }
      return {
        'error':
            e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Failed to load notes and followups',
      };
    }
  }

  static Future<Map<String, dynamic>> rechargeWallet({
    required int credits,
    String? paymentReference,
  }) async {
    try {
      final response = await _dio.post(
        '/wallet/recharge/',
        data: {'credits': credits, 'payment_reference': paymentReference},
      );
      if (kDebugMode) {
        print('[DEBUG] Recharge Wallet Response: ${response.data}');
      }
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['message'] ?? 'Recharge failed'};
    }
  }

  static Future<Map<String, dynamic>> getWalletTransactions() async {
    try {
      final response = await _dio.get('/wallet/transactions/');
      return response.data;
    } on DioException catch (e) {
      return {
        'error': e.response?.data['message'] ?? 'Failed to load transactions',
      };
    }
  }

  static Future<BannerModel?> fetchActiveBanner() async {
  try {
    final response = await _dio.get('/banner/active/'); // tumhara endpoint

    if (response.statusCode == 200 && response.data != null) {
      return BannerModel.fromJson(response.data);
    }
  } on DioException catch (e) {
    if (kDebugMode) {
      print('[DEBUG] Banner fetch error: ${e.message}');
      print('[DEBUG] Response: ${e.response?.data}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('[DEBUG] Unexpected error fetching banner: $e');
    }
  }

  return null;
}


  static Future<Map<String, dynamic>> getFilterCategories() async {
    try {
      final response = await _dio.get('/candidates/filter-categories/');
      if (kDebugMode) {
        print('[DEBUG] Filter Categories Response: ${response.data}');
      }
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Filter Categories Error: ${e.message}');
        print('[DEBUG] Response: ${e.response?.data}');
      }
      return {
        'error': e.response?.data['message'] ?? 'Failed to load filter categories',
      };
    }
  }

  static Future<Map<String, dynamic>> getCategorySubcategories(String categorySlug) async {
    try {
      final response = await _dio.get(
        '/candidates/filter-options/',
        queryParameters: {'category': categorySlug},
      );
      if (kDebugMode) {
        print('[DEBUG] Category Subcategories Response: ${response.data}');
      }
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Category Subcategories Error: ${e.message}');
        print('[DEBUG] Response: ${e.response?.data}');
      }
      return {
        'error': e.response?.data['message'] ?? 'Failed to load subcategories',
      };
    }
  }
}

