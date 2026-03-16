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
  Future<Map<String, dynamic>> getInit(String token) async {
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

  // 6. Therapy Centre List (GET - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getTherapyCentres(String token) async {
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

  // 7. Get Scales (GET - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getScales(String token) async {
    final url = Uri.parse('$_baseUrl/scales');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.get(
          url,
          headers: _getHeaders(token: effectiveToken),
        );
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
  }

  // 8. Store Assessment (POST - JSON Raw - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> storeAssessment({
    required String token,
    required int childId,
    required List<Map<String, dynamic>> scores,
  }) async {
    final url = Uri.parse('$_baseUrl/child-scale-scores');
    return _withAutoRefresh(token, (effectiveToken) async {
      try {
        final response = await http.post(
          url,
          headers: _getHeaders(token: effectiveToken, isJson: true),
          body: jsonEncode({
            "child_id": childId,
            "scores": scores,
          }),
        );
        return _handleResponse(response);
      } catch (e) {
        return _handleError(e);
      }
    });
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
    required String token,
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

  // 10. Get Care Team (POST - JSON Raw - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getCareTeam({
    required String token,
    required int childId,
    int perPage = 10,
  }) async {
    final url = Uri.parse('$_baseUrl/care-team');
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

  // 12. Get Patient Libraries (POST - JSON Raw - Bearer Auth with auto-refresh)
  Future<Map<String, dynamic>> getPatientLibraries({
    required String token,
    required int childId,
    String viewMode = 'patient',
  }) async {
    final url = Uri.parse('$_baseUrl/patient-libraries');
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

  Future<Map<String, dynamic>> _withAutoRefresh(
    String token,
    Future<Map<String, dynamic>> Function(String effectiveToken) requestFn,
  ) async {
    var currentToken = token;
    var result = await requestFn(currentToken);

    final isUnauthenticated = result['success'] == false &&
        (result['message'] == 'Unauthenticated' ||
            result['status_code'] == 401);

    if (!isUnauthenticated) {
      return result;
    }

    final newToken = await _attemptTokenRefresh(currentToken);
    if (newToken == null) {
      return result;
    }

    currentToken = newToken;
    return await requestFn(currentToken);
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

      final data = result['data'] as Map<String, dynamic>?;
      final newAccess = data?['access_token'] as String?;
      final newRefresh = data?['refresh_token'] as String?;

      if (newAccess == null) {
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
        return {
          'success': true,
          'data': body,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Error: ${response.statusCode}',
          'status_code': response.statusCode,
        };
      }
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
