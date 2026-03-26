import 'dart:developer';
import 'package:flutter/services.dart';

class NfcService {
  static const MethodChannel _channel = MethodChannel('vnpt_nfc_channel');

  /// Token VNPT SDK (lấy từ https://ekyc.vnpt.vn/admin-dashboard/console/project-manager)
  /// accessToken: "Bearer + (Access token)"
  /// tokenId: mã định danh
  /// tokenKey: mã bảo mật
  String? accessToken;
  String? tokenId;
  String? tokenKey;

  NfcService({this.accessToken, this.tokenId, this.tokenKey});

  /// Bắt đầu luồng quét MRZ -> đọc NFC CCCD qua VNPT SDK
  Future<dynamic> startMRZAndNFC() async {
    try {
      final Map<String, dynamic> args = {};

      args['accessToken'] =
          // 'bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0cmFuc2FjdGlvbl9pZCI6IjQ0OTBkYTgyLTEzMmItNDg0OS04MTU2LTJmNWViMjY5ZmRiMiIsInN1YiI6Ijg0NTczODBjLTFlODgtMTFmMS1iNzBjLWEzYTAzYzY2YzU5YiIsImF1ZCI6WyJyZXN0c2VydmljZSJdLCJ1c2VyX25hbWUiOiJ2ZXJ5eHByb2plY3RAZ21haWwuY29tIiwic2NvcGUiOlsicmVhZCJdLCJpc3MiOiJodHRwczovL2xvY2FsaG9zdCIsIm5hbWUiOiJ2ZXJ5eHByb2plY3RAZ21haWwuY29tIiwiZXhwIjoxNzc0NDk4MjEzLCJ1dWlkX2FjY291bnQiOiI4NDU3MzgwYy0xZTg4LTExZjEtYjcwYy1hM2EwM2M2NmM1OWIiLCJhdXRob3JpdGllcyI6WyJVU0VSIl0sImp0aSI6ImZmZTM2NWM5LWUwM2EtNDA0NC04NWUzLWYzMTgzYzc1OGQ4ZSIsImNsaWVudF9pZCI6ImNsaWVudGFwcCJ9.vwSVqs8Q28h_uAPEIHAyeBCmyudBFIjOrbyMhwQdSfT8U3eU8S8eVr53EBs7-2gLtdw_sfI3-yk7WmpgIM49mjNtKMW3thWSXxoSkBPHfuhrI0TdOyg3sD3s_Gr7ro7fPkbRVf3rrIfxBH0agfoEow3nF9yzDILzEp5lXyceYsbxxr5M5oMj0HAudqb6rK5iG9FYyYL__baMDFNModGciHI7Mx0d_FcupBQshDcyCffPyJnmjIdplvdqCmhrH1CxT1g5EjYFapZFsenhudGW80lKGz1HBuOlFT_-zsG9NDoIzhZdCIn_qCKEIU718jmV2SVIRJ958D52DAmcm1UmpQ';
          'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0cmFuc2FjdGlvbl9pZCI6IjUwZTA2MzBjLWRlMDUtNDIzMy1iZjkxLTZmOTUwN2IwNzMyMSIsImF1ZCI6WyJyZXN0c2VydmljZSJdLCJzY29wZSI6WyJpZGd2MiJdLCJleHAiOjE3NzQ0OTk3NTEsImp0aSI6IjQyNjI2ZDE5LTU3OWEtNGNkMy05YjMxLWJiZmEzNDcyYjVhNyIsImNsaWVudF9pZCI6ImlkZ3YyLXR5cGUzMS0wZmQyN2VjZi1jNGY2LTQ4ZWMtYTdiNS1lNWQ0MDQ2MzM4ZmUifQ.bCSeWJUkL1Kt2vvv_gTvmdPdVfhrvkym-ds86CqxR3XbGc4N3EkxwDioSz53N0cFbKQ4I8RYxKyCosPeb3tedUmqabGS_UNN--A0Za3P97JsV-WLzEVVXUGSQrCNq8K4F2YLCMz7XeTM3oVFUoYVnt4N0M4EXyfCZrD1Z0YqtQpMxn-9RhPGD-GhFzaBB-53gqvdzwQr-UBCDVv_DIsP-ghUHVucHL52TlObsDwIxKXY0YntFucjap-oOp8W1c-UNlBU7XtIglXG-_wJaWk7nwIY_nSIYN8rqhRt0CeDGnHEm37F08ND9gJGbmtHHsps1zrlpTOIHQZQY5E2s-TOlw';
      // args['tokenId'] = '4ce00b4b-e96d-2a37-e063-62199f0ae4f4';

      // args['tokenKey'] =
      //     'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALQ+kgAtm0J+koZZoaKqzYC+ufc0dCkdbI1s9OQXEKdX7UQ24mbqn/jVYFwCOFbfr2sJmBkUa0nE3myvSDXwtr0CAwEAAQ==';

      final result = await _channel.invokeMethod('startMRZNFC', args);
      print(result);
      log('=== RAW NFC RESULT FROM SDK ===');
      log(result.toString());
      log('===============================');

      if (result == null) {
        return null;
      }

      return result;
    } on PlatformException catch (e) {
      throw NfcException(
        code: e.code,
        message: e.message ?? 'Lỗi không xác định',
      );
    }
  }
}

class NfcException implements Exception {
  final String code;
  final String message;

  NfcException({required this.code, required this.message});

  @override
  String toString() => 'NfcException($code): $message';
}
