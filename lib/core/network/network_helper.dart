import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sahamitra1_0/core/global_utils.dart';


class NetworkHelper {
  // Singleton instance
  static final NetworkHelper _instance = NetworkHelper._internal();

  factory NetworkHelper() {
    return _instance;
  }

  NetworkHelper._internal();

  // Base URL from Postman collection
  static const String _baseUrl = 'https://sahamithra.tricta.com/api/v1';

  // Headers for API requests
  Map<String, String> _getHeaders({String? token, bool isJson = true}) {
    return {
      if (isJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// `/scales` and `/guest-scales` expect DOB; guest API uses `dd-MM-yyyy`.
  static String? _normalizeDobForScalesRequest(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(s)) return s;
    try {
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s)) {
        final d = DateTime.parse(s.split('T').first);
        return DateFormat('dd-MM-yyyy').format(d);
      }
    } catch (_) {}
    try {
      final d = DateFormat('dd/MM/yyyy').parse(s);
      return DateFormat('dd-MM-yyyy').format(d);
    } catch (_) {}
    try {
      final d = DateFormat('dd-MM-yyyy').parse(s);
      return DateFormat('dd-MM-yyyy').format(d);
    } catch (_) {}
    return s;
  }

  // 1. Verify Mobile (POST - Form Data)
  Future<Map<String, dynamic>> verifyMobile(String phone) async {
    final url = Uri.parse('$_baseUrl/verify-mobile');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(isJson: false),
        body: {'phone': '+91$phone'},
      );
      print('verifyMobile response ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 2. Verify OTP (POST - Form Data)
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final url = Uri.parse('$_baseUrl/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(isJson: false),
        body: {
          'phone': '+91$phone',
          'otp': otp,
          'device_id': '1234567890', // Placeholder
          'platform': 'ios', // Placeholder
        },
      );
      print('verifyOtp response ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 3. Register Step 1 (POST - Form Data)
  Future<Map<String, dynamic>> registerStep1({
    required String childName,
    required String parentsName,
    required String address,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/register1');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(isJson: false),
        body: {
          'child_name': childName,
          'parents_name': parentsName,
          'address': address,
          'phone_number': '+91$phoneNumber',
        },
      );
      print('registerStep1 response ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 4. Register Step 2 (POST - Form Data)
  Future<Map<String, dynamic>> registerStep2({
    required String childId,
    required String dob,
    required String gender,
    required String birthOrder,
    required String mothersAgeAtBirth,
    required String bloodRelationship,
    String familyHistory = '',
  }) async {
    final url = Uri.parse('$_baseUrl/register2');

    var body = {
      'child_id': childId,
      'dob': dob,
      'gender': gender,
      'birth_order': birthOrder,
      'mothers_age_at_birth': mothersAgeAtBirth,
      'blood_relationship': bloodRelationship,
      'family_history': familyHistory,
    };
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(isJson: false),
        body: body,
      );
      print('registerStep2 response ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 5. GetInit (GET - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getInit() async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/get-init');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        print('getInit response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Dashboard summary for a child.
  /// GET `/api/v1/get-dashboard-data?child_id={id}`
  /// Response body includes `status`, `message`, and nested `data` with progress, etc.
  Future<Map<String, dynamic>> getDashboardData({required int childId}) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/get-dashboard-data').replace(
      queryParameters: {'child_id': childId.toString()},
    );

    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        print('getDashboardData response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  // 6. Therapy Centre List (GET - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getTherapyCentres() async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/therapy-centres');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        print('getTherapyCentres response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Nearby therapy centres around a geo point.
  /// GET `/api/v1/therapy-centres-nearby?latitude={lat}&longitude={lng}&radius={km}`
  Future<Map<String, dynamic>> getNearbyTherapyCentres({
    required double latitude,
    required double longitude,
    double radius = 40,
  }) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/therapy-centres-nearby').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      },
    );
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        print('getNearbyTherapyCentres response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  // 7. Get Scales (GET - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getScales() async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/scales');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        print('getScales response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  // 7.1 Fetch Scales Questions (POST - Bearer Auth with auto-refresh)
  // Only `category` is passed from UI; `dob` is taken from `GlobalUtils().childDob`.
  /// Logged-in users: POST `/scales` with bearer token + `childDob` (existing API).
  /// Guest explore mode (no token): POST `/guest-scales` with `guestDob` (`dd-MM-yyyy`).
  /// If both [token] and guest flag exist, the token wins — authenticated API is used.
  /// [page] is sent when > 1 for paginated scale lists (e.g. LEST).
  Future<Map<String, dynamic>> fetchScalesQuestions({
    required String category,
    int page = 1,
  }) async {
    final utils = GlobalUtils();
    final token = utils.token;

    if (token != null) {
      final rawChildDob = utils.childDob;
      final dob =
          _normalizeDobForScalesRequest(rawChildDob) ?? rawChildDob?.trim();
      if (dob == null || dob.isEmpty) {
        return {
          'success': false,
          'message': 'Child DOB not found',
        };
      }

      final url = Uri.parse('$_baseUrl/scales');
      return _withAutoRefresh(token, (effectiveToken) async {
        final body = <String, dynamic>{
          'category': category,
          'dob': dob,
        };
        if (page > 1) {
          body['page'] = page;
        }
        print('Called fetchScalesQuestions api with url: $url and body: $body');
        try {
          final response = await http.post(
            url,
            headers: _getHeaders(token: effectiveToken, isJson: true),
            body: jsonEncode(body),
          );
          print('Called fetchScalesQuestions response: ${response.body}');

          return _handleResponse(response);
        } catch (e) {
          return _handleError(e);
        }
      });
    }

    if (utils.isGuestUser) {
      final dob = _normalizeDobForScalesRequest(utils.guestDob ?? utils.childDob);
      if (dob == null || dob.isEmpty) {
        return {
          'success': false,
          'message': 'Child DOB not found',
        };
      }

      final url = Uri.parse('$_baseUrl/guest-scales');
      final body = <String, dynamic>{
        'category': category,
        'dob': dob,
      };
      if (page > 1) {
        body['page'] = page;
      }
      print('Called fetchScalesQuestions (guest) url: $url body: $body');
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(isJson: true),
          body: jsonEncode(body),
        );
        print('Called fetchScalesQuestions (guest) response: ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    }

    return {
      'success': false,
      'message': 'Authentication token not found',
    };
  }

  // 8. Store Assessment (POST - JSON Raw - Bearer Auth with auto-refresh)
  /// Logged-in users: POST `/child-scale-scores` (existing API).
  /// Guest (no token): POST `/guest-scale-scores` with `category` and `scores` only.
  /// When [token] is present, authenticated API is used regardless of guest flag.
  Future<Map<String, dynamic>> storeAssessment({
    required String category,
    required List<Map<String, dynamic>> scores,
    int? childId,
  }) async {
    final utils = GlobalUtils();
    final token = utils.token;

    if (token != null) {
      if (childId == null) {
        return {
          'success': false,
          'message': 'Child id not found',
        };
      }

      final url = Uri.parse('$_baseUrl/child-scale-scores');
      print('store assessment body ${{
        "child_id": childId,
        "category": category,
        "scores": scores,
      }}');
      return _withAutoRefresh(token, (effectiveToken) async {
        try {
          final response = await http.post(
            url,
            headers: _getHeaders(token: effectiveToken, isJson: true),
            body: jsonEncode({
              "child_id": childId,
              "category": category,
              "scores": scores,
            }),
          );
          return _handleResponse(response);
        } catch (e) {
          return _handleError(e);
        }
      });
    }

    if (utils.isGuestUser) {
      final url = Uri.parse('$_baseUrl/guest-scale-scores');
      final payload = {
        'category': category,
        'scores': scores,
      };
      print('storeAssessment (guest) url: $url body: $payload');
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(isJson: true),
          body: jsonEncode(payload),
        );
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    }

    return {
      'success': false,
      'message': 'Authentication token not found',
    };
  }

  String _convertTo24Hour(String time) {
    try {
      final parsed = DateFormat('h:mm a').parse(time);
      return DateFormat('HH:mm').format(parsed);
    } catch (_) {
      return time;
    }
  }

  // 9. Create Appointment Request (POST - JSON Raw - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> createAppointmentRequest({
    required int childId,
    required int institutionId,
    required int specialityId,
    required int therapistId,
    required String preferredDate,
    required String preferredTime,
    String reasonForVisit = '"Speech delay consultation',
  }) async {

    final formattedPreferredTime = _convertTo24Hour(preferredTime);

    final body = jsonEncode({
      "child_id": childId,
      "institution_id": institutionId,
      "speciality_id": specialityId,
      "therapist_id": therapistId,
      "preferred_date": preferredDate,
      "preferred_time": formattedPreferredTime,
      "reason_for_visit": reasonForVisit,
    });
        print('Called create appointment api with body: $body');

    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/appointment-request');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode({
            "child_id": childId,
            "institution_id": institutionId,
            "speciality_id": specialityId,
            "therapist_id": therapistId,
            "preferred_date": preferredDate,
            "preferred_time": formattedPreferredTime,
            "reason_for_visit": reasonForVisit,
          }),
        );
        print('createAppointmentRequest response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Get appointments list for a child (optional filters: centre, speciality, date).
  /// POST `/api/v1/appointments?page={page}` with JSON body.
  Future<Map<String, dynamic>> getAppointments({
    required int childId,
    int page = 1,
    int? therapyCenterId,
    int? specialityId,
    String? date,
  }) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/appointments').replace(
      queryParameters: {'page': page.toString()},
    );

    final Map<String, dynamic> body = <String, dynamic>{
      'child_id': childId,
    };
    if (therapyCenterId != null) {
      body['therapy_center_id'] = therapyCenterId;
    }
    if (specialityId != null) {
      body['speciality_id'] = specialityId;
    }
    if (date != null && date.isNotEmpty) {
      body['date'] = date;
    }

    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode(body),
        );
        print('getAppointments response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Cancel an appointment by id.
  /// POST `/api/v1/appointments/{id}/cancel` with body `{ "child_id": <id> }`
  Future<Map<String, dynamic>> cancelAppointment({
    required int appointmentId,
    required int childId,
  }) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/appointments/$appointmentId/update');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode({
            'child_id': childId,
            'appointment_status': 'cancelled_by_parent',
          }),
        );
        print('cancelAppointment response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  // 10. Get Care Team (POST - JSON Raw - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getCareTeam({
    required int childId,
    int perPage = 10,
  }) async {
    final url = Uri.parse('$_baseUrl/care-team');
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode({
            "child_id": childId,
            "per_page": perPage,
          }),
        );
        print('getCareTeam response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  // Called getPatientLibraries api with body: https://sahamithra.tricta.com/api/v1/patient-libraries
  //  getPatientLibraries response {"status":true,"message":"Patient libraries fetched successfully","data":[[]],"pagination":{"current_page":1,"last_page":1,"per_page":10,"total":0,"has_more":false}}
  // 12. Get Patient Libraries (POST - JSON Raw - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getPatientLibraries({
    required int childId,
    String viewMode = 'patient',
  }) async {
    final url = Uri.parse('$_baseUrl/patient-libraries');
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }
    print('Called getPatientLibraries api with url: $url and body ${{
      "child_id": childId,
      "view_mode": viewMode,
    }}');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode({
            "child_id": childId,
            "view_mode": viewMode,
          }),
        );
        print('getPatientLibraries response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Guest video libraries (no auth). POST `/guest-libraries`
  Future<Map<String, dynamic>> getGuestLibraries({
    String viewMode = 'guest',
  }) async {
    final url = Uri.parse('$_baseUrl/guest-libraries');
    final payload = {'view_mode': viewMode};
    print('Called getGuestLibraries url: $url body: $payload');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(isJson: true),
        body: jsonEncode(payload),
      );
      print('getGuestLibraries response ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Updates watch status and completion for a therapy video session.
  /// POST `/api/v1/patient-session/watch-update`
  Future<Map<String, dynamic>> updatePatientSessionWatch({
    required int childId,
    required int sessionId,
    required int watchStatus,
    required int duration,
  }) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/patient-session/watch-update');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final body = <String, dynamic>{
          'child_id': childId,
          'session_id': sessionId,
          'watch_status': watchStatus,
          'duration': duration,
        };
        print('updatePatientSessionWatch url: $url body: $body');
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode(body),
        );
        print('updatePatientSessionWatch response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Fetch assessment data used to generate/download a PDF report.
  /// GET `/api/v1/child-report/{child_id}`
  Future<Map<String, dynamic>> getAssessmentDataForPdf({
    required int childId,
  }) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/child-report/$childId/data');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        print('getAssessmentDataForPdf url: $url child_id: $childId');
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        print('getAssessmentDataForPdf response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Get detailed assessment report for a child.
  /// GET `/api/v1/child-report/{child_id}`
  ///
  /// Example:
  /// `GET /api/v1/child-report/1`
  ///
  /// Expected success payload shape:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "child_id": 1,
  ///     "child_name": "Dean",
  ///     "age": 4,
  ///     "age_group": "3-6 years",
  ///     "total_score": 1,
  ///     "percentage": "75.00",
  ///     "color": "Yellow",
  ///     "zone": {
  ///       "label": "Requires Attention",
  ///       "description": "Developmental delay indicators found."
  ///     },
  ///     "message": "Developmental delay indicators found.",
  ///     "recommended_steps": [
  ///       {
  ///         "title": "Consult a therapist.",
  ///         "description": "Professional evaluation is recommended at this stage."
  ///       }
  ///     ],
  ///     "category_breakdown": [
  ///       {
  ///         "category": "TDSC",
  ///         "total_questions": 2,
  ///         "correct_answers": 1,
  ///         "percentage": 50
  ///       }
  ///     ]
  ///   }
  /// }
  Future<Map<String, dynamic>> getDetailedAssessmentReport({
    required int childId,
  }) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/child-report/$childId');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        print('getDetailedAssessmentReport url: $url child_id: $childId');
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        print('getDetailedAssessmentReport response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  /// Submit patient feedback for a therapy session.
  /// POST `/api/v1/patient-feedback`
  Future<Map<String, dynamic>> submitPatientFeedback({
    required int sessionId,
    required int therapyId,
    required String feedbackSubject,
    required String feedbackDescription,
  }) async {
    final token = GlobalUtils().token;
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    final url = Uri.parse('$_baseUrl/patient-feedback');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final body = <String, dynamic>{
          'session_id': sessionId,
          'therapy_id': therapyId,
          'feedback_subject': feedbackSubject,
          'feedback_description': feedbackDescription,
        };
        print('submitPatientFeedback url: $url body: $body');
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode(body),
        );
        print('submitPatientFeedback response ${response.body}');
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  // 11. Refresh Access Token (POST - Form Data - Bearer Auth)
  Future<Map<String, dynamic>> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    final url = Uri.parse('$_baseUrl/refresh-token');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token: token, isJson: false),
        body: {
          'refresh_token': refreshToken,
        },
      );
      print('refreshToken response ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 12. Logout (POST - Form Data - Bearer Auth)
  Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$_baseUrl/logout');

    final accessToken = GlobalUtils().token;
    final refresh = GlobalUtils().refreshToken;

    if (accessToken == null || accessToken.isEmpty) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    if (refresh == null || refresh.isEmpty) {
      return {
        'success': false,
        'message': 'Refresh token not found',
      };
    }

    return _withAutoRefresh(accessToken, (effectiveToken) async {
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: false),
          body: {
            'refresh_token': refresh,
          },
        );
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  Future<Map<String, dynamic>> _withAutoRefresh(
    String token,
    Future<Map<String, dynamic>> Function(String effectiveToken) requestFn,
  ) async {
    var currentToken = token;
    var result = await requestFn(currentToken);
    final isUnauthenticated = _isUnauthenticatedResponse(result);

    if (!isUnauthenticated) {
      return result;
    }

    // Keep the current API call (with same payload/closure context) and retry it
    // after a successful token refresh.
    final pendingRequest =
        (String effectiveToken) => requestFn(effectiveToken);

    final newToken = await _attemptTokenRefresh(currentToken);
    if (newToken == null) {
      // Refresh failed; force logout.
      await GlobalUtils().logout();
      return result;
    }

    currentToken = newToken;

    final retryResult = await pendingRequest(currentToken);
    final retryUnauthenticated = _isUnauthenticatedResponse(retryResult);

    if (retryUnauthenticated) {
      await GlobalUtils().logout();
    }

    return retryResult;
  }

  bool _isUnauthenticatedResponse(Map<String, dynamic> result) {
    final statusCode = result['status_code'];
    final success = result['success'];
    final message = (result['message'] ?? '').toString().trim().toLowerCase();

    // Some handlers put raw body in `data`; check nested message too.
    String nestedMessage = '';
    final data = result['data'];
    if (data is Map) {
      nestedMessage = (data['message'] ?? '').toString().trim().toLowerCase();
    }

    final hasUnauthMessage = message.contains('unauth') ||
        nestedMessage.contains('unauth') ||
        message == 'unauthenticated' ||
        nestedMessage == 'unauthenticated';

    return success == false && (statusCode == 401 || hasUnauthMessage);
  }

  Future<String?> _attemptTokenRefresh(String oldToken) async {
    try {
      final storedRefresh = GlobalUtils().refreshToken;
      if (storedRefresh == null || storedRefresh.isEmpty) {
        return null;
      }

      final result = await refreshToken(
        token: oldToken,
        refreshToken: storedRefresh,
      );

      if (result['success'] != true) {
        return null;
      }

      // `_handleResponse` stores the full decoded body under `result['data']`.
      // Most auth responses are envelope-shaped: `{success, data: {...tokens...}}`.
      final resultBody = result['data'];
      final envelope = resultBody is Map
          ? Map<String, dynamic>.from(resultBody)
          : <String, dynamic>{};
      final tokenData = envelope['data'] is Map
          ? Map<String, dynamic>.from(envelope['data'] as Map)
          : envelope;
      final newAccess = tokenData['access_token']?.toString();
      final newRefresh = tokenData['refresh_token']?.toString();

      if (newAccess == null || newAccess.isEmpty) {
        return null;
      }

      await GlobalUtils().setToken(newAccess);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await GlobalUtils().setRefreshToken(newRefresh);
      }

      return newAccess;
    } catch (_) {
      return null;
    }
  }



  // Helper method to handle HTTP responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Some endpoints may return 2xx but include `success: false` in body
        // (e.g., authentication errors). Handle those consistently.
        if (body is Map && body['success'] == false) {
          return {
            'success': false,
            'message': body['message'] ?? 'Authentication error',
            'status_code': response.statusCode,
            'data': body,
          };
        }

        return {
          'success': true,
          'data': body,
        };
      }

      return {
        'success': false,
        'message': body is Map ? (body['message'] ?? 'Error: ${response.statusCode}') : 'Error: ${response.statusCode}',
        'status_code': response.statusCode,
        'data': body,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: $e',
        'status_code': response.statusCode,
      };
    }
  }

  // Centralized Error Handler
  Map<String, dynamic> _handleError(dynamic e) {
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}
