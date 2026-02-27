import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../res/app_url/app_url.dart';
import '../app_exceptions.dart';
import 'base_api_service.dart';

class NetworkApiServices extends BaseApiServices {
  final storage = GetStorage();

  Future<Map<String, String>> _getHeaders({Map<String, String>? extra}) async {
    final headers = {'Content-Type': 'application/json'};
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) print('GET: $url');
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));
      return returnResponse(response);
    } on SocketException {
      throw InternetExceptions('No Internet Connection');
    } on RequestTimeOut {
      throw RequestTimeOut('Request Time Out');
    }
  }

  @override
  Future<dynamic> postApi(dynamic data, String url,
      {Map<String, String>? headers}) async {
    if (kDebugMode) {
      print('POST: $url');
      print('Body: $data');
    }
    try {
      final mergedHeaders = await _getHeaders(extra: headers);
      final response = await http
          .post(Uri.parse(url), body: jsonEncode(data), headers: mergedHeaders)
          .timeout(const Duration(seconds: 15));

      final contentType = response.headers['content-type'];
      if (kDebugMode) {
        print('Status: ${response.statusCode}');
        print('Content-Type: $contentType');
      }

      if (contentType != null && contentType.contains('application/pdf')) {
        return response.bodyBytes;
      }

      return returnResponse(response);
    } on SocketException {
      throw InternetExceptions('No Internet Connection');
    } on RequestTimeOut {
      throw RequestTimeOut('Request Time Out');
    }
  }

  // Multipart POST - for requests that include file uploads
  Future<dynamic> multipartApi(
      String url,
      Map<String, String> fields, {
        File? file,
        String fileField = 'file',
      }) async {
    if (kDebugMode) {
      print('MULTIPART POST: $url');
      print('Fields: $fields');
      print('File: ${file?.path}');
    }
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Accept': 'application/json'});
      request.fields.addAll(fields);

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          fileField,
          file.path,
          filename: file.path.split('/').last,
        ));
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body = await streamed.stream.bytesToString();

      if (kDebugMode) {
        print('Status: ${streamed.statusCode}');
        print('Response: $body');
      }

      final decoded = _tryDecodeJson(body);

      switch (streamed.statusCode) {
        case 200:
        case 201:
          return decoded;
        case 400:
          throw BadRequestException(decoded['message'] ?? 'Bad Request');
        case 401:
        case 403:
          throw UnauthorizedException('Unauthorized request');
        case 500:
          throw ServerException('Server error');
        default:
          throw FetchDataException(
              decoded['message'] ?? 'Error: ${streamed.statusCode}');
      }
    } on SocketException {
      throw InternetExceptions('No Internet Connection');
    }
  }

  dynamic returnResponse(http.Response response) {
    if (kDebugMode) {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        final json = _tryDecodeJson(response.body);
        throw BadRequestException(json['message'] ?? 'Bad Request');
      case 401:
      case 403:
        throw UnauthorizedException('Unauthorized request');
      case 500:
        throw ServerException('Server error');
      default:
        final json = _tryDecodeJson(response.body);
        throw FetchDataException(
            json['message'] ?? 'Error: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }
}


// // Path: lib/data/network/network_api_services.dart
//
// import 'dart:convert';
// import 'dart:io';
//
//
// import 'package:flutter/foundation.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
//
// import '../../res/app_url/app_url.dart';
// import '../app_exceptions.dart';
// import 'base_api_service.dart';
//
// class NetworkApiServices extends BaseApiServices {
//   final storage = GetStorage();
//
//   /// 🔥 Build Headers with Token
//   Future<Map<String, String>> _getHeaders(String url, {Map<String, String>? extra}) async {
//     final token = storage.read("access_token") ?? "";
//
//     final headers = {
//       'Content-Type': 'application/json',
//     };
//
//     return headers;
//   }
//
//
//   @override
//   Future<dynamic> getApi(String url) async {
//     if (kDebugMode) print('🌐 GET Request URL: $url');
//
//     try {
//       final headers = await _getHeaders(url);
//
//       final response = await http
//           .get(Uri.parse(url), headers: headers)
//           .timeout(const Duration(seconds: 20));
//
//       return returnResponse(response);
//     } on SocketException {
//       throw InternetExceptions('No Internet Connection');
//     } on RequestTimeOut {
//       throw RequestTimeOut('Request Time Out');
//     }
//   }
//
//   @override
//   Future<dynamic> postApi(
//       dynamic data,
//       String url, {
//         Map<String, String>? headers,
//       }) async {
//     if (kDebugMode) {
//       print('🌐 POST Request URL: $url');
//       print('🌐 POST Request Body: $data');
//     }
//
//     try {
//       // use token headers unless custom passed
//       final mergedHeaders = await _getHeaders(url, extra: headers);
//
//       final response = await http
//           .post(
//         Uri.parse(url),
//         body: jsonEncode(data),
//         headers: mergedHeaders,
//       )
//           .timeout(const Duration(seconds: 15));
//
//       final contentType = response.headers['content-type'];
//
//       if (kDebugMode) {
//         print("🌐 API Response Status Code: ${response.statusCode}");
//         print("🌐 API Response Content-Type: $contentType");
//       }
//
//       // PDF case
//       if (contentType != null && contentType.contains('application/pdf')) {
//         if (kDebugMode) print("📄 PDF response received.");
//         return response.bodyBytes;
//       }
//
//       return jsonDecode(response.body);
//
//     } on SocketException {
//       throw InternetExceptions('No Internet Connection');
//     } on RequestTimeOut {
//       throw RequestTimeOut('Request Time Out');
//     }
//   }
//
//   dynamic returnResponse(http.Response response) {
//     if (kDebugMode) {
//       print('🌐 API Response Status Code: ${response.statusCode}');
//       print('🌐 API Response Body: ${response.body}');
//     }
//
//     switch (response.statusCode) {
//       case 200:
//       case 201:
//         return jsonDecode(response.body);
//
//       case 400:
//         final jsonData = _tryDecodeJson(response.body);
//         throw BadRequestException(jsonData['message'] ?? 'Bad Request');
//
//       case 401:
//       case 403:
//         throw UnauthorizedException('Unauthorized request');
//
//       case 500:
//         throw ServerException('Server error');
//
//       default:
//         final jsonData = _tryDecodeJson(response.body);
//         throw FetchDataException(
//           jsonData['message'] ?? 'Error: ${response.statusCode}',
//         );
//     }
//   }
//
//   Map<String, dynamic> _tryDecodeJson(String body) {
//     try {
//       return jsonDecode(body);
//     } catch (_) {
//       return {};
//     }
//   }
// }
//
//
//
// // // Function to handle HTTP responses and throw custom exceptions
// // dynamic returnResponse(http.Response response) {
// //   if (kDebugMode) {
// //     print('🌐 API Response Status Code: ${response.statusCode}');
// //     print('🌐 API Response Body: ${response.body}');
// //   }
// //
// //   switch (response.statusCode) {
// //     case 200:
// //     case 201:
// //       return jsonDecode(response.body);
// //     case 400:
// //       final responseJson = jsonDecode(response.body);
// //       throw BadRequestException(responseJson['message'] ?? 'Bad Request');
// //     case 401:
// //     case 403:
// //       throw UnauthorizedException(response.body.toString());
// //     case 500:
// //       throw ServerException(response.body.toString());
// //     default:
// //       try {
// //         final errorJson = jsonDecode(response.body);
// //         throw FetchDataException(
// //           errorJson['message'] ?? 'Unexpected Error: ${response.statusCode}',
// //         );
// //       } catch (_) {
// //         throw FetchDataException(
// //           'Error occurred while communication with server with StatusCode : ${response.statusCode}',
// //         );
// //       }
// //   }
// // }