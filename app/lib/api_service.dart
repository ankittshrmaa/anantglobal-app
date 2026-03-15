import 'dart:convert';
import 'package:http/http.dart' as http;
import 'signup_screen.dart';

// ─── CONFIG ──────────────────────────────────────────────────────────────────
// Change this to your WSL IP if testing on a real device on same WiFi
// Run `hostname -I` in WSL to get your IP
const String kBaseUrl = 'http://localhost:8000';

// ─── RESPONSE WRAPPER ────────────────────────────────────────────────────────
class ApiResponse {
  final bool    success;
  final String  message;
  final Map<String, dynamic>? data;

  ApiResponse({required this.success, required this.message, this.data});
}

// ─── API SERVICE ─────────────────────────────────────────────────────────────
class ApiService {

  // ── SEND OTP ───────────────────────────────────────────────────────────────
  static Future<ApiResponse> sendOtp({
    required String name,
    required String mobile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'mobile': mobile}),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'OTP sent successfully',
          // dev_otp is returned by backend in development only
          data: {'dev_otp': body['dev_otp']},
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['detail'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Cannot connect to server. Make sure backend is running.',
      );
    }
  }

  // ── VERIFY OTP + REGISTER ──────────────────────────────────────────────────
  static Future<ApiResponse> verifyOtpAndRegister({
    required String name,
    required String mobile,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name':     name,
          'mobile':   mobile,
          'otp':      otp,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Account created!',
          data: body['user'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['detail'] ?? 'Verification failed',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Cannot connect to server. Make sure backend is running.',
      );
    }
  }

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  static Future<ApiResponse> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Login successful',
          data: body['user'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['detail'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Cannot connect to server. Make sure backend is running.',
      );
    }
  }
}